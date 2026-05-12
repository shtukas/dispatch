
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

    # NxOndates::listingItemsTodayAbsolute()
    def self.listingItemsTodayAbsolute()
        if Config::isPrimaryInstance() then
            if CommonUtils::today() != XCache::getOrNull("e61c25ae-3139-4ad7-8cc4-0b1142d4a6c9") and Time.new.hour >= 6 then
                puts "ondates daily structuration"
                items = Items::mikuType("NxOndate").select{|item| item["date"] <= CommonUtils::today() }
                # We have not yet selected absolutes for today
                selection_behaviour = lambda {|item|
                    puts ""
                    option = LucilleCore::selectEntityFromListOfEntitiesOrNull("option", ["transmute to priority item", "today absolute (default)", "today not important", "tomorrow", "ondate", "done"])
                    if option == "transmute to priority item" then
                        Transmute::transmuteTo(item, "NxPriority")
                        return nil
                    end
                    if option.nil? or option == "today absolute (default)" then
                        item["today-absolute"] = CommonUtils::today()
                        Items::setAttribute(item["uuid"], "today-absolute", CommonUtils::today())
                        return item
                    end
                    if option == "today not important" then
                        return item
                    end
                    if option == "tomorrow" then
                        Operations::dismiss(item)
                        return nil
                    end
                    if option == "ondate" then
                        date = CommonUtils::interactivelyMakeADate()
                        Items::setAttribute(item["uuid"], "date", date)
                        return nil
                    end
                    if option == "done" then
                        Items::deleteItem(item["uuid"])
                        return nil
                    end
                }
                selected = CommonUtils::selectZeroOrMoreWithSelectionBehavior(items, lambda {|item| PolyFunctions::toString(item) }, selection_behaviour)
                selected.each{|item|
                    Items::setAttribute(item["uuid"], "today-absolute", CommonUtils::today())
                }
                XCache::set("e61c25ae-3139-4ad7-8cc4-0b1142d4a6c9", CommonUtils::today())
            end
        end
        Items::mikuType("NxOndate")
            .select{|item| item["date"] <= CommonUtils::today() }
            .select{|item| item["today-absolute"] == CommonUtils::today() }
    end

    # NxOndates::listingItemsTail()
    def self.listingItemsTail()
        Items::mikuType("NxOndate")
            .select{|item| item["date"] <= CommonUtils::today() }
            .select{|item| item["today-absolute"] != CommonUtils::today() }
    end
end
