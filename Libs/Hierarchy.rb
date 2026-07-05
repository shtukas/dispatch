
class Hierarchy

    # Hierarchy::itemsForChildrenExtractions()
    def self.itemsForChildrenExtractions()
        Items::items()
    end

    # Hierarchy::children(parentuuid)
    def self.children(parentuuid)
        if parentuuid == "085ca696dd8bd8db80a82160e88efcf35024eb01" then
            # guardian
            return Guardian::guardianProjects()
        end
        Hierarchy::itemsForChildrenExtractions().select{|item| item["parentuuid"] == parentuuid }
    end

    # Hierarchy::allChildrenOrderingTypes()
    def self.allChildrenOrderingTypes()
        [
            "ordered-by-gps-strict-sequence",
            "ordered-by-gps-(1/2^n)-sequence",
            "ordered-by-rt",
            "distribution"
        ]
    end

    # Hierarchy::interactivelySelectListingType()
    def self.interactivelySelectListingType()
        LucilleCore::selectEntityFromListOfEntities_EnsureChoice("listing style", Hierarchy::allChildrenOrderingTypes())
    end

    # Hierarchy::mark_children_with_distribution_rations(parent)
    def self.mark_children_with_distribution_rations(parent)
        loop {
            children = Hierarchy::children(parent["uuid"])
            child = LucilleCore::selectEntityFromListOfEntitiesOrNull("child", children, lambda {|child| "#{child["description"]}:#{Hierarchy::distributionSuffix(child)}" })
            return if child.nil?
            ratio = LucilleCore::askQuestionAnswerAsString("ratio: ").to_f
            next if ratio == 0
            XCache::set("ceb929a4-605c-407c-9986-b44b835ac4df:#{child["uuid"]}", ratio)
        }
    end

    # Hierarchy::makeNewOrderingDirective(parent)
    def self.makeNewOrderingDirective(parent)
        puts "Let's make a children ordering directive for #{PolyFunctions::toString(parent).green}"
        type = Hierarchy::interactivelySelectListingType()
        if type == "ordered-by-rt" then
            return {
                "type" => "ordered-by-rt"
            }
        end
        if type == "ordered-by-gps-strict-sequence" then
            return {
                "type" => "ordered-by-gps-strict-sequence"
            }
        end
        if type == "ordered-by-gps-strict-sequence" then
            return {
                "type" => "ordered-by-gps-(1/2^n)-sequence"
            }
        end
        if type == "distribution" then
            Hierarchy::mark_children_with_distribution_rations(parent)
            return {
                "type" => "distribution"
            }
        end
    end

    # Hierarchy::retrieveOrArchitechParentChildrenOrderingDirective(parent)
    def self.retrieveOrArchitechParentChildrenOrderingDirective(parent)
        directive = XCache::getOrNull("5f7d92de-4254-4777-a02f-3887207a57d8:#{parent["uuid"]}")
        if directive then
            return JSON.parse(directive)
        end
        directive = Hierarchy::makeNewOrderingDirective(parent)
        XCache::set("5f7d92de-4254-4777-a02f-3887207a57d8:#{parent["uuid"]}", JSON.generate(directive))
        directive
    end

    # Hierarchy::reviewParentChildrenOrderingDirective(parent)
    def self.reviewParentChildrenOrderingDirective(parent)
        directive = XCache::getOrNull("5f7d92de-4254-4777-a02f-3887207a57d8:#{parent["uuid"]}")
        if directive then
            puts "directive: #{directive}"
            if LucilleCore::askQuestionAnswerAsBoolean("update ? ") then
                directive = Hierarchy::makeNewOrderingDirective(parent)
                XCache::set("5f7d92de-4254-4777-a02f-3887207a57d8:#{parent["uuid"]}", JSON.generate(directive))
            end
        else
            directive = Hierarchy::makeNewOrderingDirective(parent)
            XCache::set("5f7d92de-4254-4777-a02f-3887207a57d8:#{parent["uuid"]}", JSON.generate(directive))
        end
    end

    # Hierarchy::distributionSuffix(item)
    def self.distributionSuffix(item)
        ratio = XCache::getOrNull("ceb929a4-605c-407c-9986-b44b835ac4df:#{item["uuid"]}")
        return "" if ratio.nil?
        percentage = ratio.to_f * 100
        " (#{percentage} %)".green
    end

    # Hierarchy::orderingDirectiveSuffix(item)
    def self.orderingDirectiveSuffix(item)
        directive = XCache::getOrNull("5f7d92de-4254-4777-a02f-3887207a57d8:#{item["uuid"]}")
        return "" if directive.nil?
        directive = JSON.parse(directive)
        " (#{directive["type"]})".green
    end

    # Hierarchy::architectPrelude(parent)
    def self.architectPrelude(parent)
        # This function creates some children and set an ordering directive
        puts "create the children"
        text = CommonUtils::editTextSynchronously("").strip
        return if text == ""
        text.lines.map{|line| line.strip }.each{|line|
            next if line == ""
            child = NxTasks::interactivelyIssueNewLine(line)
            Items::setAttribute(child["uuid"], "parentuuid", parent["uuid"])
            Items::setAttribute(child["uuid"], "global-pos-07", GlobalPositioning::last_position() + 1)
        }
        Hierarchy::reviewParentChildrenOrderingDirective(parent)
    end
end