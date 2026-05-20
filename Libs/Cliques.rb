
class Cliques

    # Cliques::orphanClique()
    def self.orphanClique()
        {
            "uuid"        => "22e79bb3-f30b-4f48-9b8e-2826bab1df71",
            "mikuType"    => "NxClique",
            "description" => "orphan tasks"
        }
    end

    # Cliques::getDistinctCliques()
    def self.getDistinctCliques()
        Items::mikuType("NxTask").reduce([]){|cliques, item|
            known_clique_uuids = cliques.map{|clique| clique["uuid"] }
            if known_clique_uuids.include?(item["clique-0928"]["uuid"]) then
                cliques
            else
                cliques + [item["clique-0928"]]
            end
        }
    end

    # Cliques::interactivelySelectOneCliqueOrNull()
    def self.interactivelySelectOneCliqueOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("clique", Cliques::getDistinctCliques(), lambda {|clique| clique["description"] })
    end

    # Cliques::architectCliqueOrNull()
    def self.architectCliqueOrNull()
        clique = Cliques::interactivelySelectOneCliqueOrNull()
        return clique if clique
        cliquename = LucilleCore::askQuestionAnswerAsString("new clique description (empty for null clique): ")
        if cliquename then
            return {
                "uuid"        => SecureRandom.hex,
                "mikuType"    => "NxClique",
                "description" => cliquename
            }
        end
        nil
    end

    # Cliques::architectClique()
    def self.architectClique()
        loop {
            clique = Cliques::architectCliqueOrNull()
            return clique if clique
        }
    end

    # Cliques::getCliqueItems(clique)
    def self.getCliqueItems(clique)
        Items::mikuType("NxTask")
            .select{|item| item["clique-0928"]["uuid"] == clique["uuid"] }
            .sort_by {|item| item["global-pos-07"] || 0 }
    end

    # Cliques::diveClique(clique)
    def self.diveClique(clique)
        loop {
            items = Cliques::getCliqueItems(clique)
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

    # Cliques::listingItems()
    def self.listingItems()
        Cliques::getDistinctCliques()
    end
end