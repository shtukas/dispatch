class NxFeeders

    # NxFeeders::interactivelyIssueNewOrNull()
    def self.interactivelyIssueNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        return nil if description == ""
        payload = UxPayloads::makeNewPayloadOrNull()
        puts "donation target:"
        donationuuid = Donations::interactivelySelectUuidOrNull()
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "payload-37", payload)
        Items::setAttribute(uuid, "donation-14", donationuuid)
        Items::setAttribute(uuid, "mikuType", "NxFeeder")
        item = Items::itemOrNull(uuid)
        item
    end

    # ----------------------
    # Data

    # NxFeeders::icon()
    def self.icon()
        "🔸"
    end

    # NxFeeders::toString(item)
    def self.toString(item)
        "#{NxFeeders::icon()} #{item["description"]}"
    end

    # NxFeeders::listingItems()
    def self.listingItems()
        if BankDerivedData::recoveredAverageHoursPerDay("NxFeeder-7c67-4c82-b17d-51ed175f7569") > 1 then
            return []
        end
        Items::mikuType("NxFeeder").sort_by{|item| item["unixtime"] }.take(1)
    end
end
