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

    # NxRoots::dive_guardian()
    def self.dive_guardian()
        loop {
            root = Items::itemOrNull("3fc52f5b-706b-47ae-a540-eefc72e47b0b")
            children = Hierarchy::children(root)
            store = ItemStore.new()
            puts ""
            lines = FrontPage::toString2(store, root, false)
            lines.each{|line|
                puts line
            }
            children
                .each{|item|
                    lines = FrontPage::toString2(store, item, FrontPage::canBeDefault(item))
                    lines.each{|line|
                        puts line
                    }
                }
            puts "todo | new"
            input = LucilleCore::askQuestionAnswerAsString("> ")
            return if input == "exit"
            return if input == ""

            if input == "todo" or input == "new" then
                task = NxTasks::interactivelyIssueNewOrNull()
                Items::setAttribute(task["uuid"], "parentuuid", root["uuid"])
                next
            end

            if input == "sort" then
                items = children.sort_by{|item| item["global-pos-07"] || 0 }
                selected = CommonUtils::selectZeroOrMore(items, lambda {|item| PolyFunctions::toString(item) })
                selected.reverse.each{|item|
                    GlobalPositioning::insert_first(item)
                }
                next
            end

            CommandsAndInterpreters::interpreter(input, store)
        }
    end
end
