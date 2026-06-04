class NxFloats

    # NxFloats::interactivelyIssueNewOrNull()
    def self.interactivelyIssueNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        return nil if description == ""
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "mikuType", "NxFloat")
        item = Items::itemOrNull(uuid)
        item
    end

    # ----------------------
    # Data

    # NxFloats::icon()
    def self.icon()
        "🔺"
    end

    # NxFloats::toString(item)
    def self.toString(item)
        "#{NxFloats::icon()} #{item["description"]}"
    end

    # NxFloats::listingItems()
    def self.listingItems()
        Items::mikuType("NxFloat")
    end
end
