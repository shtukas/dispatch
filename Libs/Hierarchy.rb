
class Hierarchy

    # Hierarchy::children(parent)
    def self.children(parent)

        if parent["uuid"] == "2a749cd4-a815-4e05-b7df-b0e468b60bdd" then
            # waves
            return Waves::listingItemsNonInterruption()
        end

        if parent["uuid"] == "92cd40f9-2001-48fc-9e2b-51da20202049" then
            # infinity
            # We put in infinity the items that declare themselves in infinity and
            # those which are orphans
            return [
                Items::items().select{|x| x["parentuuid"] == parent["uuid"] },
                Items::items().select{|x| x["parentuuid"].nil? },
            ]
                .flatten
                .sort_by{|item| item["global-pos-07"] || 0 }
        end

        items = Items::items()
            .select{|x| x["parentuuid"] == parent["uuid"] }

        i1, i2 = items.partition{|item| item["global-pos-07"] }
        i1.sort_by{|item| item["global-pos-07"] } + i2
    end

    # Hierarchy::childrenForDive(parent)
    def self.childrenForDive(parent)
        if parent["uuid"] == "92cd40f9-2001-48fc-9e2b-51da20202049" then
            # root: infinity
            return NxTasks::itemsInOrder().first(30)
        end
        Hierarchy::children(parent)
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

        loop {
            store = ItemStore.new()
            puts ""
            lines = FrontPage::toString2(store, parent, false)
            lines.each{|line|
                puts line
            }
            children = Hierarchy::childrenForDive(parent)
            children
                .each{|child|
                    lines = FrontPage::toString2(store, child, FrontPage::canBeDefault(child))
                    lines.each{|line|
                        puts line
                    }
                }
            puts "todo | new | pile | sort"
            input = LucilleCore::askQuestionAnswerAsString("> ")
            return if input == "exit"
            return if input == ""

            if input == "todo" or input == "new" then
                task = NxTasks::interactivelyIssueNewOrNull()
                Items::setAttribute(task["uuid"], "parentuuid", parent["uuid"])
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
                    Items::setAttribute(task["uuid"], "parentuuid", parent["uuid"])
                }
                next
            end

            CommandsAndInterpreters::interpreter(input, store)
        }

        raise "(error: b326de46) I do not know how to dive item: #{parent}"
    end
end
