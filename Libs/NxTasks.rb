class NxTasks

    # NxTasks::interactivelyIssueNewOrNull()
    def self.interactivelyIssueNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        return nil if description == ""
        uuid = SecureRandom.uuid
        payload = UxPayloads::makeNewPayloadOrNull()
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "payload-37", payload)
        Items::setAttribute(uuid, "mikuType", "NxTask")
        item = Items::itemOrNull(uuid)
        item
    end

    # NxTasks::interactivelyIssueNewLine(description)
    def self.interactivelyIssueNewLine(description)
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "mikuType", "NxTask")
        item = Items::itemOrNull(uuid)
        item
    end

    # ----------------------
    # Data

    # NxTasks::icon()
    def self.icon()
        "🔹"
    end

    # NxTasks::toString(item)
    def self.toString(item)
        if item["guardian-project"] then
            return Guardian::projectToString(item)
        end
        if item["guardian-project-element"] then
            return Guardian::projectElementToString(item)
        end
        "#{NxTasks::icon()} #{item["description"]}"
    end

    # NxTasks::itemsInOrder()
    def self.itemsInOrder()
        Items::mikuType("NxTask")
            .sort_by{|item| item["global-pos-07"] || 0 }
    end

    # NxTasks::listingItems()
    def self.listingItems()
        NxTasks::itemsInOrder()
            .select{|item| DoNotShowUntil::isVisible(item) }
            .first(10)
    end

    # NxTasks::determineNewPosition()
    def self.determineNewPosition()
        items = NxTasks::itemsInOrder()
        loop {
            if items.size == 0 then
                return 1
            end
            if items.size < 10 then
                return (items.map{|item| item["global-pos-07"] || 0 }.max + 1)
            end
            average_consecutive_difference = lambda {|numbers|
                numbers.each_cons(2).sum { |a, b| b - a } / (numbers.size - 1).to_f
            }
            ten = items.take(10)
            numbers = ten.map{|item| item["global-pos-07"] || 0 }
            a = average_consecutive_difference.call(numbers)
            if a < 0.25 then
                items = items.drop(1)
                next
            end
            s1 = numbers.min
            s2 = numbers.max
            return s1 + rand * (s2 - s1)
        }
    end

    # NxTasks::markWithNewPosition(item)
    def self.markWithNewPosition(item)
        position = NxTasks::determineNewPosition()
        puts "new position: #{position}".yellow
        Items::setAttribute(item["uuid"], "global-pos-07", position)
        item["global-pos-07"] = position
        item
    end
end
