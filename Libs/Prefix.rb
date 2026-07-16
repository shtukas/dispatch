
class Prefix

    # Prefix::apply_children_ordering2(ordering_type, children)
    def self.apply_children_ordering2(ordering_type, children)
        if ordering_type == "distribution" then
            c1 = children
                    .map{|child|
                        {
                            "child" => child,
                            "ratio" => XCache::getOrNull("ceb929a4-605c-407c-9986-b44b835ac4df:#{child["uuid"]}")
                        }
                    }
                    .select{|packet| packet["ratio"] }
                    .sort_by{|packet|
                        BankDerivedData::recoveredAverageHoursPerDay(packet["child"]["uuid"])/packet["ratio"].to_f
                    }
                    .map{|packet| packet["child"] }
            c2 = children
                    .select{|child| XCache::getOrNull("ceb929a4-605c-407c-9986-b44b835ac4df:#{child["uuid"]}").nil? }
                    .sort_by {|child| child["global-pos-07"] || 0 }
            return c1 + c2
        end
        if ordering_type == "ordered-by-rt" then
            return children.sort_by{|child|
                BankDerivedData::recoveredAverageHoursPerDay(child["uuid"])
            }
        end
        if ordering_type == "ordered-by-gps-strict-sequence" then
            return children.sort_by{|child| child["global-pos-07"] || 0 }
        end
        if ordering_type == "ordered-by-gps-(1/2^n)-sequence" then
            children
                .sort_by{|child| child["global-pos-07"] || 0 }
                .map.with_index{|child, i|
                    {
                        "child" => child,
                        "multiplier" => 1 - 1.to_f/(2 ** i)
                    }
                }
                .sort_by{|packet|
                    puts packet
                    packet["multiplier"] * BankDerivedData::recoveredAverageHoursPerDay(packet["child"]["uuid"])
                }
        end
        if ordering_type == "indetermined" then
            return children
        end
        raise "(error: 305438a2) I do not know how to apply ordering_type: #{ordering_type}"
    end

    # Prefix::apply_children_ordering1(parent, children)
    def self.apply_children_ordering1(parent, children)
        if parent["mikuType"] == "NxRoot" then
            return Prefix::apply_children_ordering2(parent["orderingType"], children)
        end
        children
    end

    # Prefix::prefix(items) -> [children of first item recursively] + [item]
    def self.prefix(items)
        return [] if items.empty?
        firstItem = items[0]
        befores = Items::mikuType("NxBefore")
                    .select{|item| item["targetuuid"] == firstItem["uuid"] }
        if befores.size > 0 then
            return Prefix::prefix(befores + items)
        end
        children = Hierarchy::children(firstItem["uuid"])
        return items if children.empty?
        children = Prefix::apply_children_ordering1(firstItem, children)
        Prefix::prefix(children.take(6) + items)
    end
end
