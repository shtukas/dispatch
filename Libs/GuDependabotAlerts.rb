
# encoding: UTF-8

class GuDependabotAlerts

    # GuDependabotAlerts::getData()
    def self.getData()
        IO.read("#{Config::userHomeDirectory()}/Galaxy/Software-Guardian/vulnerability-monitor/11-results.jsonlines.txt")
                        .strip
                        .lines
                        .map{|line| JSON.parse(line.strip) }
    end

    # GuDependabotAlerts::process()
    def self.process()
        GuDependabotAlerts::getData().each{|entries|
            entries.each{|entry|
                url = entry["html_url"]
                itemuuid = Digest::SHA1.hexdigest("5223948b-6fbc-418a-b7de-a641fcb8491c:#{url}")
                item = Items::itemOrNull(itemuuid)
                next if item
                timestamp = (XCache::getOrNull("405ada91-02eb-4428-9c72-13aad665715a:#{url}") || "0").to_i
                next if (Time.new.to_i - timestamp) < 86400 * 7
                item = NxPriorities::issuePriorityWithUrl(itemuuid, url)
                Donations::setDonation(item, NxRoots::guardianuuid())
                XCache::set("405ada91-02eb-4428-9c72-13aad665715a:#{url}", Time.new.to_i)
                puts JSON.pretty_generate(item)
            }
        }
    end
end
