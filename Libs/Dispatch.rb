
class Dispatch

    # Dispatch::deadlineUnixtimeOrNull()
    def self.deadlineUnixtimeOrNull()
        return nil if Time.new.hour >= 21
        unixtime_at_limit = DateTime.parse("#{CommonUtils::today()} 21:00:00 +#{CommonUtils::getLocalTimeZone()}").to_time.to_i
        unixtime_now = Time.new.to_i
        0.5 * unixtime_now + 0.5 * unixtime_at_limit
    end

    # Dispatch::dayRatio()
    def self.dayRatio()
        # day ratio is 0 until 9am and then increases to 1 until 9pm
        return 0 if Time.new.hour < 9
        local_timezone = 
        unixtime_at_9am = DateTime.parse("#{CommonUtils::today()} 09:00:00 +#{CommonUtils::getLocalTimeZone()}").to_time.to_i
        unixtime_at_9pm = DateTime.parse("#{CommonUtils::today()} 21:00:00 +#{CommonUtils::getLocalTimeZone()}").to_time.to_i
        time_since_9_am = Time.new.to_i - unixtime_at_9am
        ratio = time_since_9_am / ( unixtime_at_9pm - unixtime_at_9am )
        ratio
    end

    # Dispatch::item_to_timespan(item)
    def self.item_to_timespan(item)

        if item["engine-1437"] then
            return NxEngines::missing_timespan_for_today(item)
        end

        if item["mikuType"] == "NxEngineDelegate" then
            return item["capacity"] - Bank::getValue(item["uuid"])
        end

        if item["mikuType"] == "NxPriority" and item["targetuuid"] then
            target = Items::itemOrNull(item["targetuuid"])
            if target then
                return Dispatch::item_to_timespan(target)
            end
        end

        # There are situations, such as above, where we know the answer, 
        # but for the rest, we use a blanket 10 minutes duration

        600
    end

    # Dispatch::timespanToNextDeadlineInSecondsOrNull()
    def self.timespanToNextDeadlineInSecondsOrNull()
        deadline = Dispatch::deadlineUnixtimeOrNull()
        return nil if deadline.nil?
        deadline - Time.new.to_i
    end

    # Dispatch::sequenceToTimespanInSeconds(sequence)
    def self.sequenceToTimespanInSeconds(sequence)
        sequence.map{|item| Dispatch::item_to_timespan(item) }.sum
    end

    # Dispatch::today_split(today, split_value)
    def self.today_split(today, split_value)
        # We are going to ensure that each today item has a random attribute 
        # between 0 and 1
        # Then we are going to split the collection using the split_value
        # This function exists to determine the subset of today, we are considering 
        # for dispatch calculations. The split value is meant to be the day ratio

        today = today.map{|item|
            if item["random"].nil? then
                item["random"] = rand
                Items::setAttribute(item["uuid"], "random", item["random"])
            end
            item
        }
        today.partition{|item| item["random"] <= split_value } 
    end

    # Dispatch::core(head, lucky, today_before_deadline, tail, today_later)
    def self.core(head, lucky, today_before_deadline, tail, today_later)
        # This function return the sequence made using the largest lucky,
        # makes it so that lucky + today1 meets the next deadline

        if tail.empty? then
            return {
                "head"        => head,
                "lucky"       => lucky,
                "today_before_deadline" => today_before_deadline,
                "tail"        => tail,
                "today_later" => today_later,
            }
        end

        timespan_to_deadline = Dispatch::timespanToNextDeadlineInSecondsOrNull()

        if timespan_to_deadline.nil? then
            if XCache::getOrNull("172cd807-2969-480a-8bd8-184f227e6b5d:#{CommonUtils::today()}") != "done" then
                puts "I do not have a dispatch deadline, which I interpret as the end of the day is nearing"
                puts "We need to review your remaining today items"
                (today_before_deadline+today_later).each{|item|
                    puts ""
                    puts "processing: #{PolyFunctions::toString(item).green}"
                    option = LucilleCore::selectEntityFromListOfEntitiesOrNull("option", ["done", "dismiss", "ondate"])
                    if option == "done" then
                        PolyActions::done(item)
                    end
                    if option == "dismiss" then
                        Operations::dismiss(item)
                    end
                    if option == "ondate" then
                        unixtime = CommonUtils::interactivelyMakeUnixtimeUsingDateCodeOrNull()
                        next if unixtime.nil?
                        DoNotShowUntil::doNotShowUntil(item, unixtime)
                    end
                }
                XCache::set("172cd807-2969-480a-8bd8-184f227e6b5d:#{CommonUtils::today()}", "done")
            end
            return {
                "head"        => head,
                "lucky"       => lucky,
                "today_before_deadlne" => [],
                "tail"        => tail,
                "today_later" => [],
            }
        end

        if Dispatch::sequenceToTimespanInSeconds(head + lucky + tail.take(1) + today_before_deadline) <= timespan_to_deadline then
            return Dispatch::core(head, lucky + tail.take(1), today_before_deadline, tail.drop(1), today_later)
        end

        {
            "head"        => head,
            "lucky"       => lucky,
            "today_before_deadline" => today_before_deadline,
            "tail"        => tail,
            "today_later" => today_later,
        }
    end

    # Dispatch::dispatch(head, lucky, today, tail)
    def self.dispatch(head, lucky, today, tail)
        today_before_deadline, today_later = Dispatch::today_split(today, Dispatch::dayRatio())
        data = Dispatch::core(head, lucky, today_before_deadline, tail, today_later)
        data["head"] + data["lucky"] + data["today_before_deadline"] + data["tail"] + data["today_later"]
    end

    # Dispatch::printBreakdown()
    def self.printBreakdown()
        today_before_deadline, today_later = Dispatch::today_split(FrontPage::today(), Dispatch::dayRatio())
        data = Dispatch::core(FrontPage::prioritized(), [], today_before_deadline, FrontPage::tail(), today_later)
        ["head", "lucky", "today_before_deadline", "tail", "today_later"].each{|label|
            puts "#{label}:"
            data[label].each{|item|
                puts "   - #{PolyFunctions::toString(item)}"
            }
        }
    end
end
