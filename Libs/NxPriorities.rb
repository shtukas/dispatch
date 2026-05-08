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
        item = GlobalPositioning::insert_first(item)
        item
    end

    # NxPriorities::issuePriorityDelegateOrNull(targetuuid)
    def self.issuePriorityDelegateOrNull(targetuuid)
        target = Items::itemOrNull(targetuuid)
        return nil if target.nil?
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", PolyFunctions::toString(target))
        Items::setAttribute(uuid, "targetuuid", targetuuid)
        Items::setAttribute(uuid, "mikuType", "NxPriority")
        item = Items::itemOrNull(uuid)
        item = GlobalPositioning::insert_first(item)
        item
    end

    # NxPriorities::itemHasPriorityDelegate(item)
    def self.itemHasPriorityDelegate(item)
        Items::mikuType("NxPriority")
            .any?{|item| item["targetuuid"] == item["uuid"] }
    end

    # NxPriorities::prioritise(item)
    def self.prioritise(item)
        return if item["mikuType"] == "NxPriority"
        NxPriorities::issuePriorityDelegateOrNull(item["uuid"])
    end

    # NxPriorities::prioritiseIfNotPriorityOrIdentity(item)
    def self.prioritiseIfNotPriorityOrIdentity(item)
        return item if item["mikuType"] == "NxPriority"
        NxPriorities::prioritise(item)
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
            .select{|item| DoNotShowUntil::isVisible(item) }
    end
end
