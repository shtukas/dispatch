
class Prefix

    # Prefix::function1(rt, ratio)
    def self.function1(rt, ratio)
        return nil if ratio.nil?
        return nil if ratio == 0
        rt/ratio
    end

    # Prefix::apply_order(ordering_directive, children)
    def self.apply_order(ordering_directive, children)
        if ordering_directive["type"] == "distribution" then
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
        if ordering_directive["type"] == "ordered-by-rt" then
            return children.sort_by{|child|
                BankDerivedData::recoveredAverageHoursPerDay(child["uuid"])
            }
        end
        if ordering_directive["type"] == "ordered-by-gps-strict-sequence" then
            return children.sort_by{|child|
                child["global-pos-07"] || 0
            }
        end
        if ordering_directive["type"] == "ordered-by-gps-(1/2^n)-sequence" then
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
        raise "(error: 305438a2) I do not know how to apply ordering_directive: #{ordering_directive}"
    end

    # Prefix::prefix(items) -> [children of first item recursively] + [item]
    def self.prefix(items)
        return [] if items.empty?
        children = Hierarchy::children(items[0]["uuid"])
        return items if children.empty?
        ordering_directive = Hierarchy::retrieveOrArchitechParentChildrenOrderingDirective(items[0])
        items = Prefix::apply_order(ordering_directive, children) + items
        Prefix::prefix(items)
    end
end
