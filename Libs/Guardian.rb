
class Guardian

    # Guardian::locations()
    def self.locations()
        locations = []
        Find.find("#{Config::pathToGalaxy()}/Open Cycles/2026-03-31 Guardian") do |path|
            if File.basename(path).include?("DISPATCH") then
                locations << path
            end
        end
        locations
    end

    # Guardian::toString(item)
    def self.toString(item)
        "G: #{item["description"]}"
    end

    # Guardian::guardianFeederUuid()
    def self.guardianFeederUuid()
        "085ca696dd8bd8db80a82160e88efcf35024eb01"
    end

    # Guardian::items()
    def self.items()
        Guardian::locations().map{|location|
            {
                "description" => location.split("/").drop(6).join(" > "),
                "location" => location
            }
        }
    end

    # Guardian::listingItems()
    def self.listingItems()
        item = Items::itemOrNull("085ca696dd8bd8db80a82160e88efcf35024eb01")
        return [] if NxFeeds::completionRatio(item) >= 1
        [item]
    end

    # Guardian::endsWith(line, ending)
    def self.endsWith(line, ending)
        line[-ending.size, ending.size] == ending
    end

    # Guardian::program()
    def self.program()
        loop {
            target = LucilleCore::selectEntityFromListOfEntitiesOrNull("item", Guardian::items(), lambda { |item| Guardian::toString(item) })
            return if target.nil?
            if File.directory?(target["location"]) then
                puts "opening directory: #{target}"
                system("open '#{target["location"]}'")
                LucilleCore::pressEnterToContinue()
                next
            end
            openable_extensions = [".txt", ".png"]
            if openable_extensions.any?{|ending| Guardian::endsWith(target["location"], ending) } then
                system("open '#{target["location"]}'")
                LucilleCore::pressEnterToContinue()
                next
            end
            puts "[8e10c6c5] I do not know how to open: #{target["location"]}"
            exit
        }
    end
end
