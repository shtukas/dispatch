
class Donations

    # Donations::suffix(item)
    def self.suffix(item)
        return "" if item["donation-14"].nil?
        description = Donations::donationIdToDescriptionOrNull(item["donation-14"])
        return "" if description.nil?
        " (d: #{description})".yellow
    end

    # Donations::donationIdToDescriptionOrNull(donationid)
    def self.donationIdToDescriptionOrNull(donationid)
        if donationid == Guardian::rootuuid() then
            return "guardian"
        end
        target = PolyFunctions::uuid_to_item_or_null_cache_results(donationid)
        if target then
            return target["description"]
        end
        nil
    end

    # Donations::interactivelySelectUuidOrNull()
    def self.interactivelySelectUuidOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("feed", [Guardian::rootuuid()], lambda {|item| "GuardianRoot" })
    end

    # Donations::interactivelySetDonation(item) # -> item
    def self.interactivelySetDonation(item)
        uuid = Donations::interactivelySelectUuidOrNull()
        return item if uuid.nil?
        Items::setAttribute(item["uuid"], "donation-14", uuid)
        Items::itemOrNull(item["uuid"])
    end
end
