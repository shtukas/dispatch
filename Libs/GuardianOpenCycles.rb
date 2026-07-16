
=begin

GuardianProject (virtual object)
{
    "uuid"        : String
    "mikuType"    : "GuardianProject"
    "description" : String
    "location"    : String
    ":virtual:"   : true
}

todo items
{
    - uuid          : String
    - mikuType      : "NxTask"
    - unixtime      :
    - datetime      :
    - description   : String
    - global-pos-07 : Float
}

=end

class GuardianOpenCycles

    # GuardianOpenCycles::children(project)
    def self.children(project)
        location = project["location"]
        if File.file?(location) then
            uuid = Digest::SHA1.hexdigest("395c2cc3-bc22-4f6b-b04f-c775262dafc4:#{location}")
            return [{
                "uuid"        => uuid,
                "mikuType"    => "NxTask",
                "description" => File.basename(location),
                ":virtual:"   => true,
                "parentuuid"  => project["uuid"]
            }]
        else
            return LucilleCore::locationsAtFolder(location)
                .select{|lx| File.basename(lx).include?("TODO.txt") }
                .map{|filepath|
                    text = File.read(filepath).strip
                    if text != "" then
                        text
                                .lines
                                .map{|line| line.strip }
                                .map{|description|
                                    uuid = Digest::SHA1.hexdigest("5d20e8f9-2612-4436-9cb0-95b869e22100:#{location}:#{description}")
                                    {
                                        "uuid"        => uuid,
                                        "mikuType"    => "NxTask",
                                        "description" => description,
                                        ":virtual:"   => true,
                                        "parentuuid"  => project["uuid"]
                                    }
                                }
                    else
                        []
                    end
                }.flatten

            return tasks
        end
    end

    # GuardianOpenCycles::items()
    def self.items()
        items = LucilleCore::locationsAtFolder("#{Config::pathToGalaxy()}/Open Cycles/2026-03-31 Guardian")
            .map{|location|
                uuid = Digest::SHA1.hexdigest("1d7bb7a1-a35a-4b39-b7bd-0087bfe4a476:#{location}")
                filename = File.basename(location)
                description = filename[11, filename.size()].strip
                {
                    "uuid"        => uuid,
                    "mikuType"    => "GuardianProject",
                    "description" => File.basename(location),
                    "location"    => location,
                    ":virtual:"   => true
                }
            }
        items.each{|item|
            ItemsInXCache::commit(item)
        }
        items
    end

    # GuardianOpenCycles::projectToString(item)
    def self.projectToString(item)
        "🐠 #{item["description"]}"
    end
end
