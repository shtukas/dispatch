
class OrderingTypes
    # OrderingTypes::orderingTypes()
    def self.orderingTypes()
        [
            "ordered-by-gps-strict-sequence",
            "ordered-by-gps-(1/2^n)-sequence",
            "ordered-by-rt",
            "distribution",
            "indetermined"
        ]
    end

    # OrderingTypes::interactivelySelectOrderingType()
    def self.interactivelySelectOrderingType()
        LucilleCore::selectEntityFromListOfEntities_EnsureChoice("listing style", OrderingTypes::orderingTypes())
    end

    # OrderingTypes::orderingDirectiveSuffix(item)
    def self.orderingDirectiveSuffix(item)
        directive = XCache::getOrNull("5f7d92de-4254-4777-a02f-3887207a57d8:#{item["uuid"]}")
        return "" if directive.nil?
        directive = JSON.parse(directive)
        " (#{directive["type"]})".green
    end
end