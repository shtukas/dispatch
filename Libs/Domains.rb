
# encoding: UTF-8

class Domains

    # Domains::decideDomain()
    def self.decideDomain()
        domain = LucilleCore::selectEntityFromListOfEntitiesOrNull("domain", ["infinity", "guardian"])
        return domain if domain
        Domains::decideDomain()
    end

    # Domains::domainUsingTheInstanceId()
    def self.domainUsingTheInstanceId()
        if Config::instanceId() == "Lucille26-pascal-honore" then
            return "guardian"
        end
        "infinity"
    end
end
