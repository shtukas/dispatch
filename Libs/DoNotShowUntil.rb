
class DoNotShowUntil

    # DoNotShowUntil::doNotShowUntil(item, unixtime)
    def self.doNotShowUntil(item, unixtime)
        datetime = Time.at(unixtime).utc.iso8601
        puts "do not show #{PolyFunctions::toString(item).green} until #{datetime.green}"
        Items::setAttribute(item["uuid"], "do-not-show-until-51", datetime)
        XCache::set("71e90d03-618a-47a9-9412-3145bf469c7b:#{item["uuid"]}", datetime)
    end

    # DoNotShowUntil::itemToDatetimeOrNull(item)
    def self.itemToDatetimeOrNull(item)
        return item["do-not-show-until-51"] if item["do-not-show-until-51"]
        XCache::getOrNull("71e90d03-618a-47a9-9412-3145bf469c7b:#{item["uuid"]}")
    end

    # DoNotShowUntil::isVisible(item)
    def self.isVisible(item)
        if item["do-not-show-until-51"] then
            return Time.new.utc.iso8601 >= item["do-not-show-until-51"]
        end
        datetime = XCache::getOrNull("71e90d03-618a-47a9-9412-3145bf469c7b:#{item["uuid"]}")
        return true if datetime.nil?
        Time.new.utc.iso8601 >= datetime
    end

    # DoNotShowUntil::suffix(item)
    def self.suffix(item)
        datetime = DoNotShowUntil::itemToDatetimeOrNull(item)
        return "" if datetime.nil?
        return "" if datetime < Time.new.utc.iso8601
        " (no display until: #{datetime})".yellow
    end
end
