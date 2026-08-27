
class Guardian

    # Guardian::projects()
    def self.projects()
        return [] if !Config::isPrimaryInstance()
        items = LucilleCore::locationsAtFolder("#{Config::pathToGalaxy()}/Open Cycles/2026-03-31 Guardian")
            .map{|location|
                uuid = Digest::SHA1.hexdigest("1d7bb7a1-a35a-4b39-b7bd-0087bfe4a476:#{location}")
                filename = File.basename(location)
                description = filename[11, filename.size()].strip
                {
                    "uuid"             => uuid,
                    "mikuType"         => "NxTask",
                    "description"      => File.basename(location),
                    "location"         => location,
                    "guardian-project" => true,
                    "parentuuid"       => "3fc52f5b-706b-47ae-a540-eefc72e47b0b", # guardian open cycles
                }
            }
        items.map{|item|
            x = Items::itemOrNull(item["uuid"])
            if x then
                x
            else
                Items::commitItem(item)
                item
            end
        }
    end

    # Guardian::projectToString(item)
    def self.projectToString(item)
        "🐠 #{item["description"]}"
    end

    # Guardian::projectElementToString(item)
    def self.projectElementToString(item)
        "🔺 #{item["description"]}"
    end
end
