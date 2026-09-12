class NxDirectories

    # NxDirectories::interactivelyIssueNewOrNull()
    def self.interactivelyIssueNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        return nil if description == ""
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "mikuType", "NxDirectory")
        item = Items::itemOrNull(uuid)
        item
    end

    # NxDirectories::issueNew(description)
    def self.issueNew(description)
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "mikuType", "NxDirectory")
        item = Items::itemOrNull(uuid)
        item
    end

    # ----------------------
    # Data

    # NxDirectories::icon()
    def self.icon()
        "📂"
    end

    # NxDirectories::toString(item)
    def self.toString(item)
        "#{NxDirectories::icon()} #{item["description"]}"
    end

    # NxDirectories::getDirectoryByDescriptionOrNull(description)
    def self.getDirectoryByDescriptionOrNull(description)
        Items::mikuType("NxFloat").select{|item| item["description"] == description }
    end
end
