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

    # NxRoots::ratio(item)
    def self.ratio(item)
        dailyExpectation = item["weeklyExpectation"].to_f/5
        BankDerivedData::recoveredAverageHoursPerDay(item["uuid"]).to_f/dailyExpectation
    end

    # NxRoots::toString(item)
    def self.toString(item)
        dailyExpectation = item["weeklyExpectation"].to_f/5
        "#{NxRoots::icon()} #{item["description"]} (#{(NxRoots::ratio(item) * 100).round(1)} % of #{dailyExpectation.to_s.yellow} daily, #{item["weeklyExpectation"].to_s.yellow} weekly)"
    end

    # NxRoots::listingItems()
    def self.listingItems()
        Items::mikuType("NxRoot")
            .sort_by{|item| NxRoots::ratio(item) }
    end
end
