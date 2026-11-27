
# encoding: UTF-8

class Domains

    # Domains::interactivelyDecideDomainOrNull()
    def self.interactivelyDecideDomainOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("domain", ["infinity", "guardian"])
    end

    # Domains::interactivelyDecideDomain()
    def self.interactivelyDecideDomain()
        domain = Domains::interactivelyDecideDomainOrNull()
        return domain if domain
        Domains::interactivelyDecideDomain()
    end

    # Domains::decideDomainUsingTheInstanceId()
    def self.decideDomainUsingTheInstanceId()
        if Config::instanceId() == "Lucille26-pascal-honore" then
            return "guardian"
        end
        "infinity"
    end
end
