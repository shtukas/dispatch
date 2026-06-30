
class PolyFunctions

    # PolyFunctions::itemToBankingAccounts(item, depth = 6) # Array[{description, number}]
    def self.itemToBankingAccounts(item, depth = 6)

        return [] if depth == 0

        accounts = []

        accounts << {
            "description" => item["description"] || item["mikuType"],
            "number"      => item["uuid"]
        }

        if item["donation-14"] then
            target = Items::itemOrNull(item["donation-14"])
            if target then
                accounts = accounts + PolyFunctions::itemToBankingAccounts(target)
            end
        end

        accounts << {
            "description" => item["mikuType"],
            "number"      => "28c68c60:#{item["mikuType"]}"
        }

        if item["mikuType"] == "BufferInItem" then
            accounts << {
                "description" => "buffer in time tracking",
                "number"      => BufferIn::timeTrackingAccount()
            }
        end

        if item["mikuType"] == "NxTask" then
            parent = Items::itemOrNull(item["parenting-22"])
            if parent then
                accounts = accounts + PolyFunctions::itemToBankingAccounts(parent)
            end
        end

        accounts.reduce([]){|as, account|
            if as.map{|a| a["number"] }.include?(account["number"]) then
                as
            else
                as + [account]
            end
        }
    end

    # PolyFunctions::toString(item)
    def self.toString(item)
        if item["mikuType"] == "DesktopTx1" then
            return item["announce"]
        end
        if item["mikuType"] == "Anniversary" then
            return Anniversaries::toString(item)
        end
        if item["mikuType"] == "NxTask" then
            return NxTasks::toString(item)
        end
        if item["mikuType"] == "BufferInItem" then
            return BufferIn::itemToString(item)
        end
        if item["mikuType"] == "BufferInDelegate" then
            return BufferIn::delegateToString(item)
        end
        if item["mikuType"] == "NxOndate" then
            return NxOndates::toString(item)
        end
        if item["mikuType"] == "NxCounter" then
            return NxCounters::toString(item)
        end
        if item["mikuType"] == "NxNotification" then
            return NxNotifications::toString(item)
        end
        if item["mikuType"] == "NxFloat" then
            return NxFloats::toString(item)
        end
        if item["mikuType"] == "NxBackup" then
            return NxBackups::toString(item)
        end
        if item["mikuType"] == "NxPriority" then
            return NxPriorities::toString(item)
        end
        if item["mikuType"] == "Wave" then
            return Waves::toString(item)
        end
        if item["mikuType"] == "NxFeed" then
            return NxFeeds::toString(item)
        end
        raise "(error: 820ce38d-e9db-4182-8e14-69551f58671d) I do not know how to PolyFunctions::toString(item): #{item}"
    end

    # PolyFunctions::uuid_to_item_or_null_cache_results(uuid)
    def self.uuid_to_item_or_null_cache_results(uuid)
        packet = XCache::getOrNull("00cc1ac4-1a63-437a-802b-8bcadbdb0fb4:#{uuid}")
        return JSON.parse(packet)[0] if packet
        item = Items::itemOrNull(uuid)
        XCache::set("00cc1ac4-1a63-437a-802b-8bcadbdb0fb4:#{uuid}", JSON.generate([item]))
        item
    end
end
