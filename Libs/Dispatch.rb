
class Dispatch

    # Dispatch::deadlineUnixtimeOrNull()
    def self.deadlineUnixtimeOrNull()
        if Time.new.hour < 11 then
            return DateTime.parse("#{CommonUtils::today()}T12:00:00Z").to_time.to_i
        end

        if Time.new.hour < 16 then
            return DateTime.parse("#{CommonUtils::today()}T18:00:00Z").to_time.to_i
        end

        if Time.new.hour >= 21 then
            return nil
        end

        DateTime.parse("#{CommonUtils::today()}T21:00:00Z").to_time.to_i
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

    # Dispatch::timeToNextDeadlineInSecondsOrNull()
    def self.timeToNextDeadlineInSecondsOrNull()
        deadline = Dispatch::deadlineUnixtimeOrNull()
        return nil if deadline.nil?
        deadline - Time.new.to_i
    end

    # Dispatch::computeSequenceLengthInSeconds(sequence)
    def self.computeSequenceLengthInSeconds(sequence)
        sequence.map{|item| Dispatch::item_to_timespan(item) }.sum
    end

    # Dispatch::splitTodayForCurrentTime(today)
    def self.splitTodayForCurrentTime(today)
        hour = Time.new.hour
        if hour >= 18 then
            return [today, []]
        end
        ratio = hour.to_f/18
        today.partition{|item| item["random"] < ratio }
    end

    # Dispatch::dispatch(head, lucky1, today, tail)
    def self.dispatch(head, lucky1, today, tail)
        # first we ensure that each today has a random value
        today = today.map{|item|
            if item["random"].nil? then
                value = rand
                Items::setAttribute(item["uuid"], "random", rand)
                item["random"] = value
            end
            item
        }

        # This function return the sequence made using the largest lucky1,
        # makes it so that lucky + today1 meets the next deadline

        if Time.new.hour >= 22 and today.size > 0 then
            puts "it's past 10pm and you haven't done a certain amount of todays, let's review and decide to dismiss"
            today.clone().each {|item|
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
            }
            return head + lucky1 + tail
        end

        if tail.empty? then
            return head + lucky1 + today + tail
        end

        timeToDeadlineInSeconds = Dispatch::timeToNextDeadlineInSecondsOrNull()
        if timeToDeadlineInSeconds.nil? then
            return head + lucky1 + today + tail
        end

        today1, today2 = Dispatch::splitTodayForCurrentTime(today)

        if Dispatch::computeSequenceLengthInSeconds(head + lucky1 + tail.take(1) + today1) < timeToDeadlineInSeconds then
            return Dispatch::dispatch(head, lucky1 + tail.take(1), today1, tail.drop(1) + today2)
        end

        return head + lucky1 + today1 + tail + today2
    end
end
