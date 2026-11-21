
class Operations

    # Operations::editItemJson(item)
    def self.editItemJson(item)
        # This function edit the payload, if there is now
        item = JSON.parse(CommonUtils::editTextSynchronously(JSON.pretty_generate(item)))
        item.each{|k, v|
            Items::setAttribute(item["uuid"], k, v)
        }
    end

    # Operations::editItem(item)
    def self.editItem(item)
        option = LucilleCore::selectEntityFromListOfEntitiesOrNull("option", ["edit description", "edit payload", "edit json"])
        return if option.nil?
        if option == "edit description" then
            PolyActions::editDescription(item)
        end
        if option == "edit payload" then
            UxPayloads::editItemPayload(item)
        end
        if option == "edit json" then
            Operations::editItemJson(item)
        end
    end

    # Operations::program(item)
    def self.program(item)
        if item["mikuType"] == "Wave" then
            Waves::program(item)
            return
        end
        puts "Using default program for #{item["mikuType"]} (Operations::editItem)"
        Operations::editItem(item)
    end

    # Operations::program3(lx)
    def self.program3(lx)
        loop {
            elements = lx.call()
            store = ItemStore.new()
            puts ""
            elements
                .each{|item|
                    lines = FrontPage::toString2(store, item, FrontPage::canBeDefault(item))
                    lines.each{|line|
                        puts line
                    }
                }
            puts ""
            input = LucilleCore::askQuestionAnswerAsString("> ")
            return if input == "exit"
            return if input == ""
            CommandsAndInterpreters::interpreter(input, store)
        }
    end

    # Operations::globalMaintenance()
    def self.globalMaintenance()
        puts "Running global maintenance".yellow
        Bank::maintenance()

        Items::items().each{|item|
            if item["parentuuid"] then
                if Items::itemOrNull(item["parentuuid"]).nil? then
                    puts "setting parentuuid to null for item uuid: #{item["uuid"]}"
                    Items::setAttribute(item["uuid"], "parentuuid", nil)
                end
            end
        }

        LucilleCore::locationsAtFolder("#{Config::pathToGalaxy()}/Open Cycles Guardian").each{|location|
            filename = File.basename(location)
            description = filename
            next if NxDirectories::getDirectoryByDescriptionOrNull(description)
            puts "creating new guardian directory: #{description}"
            item = NxDirectories::issueNew(description)
            Items::setAttribute(item["uuid"], "parentuuid", NxRoots::guardianuuid()) # guardian
        }
    end

    # Operations::interactivelyGetLinesUsingTextEditor()
    def self.interactivelyGetLinesUsingTextEditor()
        text = CommonUtils::editTextSynchronously("").strip
        return [] if text == ""
        text
            .lines
            .map{|line| line.strip }
            .select{|line| line != "" }
    end

    # Operations::interactivelyGetLinesUsingTerminal()
    def self.interactivelyGetLinesUsingTerminal()
        lines = []
        loop {
            line = LucilleCore::askQuestionAnswerAsString("entry (empty to abort): ")
            break if line.size == 0
        }
        lines
    end

    # Operations::interactivelyRecompileLines(lines)
    def self.interactivelyRecompileLines(lines)
        text = CommonUtils::editTextSynchronously(lines.join("\n")).strip
        return [] if text == ""
        text
            .lines
            .map{|line| line.strip }
            .select{|line| line != "" }
    end

    # Operations::interactivelyPush(item)
    def self.interactivelyPush(item)
        PolyActions::stop(item)
        puts "push '#{PolyFunctions::toString(item).green}'"
        unixtime = CommonUtils::interactivelyMakeUnixtimeUsingDateCodeOrNull()
        return if unixtime.nil?
        puts "pushing until '#{Time.at(unixtime).to_s.green}'"
        DoNotShowUntil::doNotShowUntil(item, unixtime)
    end

    # Operations::expose(item)
    def self.expose(item)
        puts JSON.pretty_generate(item)
        puts "rt: #{BankDerivedData::recoveredAverageHoursPerDay(item["uuid"])}"
        LucilleCore::pressEnterToContinue()
    end

    # Operations::postponeToTomorrowOrDestroy(item)
    def self.postponeToTomorrowOrDestroy(item)
        puts PolyFunctions::toString(item).green
        options = ["postpone to tomorrow (default)", "destroy"]
        option = LucilleCore::selectEntityFromListOfEntitiesOrNull("option", options)
        if option.nil? or option == "postpone to tomorrow (default)" then
            DoNotShowUntil::doNotShowUntil(item, CommonUtils::unixtimeAtTomorrowMorningAtLocalTimezone())
        end
        if option == "destroy" then
            Items::deleteItem(item["uuid"])
        end
    end

    # Operations::dismiss(item)
    def self.dismiss(item)
        unixtime = CommonUtils::unixtimeAtTomorrowMorningAtLocalTimezone()
        puts "dot not show until: #{Time.at(unixtime).to_s}".yellow
        DoNotShowUntil::doNotShowUntil(item, unixtime)
    end

    # Operations::privateGardenManagement()
    def self.privateGardenManagement()

        # Extraction of images from the repository to the desktop
        if Config::instanceId() == "Lucille24-pascal" then
            exec_path = "#{XCache::getOrNull("cac5c562-cb8c-417c-97dc-f470961cfb1d")}/todo-to-desktop-feed.rb"
            if !File.exist?(exec_path) then
                puts "[ce68bd33] Cannot recover the path to Private Garden"
                exit
            end
            system("ruby '#{exec_path}'")
        end

        # Processing of the private-garden-destruction directory
        destruction_directory = "#{ENV["HOME"]}/Desktop/private-garden-destruction"
        if !File.exist?(destruction_directory) then
            puts "[076f806c] Cannot see private-garden-destruction on the Desktop"
            exit
        end
        filepaths = LucilleCore::locationsAtFolder(destruction_directory)
        filepaths.each{|filepath|
            filename = File.basename(filepath)
            puts "destroying '#{filename}' from the wallpapers"
            # example private-garden-100-LUGHEAD.png
            dir1 = filename[15, 3] # directory name inside Desktop-Pictures-Repository, that we extract from the private garden feeder image
            puts "dir1: '#{dir1}'"
            filename1 = filename[19, filename.size] # filename inside Desktop-Pictures-Repository
            puts "filename1: '#{filename1}'"
            filepath_in_wallpapers = "/Users/pascal/Galaxy/DataHub/Desktop-Pictures-Repository/#{dir1}/#{filename1}"
            puts "filepath_in_wallpapers: '#{filepath_in_wallpapers}'"
            if File.exist?(filepath_in_wallpapers) then
                puts "deleting: '#{filepath_in_wallpapers}'"
                FileUtils.rm(filepath_in_wallpapers)
            else
                puts "I reconstructed this file '#{filepath_in_wallpapers}', but can't see it at destination"
                puts "skipping removal"
                LucilleCore::pressEnterToContinue()
            end
            puts "deleting: '#{filepath}'"
            FileUtils.rm(filepath)
            exit
        }
    end
end
