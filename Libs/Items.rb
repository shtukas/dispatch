
# encoding: UTF-8

$InMemoryItemsF6F6ECA5 = nil

class Items

    # Items::loadItemsFromDiskToMemory()
    def self.loadItemsFromDiskToMemory()
        #puts "loading items to memory".yellow
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

        Fsck::fsckItemOrError(item, false)

        # Here we need to send the item to disk and update the in memory dataset

        # Index::commitItem returns an item, because it may not be the item that 
        # was submitted, in case we had to do a reconciliation
        item = Index::commitItem(item)
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
