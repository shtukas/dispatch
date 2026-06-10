
class Dispatch

    # Dispatch::deadlineUnixtimeOrNull()
    def self.deadlineUnixtimeOrNull()
        ["09", "15", "21"]
            .map{|hour|
                DateTime.parse("#{CommonUtils::today()} #{hour}:00:00 +#{CommonUtils::getLocalTimeZone()}").to_time.to_i
            }
            .select{|unixtime| unixtime > Time.new.to_i }
            .min
    end

    # Dispatch::deadlineAsStringOrNull()
    def self.deadlineAsStringOrNull()
        deadline = Dispatch::deadlineUnixtimeOrNull()
        return nil if deadline.nil?
        "[#{Time.at(deadline).to_s[11, 5]}]"
    end

    # Dispatch::item_to_timespan_in_seconds(item)
    def self.item_to_timespan_in_seconds(item)

        if item["engine-1437"] then
            return NxEngines::missing_timespan_for_today(item)
        end

        if item["mikuType"] == "NxEngineDelegate" then
            return item["capacity"] - Bank::getValue(item["uuid"])
        end

        if item["mikuType"] == "NxPriority" and item["targetuuid"] then
            target = Items::itemOrNull(item["targetuuid"])
            if target then
                return Dispatch::item_to_timespan_in_seconds(target)
            end
        end

        if item["mikuType"] == "NxNxOndate" then
            return 3600
        end

        600 # default
    end

    # Dispatch::timespanToNextDeadlineInSecondsOrNull()
    def self.timespanToNextDeadlineInSecondsOrNull()
        deadline = Dispatch::deadlineUnixtimeOrNull()
        return nil if deadline.nil?
        deadline - Time.new.to_i
    end

    # Dispatch::sequenceToTimespanInSeconds(sequence)
    def self.sequenceToTimespanInSeconds(sequence)
        sequence.map{|item| Dispatch::item_to_timespan_in_seconds(item) }.sum
    end

    # Dispatch::core(head, lucky, today, tail)
    def self.core(head, lucky, today, tail)
        # This function return the sequence made using the largest lucky,
        # makes it so that lucky + today1 meets the next deadline

        if tail.empty? then
            return {
                "head"  => head,
                "lucky" => lucky,
                "today" => today,
                "tail"  => tail,
            }
        end

        timespan_to_deadline = Dispatch::timespanToNextDeadlineInSecondsOrNull()

        if timespan_to_deadline.nil? then
            if XCache::getOrNull("172cd807-2969-480a-8bd8-184f227e6b5d:#{CommonUtils::today()}") != "done" then
                puts "I do not have a dispatch deadline, which I interpret as the end of the day is nearing"
                puts "We need to review your remaining today items"
                today.each{|item|
                    next if item["mikuType"] == "NxEngineDelegate"
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
                "head"  => head,
                "lucky" => lucky,
                "today" => [],
                "tail"  => tail,
            }
        end

        if Dispatch::sequenceToTimespanInSeconds(head + lucky + tail.take(1) + today) <= timespan_to_deadline then
            return Dispatch::core(head, lucky + tail.take(1), today, tail.drop(1))
        end

        {
            "head"  => head,
            "lucky" => lucky,
            "today" => today,
            "tail"  => tail,
        }
    end

    # Dispatch::dispatch(head, lucky, today, tail)
    def self.dispatch(head, lucky, today, tail)
        data = Dispatch::core(head, lucky, today, tail)
        data["head"] + data["lucky"] + data["today"] + data["tail"]
    end

    # Dispatch::printBreakdown()
    def self.printBreakdown()
        data = Dispatch::core(FrontPage::prioritized(), [], FrontPage::today(), FrontPage::tail())
        ["head", "lucky", "today", "tail"].each{|label|
            puts "#{label} (#{data[label].size} items):"
            data[label].each{|item|
                puts "   - #{PolyFunctions::toString(item)}"
            }
        }
    end
end
