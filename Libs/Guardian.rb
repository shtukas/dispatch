
class Guardian
    # Guardian::guardianFeederUuid()
    def self.guardianFeederUuid()
        "085ca696dd8bd8db80a82160e88efcf35024eb01"
    end

    # Guardian::listingItems()
    def self.listingItems()
        item = Items::itemOrNull("085ca696dd8bd8db80a82160e88efcf35024eb01")
        return [] if NxFeeds::completionRatio(item) >= 1
        [item]
    end
end
