
class Prefix

    # Prefix::selection(parent, children)
    def self.selection(parent, children)
        if parent["uuid"] == NxRoots::infinityuuid() then # infinity
            return children.reduce([]) {|selection, item|
                if selection.size >= 6 then
                    selection
                else
                    if DoNotShowUntil::isVisible(item) then
                        selection + [item]
                    else
                        selection
                    end
                end
            }
        end
        children.select {|item| DoNotShowUntil::isVisible(item) }
    end

    # Prefix::decide_children(parent)
    def self.decide_children(parent)
        if parent["uuid"] == NxRoots::infinityuuid() then # infinity
            childrenuuids = XCache::getOrNull("faaf1f9a-600c-44fd-b938-2ce573d20ff0:#{CommonUtils::today()}")
            if childrenuuids then
                return JSON.parse(childrenuuids).map{|uuid| Items::itemOrNull(uuid) }.compact
            end
            children = Hierarchy::childrenInOrder(parent)
            childrenuuids = children.take(100).map{|item| item["uuid"] }
            XCache::set("faaf1f9a-600c-44fd-b938-2ce573d20ff0:#{CommonUtils::today()}", JSON.generate(childrenuuids))
            return children
        end
        Hierarchy::childrenInOrder(parent)
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
        return items if children.empty?
        Prefix::prefix(Prefix::selection(firstItem, children) + items)
    end
end
