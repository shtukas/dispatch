
class Prefix

    # Prefix::selection(parent, children)
    def self.selection(parent, children)
        if parent["uuid"] == "92cd40f9-2001-48fc-9e2b-51da20202049" then # infinity
            return children.take(6)
        end
        children
    end

    # Prefix::prefix(items) -> [children of first item recursively] + [item]
    def self.prefix(items)
        return [] if items.empty?
        firstItem = items[0]
        befores = Items::mikuType("NxBefore")
                    .select{|item| item["targetuuid"] == firstItem["uuid"] }
                    .select {|item| DoNotShowUntil::isVisible(item) }
        if befores.size > 0 then
            return Prefix::prefix(befores + items)
        end
        children = Hierarchy::children(firstItem)
                    .select {|item| DoNotShowUntil::isVisible(item) }
                    .sort_by{|item| item["global-pos-07"] || 0 }
        return items if children.empty?
        Prefix::prefix(Prefix::selection(firstItem, children) + items)
    end
end
