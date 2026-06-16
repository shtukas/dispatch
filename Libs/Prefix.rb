
class Prefix

    # Prefix::prefix(item) -> Array[Item]
    def self.prefix(item)
        Parenting::getChildrenInOrder(item["uuid"]).take(3) + [item]
    end
end
