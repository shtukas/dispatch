class GlobalPositioning

    # GlobalPositioning::first_position()
    def self.first_position()
        ([1] + Items::items().map{|item| item["global-pos-07"] || 0 }).min
    end

    # GlobalPositioning::last_position()
    def self.last_position()
        ([1] + Items::items().map{|item| item["global-pos-07"] || 0 }).max
    end

    # GlobalPositioning::insert_first(item) # -> Item
    def self.insert_first(item)
        Items::setAttribute(item["uuid"], "global-pos-07", GlobalPositioning::first_position() - 1)
        Items::itemOrNull(item["uuid"])
    end

    # GlobalPositioning::insert_last(item)
    def self.insert_last(item)
        Items::setAttribute(item["uuid"], "global-pos-07", GlobalPositioning::last_position() + 1)
        Items::itemOrNull(item["uuid"])
    end

    # GlobalPositioning::decideNewElementPositionInParent(parent)
    def self.decideNewElementPositionInParent(parent)
        children = Hierarchy::childrenInOrder(parent).take(30)
        children.each_with_index{|item, idx|
            puts "#{idx} #{PolyFunctions::toString(item)}"
        }
        option = LucilleCore::selectEntityFromListOfEntitiesOrNull("position", ["first", "after n", "last"])
        if option.nil? then
            return GlobalPositioning::decideNewElementPositionInParent
        end
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
