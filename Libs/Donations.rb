
class Donations

    # Donations::suffix(item)
    def self.suffix(item)
        return "" if item["donation-14"].nil?
        target = PolyFunctions::uuid_to_item_or_null_cache_results(item["donation-14"])
        return "" if target.nil?
        " (d: #{target["description"]})".yellow
    end

    # Donations::interactivelySelectUuidOrNull()
    def self.interactivelySelectUuidOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("root", Items::mikuType("NxRoot"), lambda {|item| PolyFunctions::toString(item) })
    end

    # Donations::interactivelySetDonation(item) # -> item
    def self.interactivelySetDonation(item)
        uuid = Donations::interactivelySelectUuidOrNull()
        return item if uuid.nil?
        Items::setAttribute(item["uuid"], "donation-14", uuid)
        Items::itemOrNull(item["uuid"])
    end
end
