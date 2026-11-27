
# encoding: UTF-8

class Domains

    # Domains::interactivelyDecideDomain()
    def self.interactivelyDecideDomain()
        domain = LucilleCore::selectEntityFromListOfEntitiesOrNull("domain", ["infinity", "guardian"])
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
