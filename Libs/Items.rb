
# encoding: UTF-8

$InMemoryItemsF6F6ECA5 = nil

class Shared1502

    # Shared1502::directory()
    def self.directory()
        "#{Config::pathToDataRepository()}/shared-1502"
    end

    # Shared1502::write_new_value_to_shared_space(value)
    def self.write_new_value_to_shared_space(value)
        filepaths = LucilleCore::locationsAtFolder(Shared1502::directory())
            .select{|filepath| filepath[-4, 4] == ".txt" }
        File.open("#{Shared1502::directory()}/#{CommonUtils::timeStringL22()}.txt", "w") {|f| f.puts(value) }
        filepaths.each{|filepath|
            FileUtils.rm(filepath)
        }
    end

    # Shared1502::write_value_to_xcache(value)
    def self.write_value_to_xcache(value)
        XCache::set("c7b6952f-0bbc-48a2-b41e-c2c29e6b28f3", value)
    end

    # Shared1502::read_shared_value()
    def self.read_shared_value()
        LucilleCore::locationsAtFolder(Shared1502::directory())
            .select{|filepath| filepath[-4, 4] == ".txt" }
            .map{|filepath| IO.read(filepath).strip }
            .join(":")
            .strip
    end

    # Shared1502::values_are_in_sync()
    def self.values_are_in_sync()
        Shared1502::read_shared_value() == XCache::getOrDefaultValue("c7b6952f-0bbc-48a2-b41e-c2c29e6b28f3", "").strip
    end

    # Shared1502::issue_new_common_value()
    def self.issue_new_common_value()
        value = SecureRandom.hex
        Shared1502::write_new_value_to_shared_space(value)
        Shared1502::write_value_to_xcache(value)
    end

end

class Items

    # Items::loadItemsFromDiskToMemory()
    def self.loadItemsFromDiskToMemory()
        puts "loading items to memory".yellow
        $InMemoryItemsF6F6ECA5 = Index::getItems()
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
        # Here we need to send the item to disk and update the in memory dataset

        # Index::commitItem returns an item, because it may not be the item that 
        # was submitted, in case we had to do a reconciliation
        item = Index::commitItem(item)

        Shared1502::issue_new_common_value()

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
        # Index::commitItem returns an item, because it may not be the item that 
        # was submitted, in case we had to do a reconciliation
        item = Items::commitItem(item)

        item
    end

    # Items::deleteItem(uuid)
    def self.deleteItem(uuid)
        Index::deleteItem(uuid)
        if $InMemoryItemsF6F6ECA5 then
            $InMemoryItemsF6F6ECA5 = $InMemoryItemsF6F6ECA5.reject{|i| i["uuid"] == uuid }
        end
    end
end
