
# encoding: UTF-8

class GuDependabotAlerts

    # GuDependabotAlerts::getData()
    def self.getData()
        IO.read("#{Config::userHomeDirectory()}/Galaxy/Software/Guardian/vulnerability-monitor/11-results.jsonlines.txt")
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
                item = NxPriorities::issuePriorityWithUrl(itemuuid, url)
                puts JSON.pretty_generate(item)
            }
        }
    end
end
