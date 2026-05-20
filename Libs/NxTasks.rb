class NxTasks

    # NxTasks::interactivelyIssueNewOrNull(clique)
    def self.interactivelyIssueNewOrNull(clique)
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        return nil if description == ""
        uuid = SecureRandom.uuid
        payload = UxPayloads::makeNewPayloadOrNull()
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "payload-37", payload)
        Items::setAttribute(uuid, "clique-0928", clique)
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
        cliquesuffix = ""
        if item["clique-13"] then
            cliquesuffix = " [#{item["clique-13"]}]"
        end
        "#{NxTasks::icon()} #{item["description"]}#{cliquesuffix}"
    end
end
