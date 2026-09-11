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
        option = LucilleCore::selectEntityFromListOfEntitiesOrNull("position", ["first", "after n", "last"])
        return if option.nil?
        if option == "first" then
            return GlobalPositioning::first_position() - 1
        end
        if option == "after n" then
            n = LucilleCore::askQuestionAnswerAsString("n: ").to_i
            children = Hierarchy::children(parent)
            # First we need to ensure that the first n+1 elements
            # have a global-pos-07
            children = children.take(n+1)
            children = children.map{|item|
                if item["global-pos-07"].nil? then
                    position = GlobalPositioning::last_position() + 1
                    item["global-pos-07"] = position
                    puts "setting position: #{position} for '#{PolyFunctions::toString(item).green}'"
                    Items::setAttribute(item["uuid"], "global-pos-07", position)
                end
                item
            }
            tail = children.drop(n-1)
            position = 0.5 * (tail[0]["global-pos-07"] + tail[1]["global-pos-07"])
            puts "decided position: #{position}".green
            return position
        end
        if option == "last" then
            return nil
        end
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
            puts "todo | new | pile"
            input = LucilleCore::askQuestionAnswerAsString("> ")
            return if input == "exit"
            return if input == ""

            if input == "todo" or input == "new" then
                position = NxRoots::decideNewElementPositionOrNull(root)
                task = NxTasks::interactivelyIssueNewOrNull()
                Items::setAttribute(task["uuid"], "parentuuid", root["uuid"])
                Items::setAttribute(task["uuid"], "global-pos-07", position)
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

            if input == "pile" then
                text = CommonUtils::editTextSynchronously("").strip
                if text == "" then
                    next
                end
                text.lines.map {|line| line.strip }.reverse.each{|description|
                    task = NxTasks::interactivelyIssueNewLine(description)
                    Items::setAttribute(task["uuid"], "global-pos-07", GlobalPositioning::first_position() - 1)
                    Items::setAttribute(task["uuid"], "parentuuid", root["uuid"])
                }
                next
            end

            CommandsAndInterpreters::interpreter(input, store)
        }
    end
end
