
class BufferIn

    # BufferIn::issueNew(filepath)
    def self.issueNew(filepath)
        description = File.basename(filepath)
        uuid = SecureRandom.uuid
        Items::init(uuid)
        Items::setAttribute(uuid, "unixtime", Time.new.to_i)
        Items::setAttribute(uuid, "datetime", Time.new.utc.iso8601)
        Items::setAttribute(uuid, "description", description)
        Items::setAttribute(uuid, "payload-37", UxPayloads::locationToPayload(filepath))
        Items::setAttribute(uuid, "parenting-22", BufferIn::deleguateuuid())
        Items::setAttribute(uuid, "mikuType", "BufferInItem")
        item = Items::itemOrNull(uuid)
        item
    end

    # BufferIn::import()
    def self.import()
        repository = "#{Config::userHomeDirectory()}/Desktop/Buffer-In"
        return if !File.exist?(repository)
        LucilleCore::locationsAtFolder(repository).each{|location|
            next if File.basename(location).start_with?('.')
            puts "importing location: #{location}".yellow
            BufferIn::issueNew(location)
            LucilleCore::removeFileSystemLocation(location)
        }
    end

    # BufferIn::itemToString(item)
    def self.itemToString(item)
        "🥐 #{item["description"]}"
    end

    # BufferIn::delegateToString(item)
    def self.delegateToString(item)
        "🐞 #{item["description"]}"
    end

    # BufferIn::deleguateuuid()
    def self.deleguateuuid()
        "101b6971-3582-4459-9882-cf9d2fa52503"
    end

    # BufferIn::timeTrackingAccount()
    def self.timeTrackingAccount()
        "95580b8d-b62f-4fa2-88ad-aefdc3ca450c"
    end

    # BufferIn::listingItems()
    def self.listingItems()
        if BankDerivedData::recoveredAverageHoursPerDay(BufferIn::timeTrackingAccount()) > 1 then
            return []
        end
        Items::mikuType("BufferInDelegate").sort_by{|item| item["unixtime"] }
    end
end
