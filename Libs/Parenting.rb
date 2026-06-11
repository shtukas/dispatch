
class Parenting

    # Parenting::getChildren(parentuuid)
    def self.getChildren(parentuuid)
        Items::items().select{|item| item["parenting-22"] == parentuuid }
    end

    # Parenting::dive(parent)
    def self.dive(parent)
        loop {
            children = Parenting::getChildren(parent["uuid"])
                        .sort_by{|item| item["global-pos-07"] }
            store = ItemStore.new()
            puts ""
            puts "-> #{PolyFunctions::toString(parent).green}"
            children
                .each{|item|
                    store.register(item, FrontPage::canBeDefault(item))
                    puts FrontPage::toString2(store, item)
                }
            puts ""
            puts "new | sort"
            input = LucilleCore::askQuestionAnswerAsString("> ")
            return if input == "exit"
            return if input == ""

            if input == "new" then
                
                next
            end

            if input == "sort" then
                selected = CommonUtils::selectZeroOrMore(children, lambda {|item| PolyFunctions::toString(item) })
                selected.reverse.each{|item|
                    GlobalPositioning::insert_first(item)
                }
                next
            end

            CommandsAndInterpreters::interpreter(input, store)
        }
    end

    # Parenting::interactivelyRecursivelySelectParentOrNull(context)
    def self.interactivelyRecursivelySelectParentOrNull(context)
        if context.nil? then
            root = NxRoots::interactivelySelectOneOrNull()
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
