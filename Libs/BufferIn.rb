
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
        Items::setAttribute(uuid, "global-pos-07", NxTasks::determineNewPosition())
        Items::setAttribute(uuid, "mikuType", "NxTask")
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
end
