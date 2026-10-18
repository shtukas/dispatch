class NxDirectives

    # NxDirectives::interactivelyIssueNewOrNull()
    def self.interactivelyIssueNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        return nil if description == ""
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "mikuType", "NxDirective")
        item = Items::itemOrNull(uuid)
        item
    end

    # ----------------------
    # Data

    # NxDirectives::icon()
    def self.icon()
        "📍"
    end

    # NxDirectives::toString(item)
    def self.toString(item)
        "#{NxDirectives::icon()} #{item["description"]}"
    end

    # NxDirectives::listingItems()
    def self.listingItems()
        Items::mikuType("NxDirective")
    end
end
