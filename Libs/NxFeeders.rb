
class NxFeeders

    # NxFeeders::interactivelyIssueNewOrNull()
    def self.interactivelyIssueNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        return nil if description == ""
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "mikuType", "NxFeeder")
        item = Items::itemOrNull(uuid)
        item
    end

    # NxFeeders::toString(item)
    def self.toString(item)
        "🔺 #{item["description"]}"
    end

    # NxFeeders::interactivelySelectOneOrNull()
    def self.interactivelySelectOneOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("root", Items::mikuType("NxFeeder"), lambda {|item| item["description"] })
    end

    # NxFeeders::listingItems()
    def self.listingItems()
        Items::mikuType("NxFeeder").each{|item|
            if item["whours-04"].nil? then
                hours = LucilleCore::askQuestionAnswerAsString("weekly hours for '#{PolyFunctions::toString(item)}' : ").to_f
                if hours == 0 then
                    return NxFeeders::listingItems()
                end
                Items::setAttribute(item["uuid"], "whours-04", hours)
            end
        }
        Items::mikuType("NxFeeder")
            .sort_by{|item|
                BankDerivedData::recoveredAverageHoursPerDay(item["uuid"])/item["whours-04"]
            }
    end
end