
class Donations

    # Donations::uuid_to_description_or_null_cache_results(uuid)
    def self.uuid_to_description_or_null_cache_results(uuid)
        description = XCache::getOrNull("00cc1ac4-1a63-437a-802b-8bcadbdb0fb5:#{uuid}:#{CommonUtils::today()}")
        return description if description
        item = Items::itemOrNull(uuid)
        return nil if item.nil?
        description = item["description"]
        XCache::set("00cc1ac4-1a63-437a-802b-8bcadbdb0fb5:#{uuid}:#{CommonUtils::today()}", description)
        description
    end

    # Donations::suffix(item)
    def self.suffix(item)
        return "" if item["donation-14"].nil?
        description = Donations::uuid_to_description_or_null_cache_results(item["donation-14"])
        return "" if description.nil?
        " (d: #{description})".yellow
    end

    # Donations::interactivelySelectUuidOrNull()
    def self.interactivelySelectUuidOrNull()
        target = LucilleCore::selectEntityFromListOfEntitiesOrNull("root", Items::mikuType("NxRoot"), lambda {|item| PolyFunctions::toString(item) })
        return nil if target.nil?
        target["uuid"]
    end

    # Donations::interactivelySetDonation(item) # -> item
    def self.interactivelySetDonation(item)
        uuid = Donations::interactivelySelectUuidOrNull()
        return item if uuid.nil?
        Items::setAttribute(item["uuid"], "donation-14", uuid)
        Items::itemOrNull(item["uuid"])
    end
end
