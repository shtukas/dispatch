
class Transmute

    # Transmute::transmuteTo(item, targetType) # updated item
    def self.transmuteTo(item, targetType)
        if item["mikuType"] == "NxOndate" and targetType == "NxDirective" then
            Items::setAttribute(item["uuid"], "mikuType", "NxDirective")
            return Items::itemOrNull(item["uuid"])
        end
        if item["mikuType"] == "NxOndate" and targetType == "NxPriority" then
            Items::setAttribute(item["uuid"], "mikuType", "NxPriority")
            return Items::itemOrNull(item["uuid"])
        end
        if item["mikuType"] == "NxOndate" and targetType == "NxTask" then
            Items::setAttribute(item["uuid"], "global-pos-07", GlobalPositioning::first_position() - 1)
            Items::setAttribute(item["uuid"], "parentuuid", root["uuid"]) # this should come after GlobalPositioning::decideNewElementPositionInParent
            Items::setAttribute(item["uuid"], "domain", Domains::decideDomain())
            Items::setAttribute(item["uuid"], "mikuType", "NxTask")
            return Items::itemOrNull(item["uuid"])
        end
        if item["mikuType"] == "NxOndate" and targetType == "Wave" then
            nx46 = Nx46::interactivelyMakeNewOrNull()
            Items::setAttribute(item["uuid"], "nx46", nx46)
            Items::setAttribute(item["uuid"], "mikuType", "Wave")
            Items::setAttribute(item["uuid"], "lastDoneUnixtime", 0)
            Items::setAttribute(item["uuid"], "interruption", LucilleCore::askQuestionAnswerAsBoolean("interruption ?: "))
            return Items::itemOrNull(item["uuid"])
        end
        if item["mikuType"] == "NxPriority" and targetType == "NxTask" then
            Items::setAttribute(item["uuid"], "global-pos-07", GlobalPositioning::first_position() - 1)
            Items::setAttribute(item["uuid"], "parentuuid", root["uuid"]) # this should come after GlobalPositioning::decideNewElementPositionInParent
            Items::setAttribute(item["uuid"], "domain", Domains::decideDomain())
            Items::setAttribute(item["uuid"], "mikuType", "NxTask")
            return Items::itemOrNull(item["uuid"])
        end
        raise "(error a7093fd4-0236) I do not know how to transmute #{item["mikuType"]} to #{targetType}"
    end

    # Transmute::transmute(item)
    def self.transmute(item)
        mapping = {
            "NxOndate" => ["NxDirective","NxPriority","NxTask", "Wave"],
            "NxPriority"   => ["NxTask"],
        }
        targetTypes = mapping[item["mikuType"]]
        if targetTypes.nil? or targetTypes.empty? then
            puts "I do not have transmute targets for #{item["mikuType"]}"
            LucilleCore::pressEnterToContinue()
            return
        end
        targetType = LucilleCore::selectEntityFromListOfEntitiesOrNull("target", targetTypes)
        if targetType then
            Transmute::transmuteTo(item, targetType)
            return
        end
    end
end
