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

    # NxDirectories::childrenCountForDisplay(parent)
    def self.childrenCountForDisplay(parent)
        data = XCache::getOrNull("8101b709-f7a5-4d05-a1f3-2c537eb5ee76:#{parent["uuid"]}")
        if data then
            data = JSON.parse(data)
            if (Time.new.to_i - data["unixtime"]) < 86400 then
                return data["count"]
            end
        end
        count = Hierarchy::childrenInOrder(parent).size
        data = { "count" => count, "unixtime" => Time.new.to_i }
        XCache::set("8101b709-f7a5-4d05-a1f3-2c537eb5ee76:#{parent["uuid"]}", JSON.generate(data))
        count
    end

    # NxDirectories::toString(item)
    def self.toString(item)
        "#{NxDirectories::icon()} #{item["description"]} (#{NxDirectories::childrenCountForDisplay(item)})"
    end

    # NxDirectories::getDirectoryByDescriptionOrNull(description)
    def self.getDirectoryByDescriptionOrNull(description)
        Items::mikuType("NxFloat").select{|item| item["description"] == description }
    end
end
