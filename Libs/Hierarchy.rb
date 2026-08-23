
class Hierarchy

    # Hierarchy::itemsForChildrenExtractions()
    def self.itemsForChildrenExtractions()
        Items::items()
    end

    # Hierarchy::children(item)
    def self.children(item)

        if item["uuid"] == "2a749cd4-a815-4e05-b7df-b0e468b60bdd" then
            # waves
            return Waves::listingItemsNonInterruption()
        end

        if item["uuid"] == "3fc52f5b-706b-47ae-a540-eefc72e47b0b" then
            # guardian open cycles
            return Guardian::projects().sort_by{|item| item["global-pos-07"] || 0 }
        end

        if item["uuid"] == "92cd40f9-2001-48fc-9e2b-51da20202049" then
            # infinity
            # We put in infinity the items that declare themselves in infinity and
            # those which are orphans
            return [
                Hierarchy::itemsForChildrenExtractions().select{|x| x["parentuuid"] == item["uuid"] },
                Hierarchy::itemsForChildrenExtractions().select{|x| x["parentuuid"].nil? },
            ]
                .flatten
                .sort_by{|item| item["global-pos-07"] || 0 }
        end

        if item["uuid"] == "ba965060-6358-40e9-b276-67dfe8ac63df" then
            # trading
            return []
        end

        if item["guardian-project"] then
            return Guardian::project_children(item)
        end

        Hierarchy::itemsForChildrenExtractions()
            .select{|x| x["parentuuid"] == item["uuid"] }
            .sort_by{|item| item["global-pos-07"] || 0 }
    end

    # Hierarchy::dive(parent)
    def self.dive(parent)
        if parent["uuid"] == "2a749cd4-a815-4e05-b7df-b0e468b60bdd" then
            # root: waves
            Operations::program3(lambda { 
                w1, w2 = Items::mikuType("Wave").partition{|item| DoNotShowUntil::isVisible(item) }
                [parent] + w2 + w1 # we put the done ones first
            })
            return
        end

        if parent["uuid"] == "3fc52f5b-706b-47ae-a540-eefc72e47b0b" then
            # root: guardian open cycles
            Operations::program3(lambda { 
                [parent] + Guardian::projects()
            })
            return
        end

        if parent["uuid"] == "92cd40f9-2001-48fc-9e2b-51da20202049" then
            # root: infinity
            Operations::program3(lambda { 
                [parent] + NxTasks::listingItems()
            })
            return
        end

        if parent["uuid"] == "ba965060-6358-40e9-b276-67dfe8ac63df" then
            # root: trading
            puts "We are not diving root:trading, please find the todo file"
            LucilleCore::pressEnterToContinue()
            return
        end

        loop {
            children = Hierarchy::children(parent).sort_by{|item| item["global-pos-07"] || 0 }
            store = ItemStore.new()
            puts ""
            store.register(parent, false)
            lines = FrontPage::toString2(store, parent)
            lines.each{|line|
                puts line
            }
            children
                .each{|child|
                    store.register(child, FrontPage::canBeDefault(child))
                    lines = FrontPage::toString2(store, child)
                    lines.each{|line|
                        puts line
                    }
                }
            puts ""
            input = LucilleCore::askQuestionAnswerAsString("> ")
            return if input == "exit"
            return if input == ""

            if input == "todo" or input == "new" then
                task = NxTasks::interactivelyIssueNewOrNull()
                Items::setAttribute(task["uuid"], "parentuuid", parent["uuid"])
                next
            end

            CommandsAndInterpreters::interpreter(input, store)
        }

        raise "(error: b326de46) I do not know how to dive item: #{parent}"
    end
end
