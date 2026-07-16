class FrontPage

    # -----------------------------------------
    # Data

    # FrontPage::canBeDefault(item)
    def self.canBeDefault(item)
        return false if TmpSkip1::isSkipped(item)
        return true  if NxBalls::itemIsRunning(item)
        return false if item["mikuType"] == "NxFloat"
        true
    end

    # FrontPage::isInterruption(item)
    def self.isInterruption(item)
        item["interruption"]
    end

    # FrontPage::toString2(store, item)
    def self.toString2(store, item)
        return nil if item.nil?
        storePrefix = store ? "(#{store.prefixString()})" : ""
        line = "#{storePrefix} #{PolyFunctions::toString(item)}#{UxPayloads::suffixString(item)}#{NxBalls::nxballSuffixStatusIfRelevant(item)}#{Donations::suffix(item)}#{DoNotShowUntil::suffix(item)}#{OrderingTypes::orderingDirectiveSuffix(item)}"
        if TmpSkip1::isSkipped(item) then
            line = line.yellow
        end
        if !DoNotShowUntil::isVisible(item) then
            line = line.yellow
        end
        if NxBalls::itemIsActive(item) then
            line = line.green
        end
        if NxBalls::itemIsRunning(item) then
            line = line.green
        end
        line
    end

    # FrontPage::printItem(store, item, screen_width)
    def self.printItem(store, item, screen_width)
        return 0 if item.nil?
        store.register(item, FrontPage::canBeDefault(item))
        height = 0
        storePrefix = store ? "(#{store.prefixString()})" : ""
        line = "#{storePrefix} #{PolyFunctions::toString(item)}#{UxPayloads::suffixString(item)}#{NxBalls::nxballSuffixStatusIfRelevant(item)}#{Donations::suffix(item)}#{DoNotShowUntil::suffix(item)}#{OrderingTypes::orderingDirectiveSuffix(item)}"
        if TmpSkip1::isSkipped(item) then
            line = line.yellow
        end
        if !DoNotShowUntil::isVisible(item) then
            line = line.yellow
        end
        if NxBalls::itemIsActive(item) then
            line = line.green
        end
        if NxBalls::itemIsRunning(item) then
            line = line.green
        end
        puts line
        height = height + (line.size/screen_width + 1)
        height
    end

    # -----------------------------------------
    # Ops

    # FrontPage::preliminaries(initialCodeTrace)
    def self.preliminaries(initialCodeTrace)
        if CommonUtils::catalystTraceCode() != initialCodeTrace then
            puts "Code change detected"
            exit
        end
    end

    # FrontPage::isAccessible(item)
    def self.isAccessible(item)
        if item["payload-37"] and item["payload-37"]["mikuType"] == "Dx8Unit" then
            if Config::instanceId().start_with?("Lucille26") then
                # We don't do Dx8Units on Lucille26
                return false
            end
        end
        true
    end

    # FrontPage::itemsForListingOrdered()
    def self.itemsForListingOrdered()
        GuardianOpenCycles::ensureItemsInCache()

        guardian_on = BankDerivedData::recoveredAverageHoursPerDay("fd608ab9-c3d7-4970-a464-9a736159855b") < 3 ? [Items::itemOrNull("fd608ab9-c3d7-4970-a464-9a736159855b")] : []

        items = [
            Anniversaries::listingItems(),
            Desktop::listingItems(),
            NxNotifications::listingItems(),
            NxPriorities::listingItems(),
            NxFloats::listingItems(),
            Waves::listingItemsInterruption(),
            NxCounters::listingItems(),
            NxOndates::listingItems(),
            NxBackups::listingItems(),
            guardian_on,
            NxRoots::listingItems(),
        ]
            .flatten
            .select {|item| DoNotShowUntil::isVisible(item) }
            .select {|item| FrontPage::isAccessible(item) }

        is1, is2 = items.partition{|item| item["listpos39"] and item["listpos39"]["date"] == CommonUtils::today() }
        is1 = is1.sort_by{|item| item["listpos39"]["position"] }
        is1 + is2
    end

    # FrontPage::displayListing(initialCodeTrace)
    def self.displayListing(initialCodeTrace)

        BufferIn::import()

        NxNotifications::pickup()

        sheight = CommonUtils::screenHeight() - 5
        swidth = CommonUtils::screenWidth()

        if Config::isPrimaryInstance() then
            if (Time.new.to_i - XCache::getOrDefaultValue("e1450d85-3f2b-4c3c-9c57-5e034361e8d6", "0").to_i) > 86400 then
                Operations::globalMaintenance()
                XCache::set("e1450d85-3f2b-4c3c-9c57-5e034361e8d6", Time.new.to_i)
            end
        end

        system('clear')

        puts ""

        t1 = Time.new.to_f

        store = ItemStore.new()
        items = FrontPage::itemsForListingOrdered()
        items = Prefix::prefix(items)
        items = NxBalls::activeItems() + items
        items = CommonUtils::removeDuplicateObjectsOnAttribute(items, "uuid")

        items.each{|item|
            d = FrontPage::printItem(store, item, swidth)
            sheight = sheight - d
            break if sheight <= 0
        }

        t2 = Time.new.to_f
        renderingTime = t2-t1
        if renderingTime > 0.5 then
            puts "rendering time: #{renderingTime.round(3)} seconds".red
        end

        input = LucilleCore::askQuestionAnswerAsString("> ")
        if input == "exit" then
            return
        end

        CommandsAndInterpreters::interpreter(input, store)
    end

    # FrontPage::main()
    def self.main()
        # The in memory items should be updated during activity, but we load from disk every 2 mins 
        # to pick up changes from other instances
        Thread.new {
            sleep 300
            loop {
                Items::loadItemsFromDiskToMemory()
                sleep 300
            }
        }

        initialCodeTrace = CommonUtils::catalystTraceCode()
        loop {
            FrontPage::preliminaries(initialCodeTrace)
            FrontPage::displayListing(initialCodeTrace)
        }
    end
end
