
# The parenting class is generic, it allows any element to be the parent of any other
# but in the context of feeders, we only allow feeders to be parents and 
# children to be tasks.

class Parenting

    # Parenting::getChildren(parentuuid)
    def self.getChildren(parentuuid)
        if parentuuid == Guardian::guardianFeederUuid() then
            return Guardian::guardianProjects()
        end
        Items::items().select{|item| item["parenting-22"] == parentuuid }
    end

    # Parenting::getChildrenInOrder(parentuuid)
    def self.getChildrenInOrder(parentuuid)
        Parenting::getChildren(parentuuid)
            .sort_by{|item| item["global-pos-07"] }
    end

    # Parenting::dive(parent)
    def self.dive(parent)
        loop {
            children = Parenting::getChildrenInOrder(parent["uuid"])
            store = ItemStore.new()
            puts ""
            puts "#{PolyFunctions::toString(parent).green}"
            store.register(parent, FrontPage::canBeDefault(parent))
            puts FrontPage::toString2(store, parent)
            children
                .each{|item|
                    store.register(item, FrontPage::canBeDefault(item))
                    puts FrontPage::toString2(store, item)
                }
            puts ""
            puts "new | sort | move"
            input = LucilleCore::askQuestionAnswerAsString("> ")
            return if input == "exit"
            return if input == ""

            if input == "new" then
                item = NxTasks::interactivelyIssueNewOrNull(parent)
                next if item.nil?
                puts JSON.pretty_generate(item)
                next
            end

            if input == "sort" then
                selected = CommonUtils::selectZeroOrMore(children, lambda {|item| PolyFunctions::toString(item) })
                selected.reverse.each{|item|
                    GlobalPositioning::insert_first(item)
                }
                next
            end

            if input == "move" then
                selected = CommonUtils::selectZeroOrMore(children, lambda {|item| PolyFunctions::toString(item) })
                parent2 = Parenting::interactivelyRecursivelySelectParentOrNull(nil)
                selected.each{|item|
                    Items::setAttribute(item["uuid"], "parenting-22", parent2["uuid"])
                }
            end

            CommandsAndInterpreters::interpreter(input, store)
        }
    end

    # Parenting::interactivelyRecursivelySelectParentOrNull(context)
    def self.interactivelyRecursivelySelectParentOrNull(context)
        if context.nil? then
            root = NxFeeds::interactivelySelectOneOrNull()
            return nil if root.nil?
            return Parenting::interactivelyRecursivelySelectParentOrNull(root)
        end
        if Parenting::getChildren(context["uuid"]).empty? then
            return context
        end
        puts "context: #{PolyFunctions::toString(context).green}"
        option = LucilleCore::selectEntityFromListOfEntitiesOrNull("option", ["select context (default)", "dive context"])
        if option.nil? or option == "select context (default)" then
            return context
        end
        if option == "dive context" then
            children = Parenting::getChildren(context["uuid"])
            child = LucilleCore::selectEntityFromListOfEntitiesOrNull("item", children, lambda {|item| PolyFunctions::toString(item) })
            if child.nil? then
                return Parenting::interactivelyRecursivelySelectParentOrNull(context)
            end
            return Parenting::interactivelyRecursivelySelectParentOrNull(child)
        end
    end
end
