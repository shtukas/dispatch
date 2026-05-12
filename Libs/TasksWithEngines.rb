# An engine represents a requirement to do something a certain number of hours 
# per day or per week

# A project is a task with an engine

class TasksWithEngines
    # TasksWithEngines::items()
    def self.items()
        Items::items().select{|item| item["engine-1437"] }
    end

    # TasksWithEngines::listingItems()
    def self.listingItems()
        # Version 1
        # TasksWithEngines::items().select{|item| NxEngines::ratio(item) < 1 }.sort_by{|item| NxEngines::ratio(item) }

        # Version 2
        TasksWithEngines::items().each{|item|
            needed = NxEngines::missing_timespan_for_today(item) -  NxEngineDelegate::total_capacity_for_targetuuid(item["uuid"])
            next if needed <= 0
            5.times {
                capacity = needed.to_f/5
                puts "issuing delegate for #{PolyFunctions::toString(item)}, capacity: #{capacity}".yellow
                NxEngineDelegate::issue(item["uuid"], capacity)
            }
        }
        []
    end
end