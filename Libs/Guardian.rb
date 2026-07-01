
=begin

This is a virtual object, not presence in the item store
{
    "uuid"        : String
    "mikuType"    : "GuardianProject"
    "description" : String
    "location"    : String
}

=end

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

    # Guardian::guardianProjects()
    def self.guardianProjects()
        LucilleCore::locationsAtFolder("#{Config::pathToGalaxy()}/Open Cycles/2026-03-31 Guardian")
            .map{|location|
                uuid = Digest::SHA1.hexdigest("1d7bb7a1-a35a-4b39-b7bd-0087bfe4a476:#{location}")
                filename = File.basename(location)
                description = filename[11, filename.size()].strip
                {
                    "uuid" => uuid,
                    "mikuType" => "GuardianProject",
                    "description" => File.basename(location),
                    "location" => location,
                    "isFile" => File.file?(location)
                }
            }
    end

    # Guardian::identifyTodoFileInDirectory(parent)
    def self.identifyTodoFileInDirectory(parent)
        LucilleCore::locationsAtFolder(parent)
            .select{|location| location.include?("TODO.txt") }
            .first
    end

    # Guardian::projectToString(item)
    def self.projectToString(item)
        "👩🏻‍💻 #{item["description"]}"
    end
end
