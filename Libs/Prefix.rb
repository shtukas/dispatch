
class Prefix

    # Prefix::selection(parent, children)
    def self.selection(parent, children)
        if parent["uuid"] == "92cd40f9-2001-48fc-9e2b-51da20202049" then # infinity
            return children.take(6)
        end
        children
    end

    # Prefix::decide_children(parent)
    def self.decide_children(parent)
        if parent["uuid"] == "92cd40f9-2001-48fc-9e2b-51da20202049" then # infinity
            children = XCache::getOrNull("dbde5dbd6ccc:#{CommonUtils::today()}")
            if children then
                children = JSON.parse(children)
                children = children.select{|item| Items::itemOrNull(item["uuid"]) }
                return children
            end
            children = Hierarchy::children(parent)
            children = children.take(100)
            XCache::set("dbde5dbd6ccc:#{CommonUtils::today()}", JSON.generate(children))
            return children
        end
        Hierarchy::children(parent)
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
        children = Prefix::decide_children(firstItem)
                    .select {|item| DoNotShowUntil::isVisible(item) }
        return items if children.empty?
        Prefix::prefix(Prefix::selection(firstItem, children) + items)
    end
end
