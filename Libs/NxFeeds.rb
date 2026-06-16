
class NxFeeds

    # NxFeeds::interactivelyIssueNewOrNull()
    def self.interactivelyIssueNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        return nil if description == ""
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "mikuType", "NxFeed")
        item = Items::itemOrNull(uuid)
        item
    end

    # NxFeeds::toString(item)
    def self.toString(item)
        "🔺 #{item["description"]}"
    end

    # NxFeeds::interactivelySelectOneOrNull()
    def self.interactivelySelectOneOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("feed", Items::mikuType("NxFeed"), lambda {|item| item["description"] })
    end

    # NxFeeds::completionRatio(item)
    def self.completionRatio(item)
        BankDerivedData::recoveredAverageHoursPerDay(item["uuid"])/(item["whours-04"].to_f/7)
    end

    # NxFeeds::guardian_for_front_page()
    def self.guardian_for_front_page()
        item = Items::itemOrNull("085ca696dd8bd8db80a82160e88efcf35024eb01")
        return [] if item.nil?
        return [] if NxFeeds::completionRatio(item) >= 1
        [item]
    end

    # NxFeeds::listingItems()
    def self.listingItems()
        Items::mikuType("NxFeed").each{|item|
            if item["whours-04"].nil? then
                hours = LucilleCore::askQuestionAnswerAsString("weekly hours for '#{PolyFunctions::toString(item)}' : ").to_f
                if hours == 0 then
                    return NxFeeds::listingItems()
                end
                Items::setAttribute(item["uuid"], "whours-04", hours)
            end
        }
        Items::mikuType("NxFeed")
            .sort_by{|item| NxFeeds::completionRatio(item) }
    end
end