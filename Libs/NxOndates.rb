
class NxOndates

    # NxOndates::interactivelyIssueNewOrNull()
    def self.interactivelyIssueNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        return nil if description == ""
        date = CommonUtils::interactivelyMakeADate()
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "date", date)
        Items::setAttribute(uuid, "payload-37", UxPayloads::makeNewPayloadOrNull())
        Items::setAttribute(uuid, "mikuType", "NxOndate")
        item = Items::itemOrNull(uuid)
        item
    end

    # NxOndates::interactivelyIssueNewWithDetails(description, date)
    def self.interactivelyIssueNewWithDetails(description, date)
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "date", date)
        Items::setAttribute(uuid, "payload-37", UxPayloads::makeNewPayloadOrNull())
        Items::setAttribute(uuid, "mikuType", "NxOndate")
        if date == CommonUtils::today() then
            Items::setAttribute(uuid, "priority-48", CommonUtils::today())
        end
        item = Items::itemOrNull(uuid)
        item
    end

    # NxOndates::icon(item)
    def self.icon(item)
        "🗓️ "
    end

    # NxOndates::toString(item)
    def self.toString(item)
        "#{NxOndates::icon(item)} [#{item["date"]}] #{item["description"]}"
    end

    # NxOndates::listingItems()
    def self.listingItems()
        Items::mikuType("NxOndate")
            .select{|item| item["date"] <= CommonUtils::today() }
    end

    # NxOndates::todayPriorities()
    def self.todayPriorities()
        NxOndates::listingItems()
            .select{|item| item["priority-48"] == CommonUtils::today() }
    end

    # NxOndates::selectAndMarkPrioritiesForToday()
    def self.selectAndMarkPrioritiesForToday()
        items = NxOndates::listingItems()
        selected = CommonUtils::selectZeroOrMore(items, lambda {|item| PolyFunctions::toString(item) })
        selected.each{|item|
            Items::setAttribute(item["uuid"], "priority-48", CommonUtils::today())
        }
    end
end
