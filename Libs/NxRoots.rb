class NxRoots

    # NxRoots::issueNew(description, orderingType, weeklyExpectation)
    def self.issueNew(description, orderingType, weeklyExpectation)
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "orderingType", orderingType)
        Items::setAttribute(uuid, "weeklyExpectation", weeklyExpectation)
        Items::setAttribute(uuid, "mikuType", "NxRoot")
        item = Items::itemOrNull(uuid)
        item
    end

    # ----------------------
    # Data

    # NxRoots::icon()
    def self.icon()
        "🏰"
    end

    # NxRoots::ratio(item)
    def self.ratio(item)
        dailyExpectation = item["weeklyExpectation"].to_f/5
        BankDerivedData::recoveredAverageHoursPerDay(item["uuid"]).to_f/dailyExpectation
    end

    # NxRoots::toString(item)
    def self.toString(item)
        dailyExpectation = item["weeklyExpectation"].to_f/5
        "#{NxRoots::icon()} #{item["description"]} (#{(NxRoots::ratio(item) * 100).round(1)} % of #{dailyExpectation.to_s.yellow} daily, #{item["weeklyExpectation"].to_s.yellow} weekly)"
    end

    # NxRoots::listingItems()
    def self.listingItems()
        Items::mikuType("NxRoot")
            .sort_by{|item| NxRoots::ratio(item) }
    end

    # NxRoots::interactivelySelectOneOrNull()
    def self.interactivelySelectOneOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("root", Items::mikuType("NxRoot"), lambda{|item| PolyFunctions::toString(item) })
    end

    # NxRoots::decideNewElementPositionOrNull(parent)
    def self.decideNewElementPositionOrNull(parent)
        children = Hierarchy::children(parent)
        children.each_with_index{|item, idx|
            puts "#{idx} #{PolyFunctions::toString(item)}"
        }
        option = LucilleCore::selectEntityFromListOfEntitiesOrNull("position", ["first", "after n", "last"])
        return if option.nil?
        if option == "first" then
            return GlobalPositioning::first_position() - 1
        end
        if option == "after n" then
            n = LucilleCore::askQuestionAnswerAsString("n: ").to_i

            children = children.take(n+2)
            children = children.map{|item|
                if item["global-pos-07"].nil? then
                    position = GlobalPositioning::last_position() + 1
                    item["global-pos-07"] = position
                    puts "setting position: #{position} for '#{PolyFunctions::toString(item).green}'"
                    Items::setAttribute(item["uuid"], "global-pos-07", position)
                end
                item
            }
            tail = children.drop(n)
            position = 0.5 * (tail[0]["global-pos-07"] + tail[1]["global-pos-07"])
            puts "decided position: #{position}".green
            return position
        end
        if option == "last" then
            return GlobalPositioning::last_position() + 1
        end
    end
end
