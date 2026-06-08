
class ListPos39

    # -------------------------
    # Data

    # ListPos39::firstPosition()
    def self.firstPosition()
        positions = Items::items()
            .map{|item|
                item["listpos39"]
            }
            .compact
            .select{|listpos39| listpos39["date"] == CommonUtils::today() }
            .map{|listpos39| listpos39["position"] }
        ([0] + positions).min
    end

    # ListPos39::hasACurrentPosition(item)
    def self.hasACurrentPosition(item)
        return false if item["listpos39"].nil?
        return false if item["listpos39"]["date"] != CommonUtils::today()
        true
    end

    # ListPos39::currentPositionOrNull(item)
    def self.currentPositionOrNull(item)
        return nil if item["listpos39"].nil?
        return nil if item["listpos39"]["date"] != CommonUtils::today()
        item["listpos39"]["position"]
    end

    # -------------------------
    # Ops

    # ListPos39::markItemWithPosition(item, position)
    def self.markItemWithPosition(item, position)
        mark = {
            "date" => CommonUtils::today(),
            "position" => position
        }
        Items::setAttribute(item["uuid"], "listpos39", mark)
    end

    # ListPos39::markItemWithFirstPosition(item)
    def self.markItemWithFirstPosition(item)
        position = ListPos39::firstPosition() - 1
        ListPos39::markItemWithPosition(item, position)
    end
end
