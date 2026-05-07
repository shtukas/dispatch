class NxPriorities

    # NxPriorities::issueNew(description)
    def self.issueNew(description)
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "mikuType", "NxPriority")
        item = Items::itemOrNull(uuid)
        item
    end

    # ----------------------
    # Data

    # NxPriorities::toString(item)
    def self.toString(item)
        "🔥 #{item["description"]}"
    end

    # NxPriorities::itemsInGlobalPositioningOrder()
    def self.itemsInGlobalPositioningOrder()
        Items::mikuType("NxPriority")
            .sort_by{|item| item["global-pos-07"] || 0 }
    end

    # NxPriorities::listingItems()
    def self.listingItems()
        NxPriorities::itemsInGlobalPositioningOrder()
    end
end
