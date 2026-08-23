
class Guardian

    # Guardian::project_children_core(project)
    def self.project_children_core(project)
        location = project["location"]
        if File.file?(location) then
            uuid = Digest::SHA1.hexdigest("395c2cc3-bc22-4f6b-b04f-c775262dafc4:#{location}")
            return [{
                "uuid"        => uuid,
                "mikuType"    => "NxTask",
                "description" => File.basename(location),
                ":virtual:"   => true,
                "parentuuid"  => project["uuid"],
                "guardian-project-element" => {
                    "todo-filepath" => location
                }
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
                                        "parentuuid"  => project["uuid"],
                                        "guardian-project-element" => {
                                            "todo-filepath" => filepath
                                        }
                                    }
                                }
                    else
                        []
                    end
                }.flatten

            return tasks
        end
    end

    # Guardian::project_children(project)
    def self.project_children(project)
        items = Guardian::project_children_core(project)
        items.map{|item|
            x = Items::itemOrNull(item["uuid"])
            if x then
                x
            else
                Items::commitItem(item)
                item
            end
        }
        .select {|item| DoNotShowUntil::isVisible(item) }
    end

    # Guardian::projects()
    def self.projects()
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
        .select {|item| DoNotShowUntil::isVisible(item) }
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
