
class Transmute

    # Transmute::transmuteTo(item, targetType) # updated item
    def self.transmuteTo(item, targetType)
        if item["mikuType"] == "NxOndate" and targetType == "NxFloat" then
            Items::setAttribute(item["uuid"], "mikuType", "NxFloat")
            return Items::itemOrNull(item["uuid"])
        end
        if item["mikuType"] == "NxOndate" and targetType == "NxPriority" then
            Items::setAttribute(item["uuid"], "mikuType", "NxPriority")
            return Items::itemOrNull(item["uuid"])
        end
        if item["mikuType"] == "NxOndate" and targetType == "NxTask" then
            root = NxRoots::interactivelySelectOneOrNull()
            return if root.nil?
            position = NxRoots::decideNewElementPositionOrNull(root) || 0
            Items::setAttribute(item["uuid"], "global-pos-07", position)
            Items::setAttribute(item["uuid"], "parentuuid", root["uuid"]) # this should come after NxRoots::decideNewElementPositionOrNull
            Items::setAttribute(item["uuid"], "mikuType", "NxTask")
            return Items::itemOrNull(item["uuid"])
        end
        if item["mikuType"] == "NxPriority" and targetType == "NxTask" then
            root = NxRoots::interactivelySelectOneOrNull()
            return if root.nil?
            position = NxRoots::decideNewElementPositionOrNull(root) || 0
            Items::setAttribute(item["uuid"], "global-pos-07", position)
            Items::setAttribute(item["uuid"], "parentuuid", root["uuid"]) # this should come after NxRoots::decideNewElementPositionOrNull
            Items::setAttribute(item["uuid"], "mikuType", "NxTask")
            return Items::itemOrNull(item["uuid"])
        end
        if item["mikuType"] == "NxTask" and targetType == "NxDirectory" then
            if item["payload-37"] then
                puts "item has a payload, you cannot transform it into a directory"
                LucilleCore::pressEnterToContinue()
                return
            end
            Items::setAttribute(item["uuid"], "mikuType", "NxDirectory")
            if LucilleCore::askQuestionAnswerAsBoolean("enter items ? ") then
                text = CommonUtils::editTextSynchronously("").strip
                if text != "" then
                    text.lines.map {|line| line.strip }.reverse.each{|description|
                        task = NxTasks::interactivelyIssueNewLine(description)
                        Items::setAttribute(task["uuid"], "global-pos-07", GlobalPositioning::first_position() - 1)
                        Items::setAttribute(task["uuid"], "parentuuid", item["uuid"])
                    }
                end
            end
            return
        end
        raise "(error a7093fd4-0236) I do not know how to transmute #{item["mikuType"]} to #{targetType}"
    end

    # Transmute::transmute(item)
    def self.transmute(item)
        mapping = {
            "NxOndate" => ["NxFloat","NxPriority","NxTask"],
            "NxTask"   => ["NxDirectory"],
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
