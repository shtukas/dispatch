
class Dispatch

    # Dispatch::deadlineUnixtime()
    def self.deadlineUnixtime()
        if Time.new.hour <= 18 then
            unixtime_at_limit = DateTime.parse("#{CommonUtils::today()}T18:00:00Z").to_time.to_i
            unixtime_now = Time.new.to_i
            return 0.5 * unixtime_now + 0.5 * unixtime_at_limit
        end
        if Time.new.hour <= 21 then
            unixtime_at_limit = DateTime.parse("#{CommonUtils::today()}T21:00:00Z").to_time.to_i
            unixtime_now = Time.new.to_i
            return 0.5 * unixtime_now + 0.5 * unixtime_at_limit
        end
        unixtime_at_limit = CommonUtils::unixtimeAtComingMidnightAtLocalTimezone()
        unixtime_now = Time.new.to_i
        0.5 * unixtime_now + 0.5 * unixtime_at_limit
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

    # -------------------------------------

    # Dispatch::timespanToNextDeadlineInSeconds()
    def self.timespanToNextDeadlineInSeconds()
        Dispatch::deadlineUnixtime() - Time.new.to_i
    end

    # Dispatch::computeSequenceLengthInSeconds(sequence)
    def self.computeSequenceLengthInSeconds(sequence)
        sequence.map{|item| Dispatch::item_to_timespan(item) }.sum
    end

    # Dispatch::core(head, lucky, today, tail)
    def self.core(head, lucky, today, tail)
        # This function return the sequence made using the largest lucky,
        # makes it so that lucky + today1 meets the next deadline

        if tail.empty? then
            return {
                "head" => head,
                "lucky" => lucky,
                "today" => today,
                "tail" => tail
            }
        end

        if Time.new.hour >= 20 and !XCache::getFlag("5873d84c-0235-4e22-afa4-e2010fe153f2:#{CommonUtils::today()}") then
            today = today
                .map {|item|
                    (lambda {|item|
                        puts ""
                        puts PolyFunctions::toString(item).green
                        option = LucilleCore::selectEntityFromListOfEntitiesOrNull("option", ["tomorrow (default)", "ondate", "done"])
                        if option.nil? or option == "tomorrow (default)" then
                            Operations::dismiss(item)
                            next
                        end
                        if option == "ondate" then
                            date = CommonUtils::interactivelyMakeADate()
                            Items::setAttribute(item["uuid"], "date", date)
                            next
                        end
                        if option == "done" then
                            Items::deleteItem(item["uuid"])
                            next
                        end
                    }).call(item)
                }.compact
            XCache::setFlag("5873d84c-0235-4e22-afa4-e2010fe153f2:#{CommonUtils::today()}", true)
        end

        if Dispatch::computeSequenceLengthInSeconds(head + lucky + tail.take(1) + today) <= Dispatch::timespanToNextDeadlineInSeconds() then
            return Dispatch::core(head, lucky + tail.take(1), today, tail.drop(1))
        end

        {
            "head"  => head,
            "lucky" => lucky,
            "today" => today,
            "tail"  => tail
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
            puts "#{label}:"
            data[label].each{|item|
                puts "   - #{PolyFunctions::toString(item)}"
            }
        }
    end
end
