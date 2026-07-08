
=begin

GuardianRoot (virtual object)
{
    "uuid"        : String
    "mikuType"    : "GuardianRoot"
}

GuardianProject (virtual object)
{
    "uuid"        : String
    "mikuType"    : "GuardianProject"
    "description" : String
    "location"    : String
}

=end

class Guardian

    # Guardian::rootuuid()
    def self.rootuuid()
        "085ca696dd8bd8db80a82160e88efcf35024eb01"
    end

    # Guardian::guardianRootItem()
    def self.guardianRootItem()
        {
            "uuid"        => Guardian::rootuuid(),
            "mikuType"    => "GuardianRoot",
            "unixtime"    => Time.new.to_i,
            "description" => "Guardian"
        }
    end

    # Guardian::rootAsString()
    def self.rootAsString()
        "👩🏻‍💻 Guardian"
    end

    # Guardian::listingItems()
    def self.listingItems()
        return [] if BankDerivedData::recoveredAverageHoursPerDay(Guardian::rootuuid()) > 5
        [Guardian::guardianRootItem()]
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
                    "unixtime" => File.mtime(location).to_i,
                    "description" => File.basename(location),
                    "location" => location,
                    "isFile" => File.file?(location)
                }
            }
    end

    # Guardian::ensureItemsInCache()
    def self.ensureItemsInCache()
        VirtualItems::commit(Guardian::guardianRootItem())
        Guardian::guardianProjects().each{|project|
            s = VirtualItems::getOrNull(project["uuid"])
            next if s
            VirtualItems::commit(project)
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
        "🔹 #{item["description"]}"
    end

    # Guardian::dive()
    def self.dive()
        Operations::program3(lambda {
            Guardian::guardianProjects()
        })
    end
end
