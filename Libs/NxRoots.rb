
class NxRoots

    # NxRoots::interactivelyIssueNewOrNull()
    def self.interactivelyIssueNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        return nil if description == ""
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "mikuType", "NxRoot")
        item = Items::itemOrNull(uuid)
        item
    end

    # NxRoots::toString(item)
    def self.toString(item)
        "🫜 #{item["description"]}"
    end

    # NxRoots::interactivelySelectOneOrNull()
    def self.interactivelySelectOneOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("root", Items::mikuType("NxRoot"), lambda {|item| item["description"] })
    end

    # NxRoots::listingItems()
    def self.listingItems()
        Items::mikuType("NxRoot")
    end
end