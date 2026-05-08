
class Cliques

    # Cliques::setClique(item, cliquename)
    def self.setClique(item, cliquename)
        Items::setAttribute(item["uuid"], "clique-13", cliquename)
    end

    # Cliques::getCliquenames()
    def self.getCliquenames()
        Items::mikuType("NxTask")
            .select{|item| item["clique-13"] }
            .map{|item| item["clique-13"] }
            .compact
            .uniq
            .sort
    end

    # Cliques::interactivelySelectCliqueNameOrNull()
    def self.interactivelySelectCliqueNameOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("clique", Cliques::getCliquenames())
    end

    # Cliques::architectCliqueNameOrNull()
    def self.architectCliqueNameOrNull()
        cliquename = Cliques::interactivelySelectCliqueNameOrNull()
        return cliquename if cliquename
        cliquename = LucilleCore::askQuestionAnswerAsString("clique name (empty for null): ")
        return cliquename if cliquename != ""
        nil
    end

    # Cliques::setCliqueAttempt(item)
    def self.setCliqueAttempt(item)
        cliquename = Cliques::architectCliqueNameOrNull()
        return if cliquename.nil?
        Cliques::setClique(item, cliquename)
    end

    # Cliques::dive(cliquename)
    def self.dive(cliquename)
        loop {
            items = Items::mikuType("NxTask")
                        .select{|item| item["engine-1437"].nil? }
                        .select{|item| item["clique-13"] == cliquename }
                        .sort_by {|item| item["global-pos-07"] || 0 }
            store = ItemStore.new()
            puts ""
            items
                .each{|item|
                    store.register(item, FrontPage::canBeDefault(item))
                    puts FrontPage::toString2(store, item)
                }
            puts "sort"
            input = LucilleCore::askQuestionAnswerAsString("> ")
            return if input == "exit"
            return if input == ""

            if input == "sort" then
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