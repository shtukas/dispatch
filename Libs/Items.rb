
# encoding: UTF-8

$InMemoryItemsF6F6ECA5 = nil

class Items

    # Items::itemsRepository()
    def self.itemsRepository()
        "#{Config::pathToGalaxy()}/DataHub/Dispatch/data/items-2107"
    end

    # Items::getItemsFromDisk()
    def self.getItemsFromDisk()
        items = []
        Find.find(Items::itemsRepository()) do |path|
            if path[-5, 5] == ".json" then
                items << JSON.parse(IO.read(path))
            end
        end
        items
    end

    # Items::loadItemsFromDiskToMemory()
    def self.loadItemsFromDiskToMemory()
        #puts "loading items to memory".yellow
        $InMemoryItemsF6F6ECA5 = Items::getItemsFromDisk()
    end

    # Items::ensureItems()
    def self.ensureItems()
        # This function just ensures that 
        if $InMemoryItemsF6F6ECA5.nil? then
            Items::loadItemsFromDiskToMemory()
        end
    end

    # Items::items()
    def self.items()
        Items::ensureItems()
        $InMemoryItemsF6F6ECA5.clone()
    end

    # Items::mikuType(mikuType)
    def self.mikuType(mikuType)
        Items::ensureItems()
        $InMemoryItemsF6F6ECA5.select{|i| i["mikuType"] == mikuType }
    end

    # Items::itemOrNull(uuid)
    def self.itemOrNull(uuid)
        Items::ensureItems()
        $InMemoryItemsF6F6ECA5.select{|i| i["uuid"] == uuid }.first
    end

    # Items::commitItem(item)
    def self.commitItem(item)
        Fsck::fsckItemOrError(item, false)
        filepath = "#{Items::itemsRepository()}/#{item["uuid"]}.json"
        File.open(filepath, "w"){|f| f.puts(JSON.pretty_generate(item)) }
        if $InMemoryItemsF6F6ECA5 then
            $InMemoryItemsF6F6ECA5 = $InMemoryItemsF6F6ECA5.reject{|i| i["uuid"] == item["uuid"] } + [item]
        end
        item
    end

    # Items::init(uuid)
    def self.init(uuid)
        item = {
            "uuid" => uuid,
            "mikuType" => "NxDeleted",
            "unixtime" => Time.new.to_i
        }
        Items::commitItem(item)
        Items::ensureItems()
        $InMemoryItemsF6F6ECA5 = $InMemoryItemsF6F6ECA5 + [item]
    end

    # Items::setAttribute(uuid, attribute_name, attribute_value) # -> updated Item
    def self.setAttribute(uuid, attribute_name, attribute_value)
        item = Items::itemOrNull(uuid)
        return if item.nil?
        item[attribute_name] = attribute_value
        Items::commitItem(item)
    end

    # Items::deleteItem(uuid)
    def self.deleteItem(uuid)
        filepath = "#{Items::itemsRepository()}/#{uuid}.json"
        if File.exist?(filepath) then
            FileUtils.rm(filepath)
        end
        if $InMemoryItemsF6F6ECA5 then
            $InMemoryItemsF6F6ECA5 = $InMemoryItemsF6F6ECA5.reject{|i| i["uuid"] == uuid }
        end
    end
end
