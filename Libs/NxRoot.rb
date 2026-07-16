class NxRoots

    # NxRoots::issueNew(description, orderingType, weeklyExpectation)
    def self.issueNew(description, orderingType, weeklyExpectation)
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "orderingType", orderingType)
        Items::setAttribute(uuid, "weeklyExpectation", weeklyExpectation)
        Items::setAttribute(uuid, "mikuType", "NxRoot")
        item = Items::itemOrNull(uuid)
        item
    end

    # ----------------------
    # Data

    # NxRoots::icon()
    def self.icon()
        "🏰"
    end

    # NxRoots::toString(item)
    def self.toString(item)
        "#{NxRoots::icon()} #{item["description"]} (#{item["weeklyExpectation"].to_s.yellow})"
    end

    # NxRoots::listingItems()
    def self.listingItems()
        Items::mikuType("NxRoot")
    end
end
