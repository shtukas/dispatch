
=begin

GuardianProject (virtual object)
{
    "uuid"        : String
    "mikuType"    : "GuardianProject"
    "description" : String
    "location"    : String
}

=end

class GuardianOpenCycles

    # GuardianOpenCycles::items()
    def self.items()
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

    # GuardianOpenCycles::ensureItemsInCache()
    def self.ensureItemsInCache()
        GuardianOpenCycles::items().each{|project|
            s = VirtualItems::getOrNull(project["uuid"])
            next if s
            VirtualItems::commit(project)
        }
    end

    # GuardianOpenCycles::identifyTodoFileInDirectory(parent)
    def self.identifyTodoFileInDirectory(parent)
        LucilleCore::locationsAtFolder(parent)
            .select{|location| location.include?("TODO.txt") }
            .first
    end

    # GuardianOpenCycles::projectToString(item)
    def self.projectToString(item)
        "🔹 #{item["description"]}"
    end
end
