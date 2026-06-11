class NxTasks

    # NxTasks::interactivelyIssueNewOrNull(parent)
    def self.interactivelyIssueNewOrNull(parent)
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        return nil if description == ""
        uuid = SecureRandom.uuid
        payload = UxPayloads::makeNewPayloadOrNull()
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "payload-37", payload)
        Items::setAttribute(uuid, "parenting-22", parent["uuid"])
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
        parent = Items::itemOrNull(item["parenting-22"])
        pa = "(#{parent["description"]})".yellow
        "#{NxTasks::icon()} #{item["description"]} #{pa}"
    end
end
