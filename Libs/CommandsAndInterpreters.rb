# encoding: UTF-8

class CommandsAndInterpreters

    # CommandsAndInterpreters::commands()
    def self.commands()
        [
            "on items : .. | ... | <datecode> | access (*) | start (*) | done (*) | program (*) | expose (*) | add time * | skip * hours (default item) | bank accounts * | payload (*) | bank data * | push * | * on <datecode> | edit * | destroy * | transmute (*) | donation * | dismiss | :: * (prioritise) | dive * | move *",
            "makers        : anniversary | wave | today | tomorrow | desktop | ondate | on <weekday> | backup | counter | todo | >> * (transmute) | float | feed",
            "divings       : anniversaries | ondates | waves | desktop | backups | tomorrows | todays | counters | feeds",
            "NxBalls       : start (*) | stop (*) | pause (*) | pursue (*)",
            "misc          : search | commands | fsck | fsck-force | global-maintenance | today priorities | numbers",
        ].join("\n")
    end

    # CommandsAndInterpreters::interpreter(input, store)NxEngine
    def self.interpreter(input, store)

        # We have a special handling for ++, which doesn't delist, unlike the other timecodes
        if Interpreting::match("++", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::stop(item)
            unixtime = Time.new.to_i + 3600
            puts "dot not show until: #{Time.at(unixtime).to_s}".yellow
            DoNotShowUntil::doNotShowUntil(item, unixtime)
            return
        end

        if input.start_with?("+") and (unixtime = CommonUtils::codeToUnixtimeOrNull(input.gsub(" ", ""))) then
            if (item = store.getDefault()) then
                PolyActions::stop(item)
                puts "dot not show until: #{Time.at(unixtime).to_s}".yellow
                DoNotShowUntil::doNotShowUntil(item, unixtime)
                return
            end
        end

        if Interpreting::match("..", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::doubleDots(item)
            return
        end

        if Interpreting::match(".. *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            PolyActions::doubleDots(item)
            return
        end

        if Interpreting::match("...", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::tripleDots(item)
            return
        end

        if Interpreting::match("... *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            PolyActions::tripleDots(item)
            return
        end

        if Interpreting::match("* on *", input) then
            listord, _, datecode = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            unixtime = CommonUtils::codeToUnixtimeOrNull(datecode)
            PolyActions::stop(item)
            DoNotShowUntil::doNotShowUntil(item, unixtime)
            return
        end

        if Interpreting::match(">> *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            Transmute::transmute(item)
            return
        end

        if Interpreting::match(":: *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            pitem = NxPriorities::prioritise(item)
            puts JSON.pretty_generate(pitem)
            GlobalPositioning::insert_last(pitem)
            return
        end

        if Interpreting::match("dismiss", input) then
            item = store.getDefault()
            return if item.nil?
            Operations::dismiss(item)
            return
        end

        if Interpreting::match("numbers", input) then
            FrontPage::tail_structure().each{|packet|
                puts "#{packet["name"]}: #{packet["rt"]}"
            }
            LucilleCore::pressEnterToContinue()
            return
        end

        if Interpreting::match("today priorities", input) then
            NxOndates::selectAndMarkPrioritiesForToday()
            wave = Items::itemOrNull("0bcd9517-03ca-4a9a-bf72-59fe01f997ff")
            if wave.nil? then
                puts "Please review [8f854be2]"
                LucilleCore::pressEnterToContinue()
                return
            end
            PolyActions::done(wave)
            return
        end

        if Interpreting::match("transmute", input) then
            item = store.getDefault()
            return if item.nil?
            Transmute::transmute(item)
            return
        end

        if Interpreting::match("transmute *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            Transmute::transmute(item)
            return
        end

        if Interpreting::match("dive *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            if item["uuid"] == Guardian::guardianFeederUuid() then
                puts "You cannot dive into the Guardian (you can access it)"
                LucilleCore::pressEnterToContinue()
                return
            end

            Parenting::dive(item)
            return
        end

        if Interpreting::match("global-maintenance", input) then
            Operations::globalMaintenance()
            return
        end

        if Interpreting::match("bank accounts *", input) then
            _, _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            puts JSON.pretty_generate(PolyFunctions::itemToBankingAccounts(item))
            LucilleCore::pressEnterToContinue()
            return
        end

        if Interpreting::match("bank data *", input) then
            _, _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            Bank::getRecords(item["uuid"])
                .sort_by{|record| record["date"] }
                .each{|record|
                    puts "recorduuid: #{record["recorduuid"]}; uuid: #{record["id"]}, date: #{record["date"]}, value: #{"%9.2f" % record["value"]}"
                }
            LucilleCore::pressEnterToContinue()
            return
        end

        if Interpreting::match("float", input) then
            item = NxFloats::interactivelyIssueNewOrNull()
            return  if item.nil?
            puts JSON.pretty_generate(item)
            return
        end

        if Interpreting::match("feed", input) then
            item = NxFeeds::interactivelyIssueNewOrNull()
            return  if item.nil?
            puts JSON.pretty_generate(item)
            return
        end

        if Interpreting::match("todo", input) then
            parent = Parenting::interactivelyRecursivelySelectParentOrNull(nil)
            return if parent.nil?
            item = NxTasks::interactivelyIssueNewOrNull(parent)
            return  if item.nil?
            puts JSON.pretty_generate(item)
            return
        end

        if Interpreting::match("move *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?

            parent = Parenting::interactivelyRecursivelySelectParentOrNull(nil)
            return if parent.nil?

            Items::setAttribute(item["uuid"], "parenting-22", parent["uuid"])
            return
        end

        if Interpreting::match("backup", input) then
            item = NxBackups::interactivelyIssueNewOrNull()
            puts JSON.pretty_generate(item)
            return
        end

        if Interpreting::match("backups", input) then
            Operations::program3(lambda { 
                Items::mikuType("NxBackup")
            })
            return
        end

        if Interpreting::match("payload", input) then
            item = store.getDefault()
            return if item.nil?
            UxPayloads::payloadProgram(item)
            return
        end

        if Interpreting::match("donation", input) then
            item = store.getDefault()
            return if item.nil?
            Donations::interactivelySetDonation(item)
            return
        end

        if Interpreting::match("donation *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            Donations::interactivelySetDonation(item)
            return
        end

        if Interpreting::match("clique *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            cliquename = NxFeeds::architectCliqueNameOrNull()
            return if cliquename.nil?
            Items::setAttribute(item["uuid"], "clique-13", cliquename)
            return
        end

        if Interpreting::match("feeds", input) then
            loop {
                feed = NxFeeds::interactivelySelectOneOrNull()
                return if feed.nil?
                Parenting::dive(feed)
            }
            return
        end

        if Interpreting::match("payload *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            UxPayloads::payloadProgram(item)
            return
        end

        if Interpreting::match("fsck", input) then
            Fsck::fsckAll()
            LucilleCore::pressEnterToContinue()
            return
        end

        if Interpreting::match("fsck-force", input) then
            Fsck::fsckAllForce()
            LucilleCore::pressEnterToContinue()
            return
        end

        if Interpreting::match("on *", input) then
            _, weekdayName = Interpreting::tokenizer(input)
            return if !["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"].include?(weekdayName)
            date = CommonUtils::selectDateOfNextNonTodayWeekDay(weekdayName)
            description = LucilleCore::askQuestionAnswerAsString("description: ")
            return if description == ""
            item = NxOndates::interactivelyIssueNewWithDetails(description, date)
            puts JSON.pretty_generate(item)
            return
        end

        if Interpreting::match("today", input) then
            description = LucilleCore::askQuestionAnswerAsString("description: ")
            return if description == ""
            item = NxOndates::interactivelyIssueNewWithDetails(description, CommonUtils::today())
            puts JSON.pretty_generate(item)
            return
        end

        if Interpreting::match("todays", input) then
            Operations::program3(lambda { 
                Items::mikuType("NxOndate").select{|item| item["date"] <= CommonUtils::today() }
            })
            return
        end

        if Interpreting::match("sort", input) then
            items = store.items()
            selected = CommonUtils::selectZeroOrMore(items, lambda {|item| PolyFunctions::toString(item) })
            selected.reverse.each{|item|
                ListPos39::markItemWithFirstPosition(item)
            }
            return
        end

        if Interpreting::match("counter", input) then
            item = NxCounters::interactivelyIssueNewOrNull()
            puts JSON.pretty_generate(item)
            return
        end

        if Interpreting::match("counters", input) then
            Operations::program3(lambda { 
                Items::mikuType("NxCounter")
            })
            return
        end

        if Interpreting::match("tomorrow", input) then
            description = LucilleCore::askQuestionAnswerAsString("description: ")
            return if description == ""
            item = NxOndates::interactivelyIssueNewWithDetails(description, CommonUtils::tomorrow())
            puts JSON.pretty_generate(item)
            return
        end

        if Interpreting::match("tomorrows", input) then
            Operations::program3(lambda { 
                Items::mikuType("NxOndate")
                    .select{|item| item["date"] == CommonUtils::tomorrow() }
            })
            return
        end

        if Interpreting::match("ondate", input) then
            item = NxOndates::interactivelyIssueNewOrNull()
            puts JSON.pretty_generate(item)
            return
        end

        if Interpreting::match("ondates", input) then
            Operations::program3(lambda { 
                Items::mikuType("NxOndate")
                    .sort_by{|item| item["date"] }
            })
            return
        end

        if Interpreting::match("skip * hours", input) then
            _, d, _ = Interpreting::tokenizer(input)
            item = store.getDefault()
            return if item.nil?
            Items::setAttribute(item["uuid"], "skip-0843", Time.new.to_i+3600*d.to_f)
            return
        end

        if Interpreting::match("add time *", input) then
            _, _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            puts "adding time for '#{PolyFunctions::toString(item).green}'"
            timeInHours = LucilleCore::askQuestionAnswerAsString("time in hours: ").to_f
            PolyActions::addTimeToItem(item, timeInHours*3600)
        end

        if Interpreting::match("access", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::access(item)
            return
        end

        if Interpreting::match("access *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            PolyActions::access(item)
            return
        end

        if Interpreting::match("priority", input) then
            description = LucilleCore::askQuestionAnswerAsString("description: ")
            return if description == ""
            item = NxPriorities::issueNew(description)
            puts JSON.pretty_generate(item)
            Donations::interactivelySetDonation(item)
            return
        end

        if Interpreting::match("anniversary", input) then
            item = Anniversaries::interactivelyIssueNewOrNull()
            return if item.nil?
            puts JSON.pretty_generate(item)
            return
        end

        if Interpreting::match("anniversaries", input) then
            Operations::program3(lambda { 
                Items::mikuType("Anniversary")
            })
            return
        end

        if Interpreting::match("commands", input) then
            puts CommandsAndInterpreters::commands().yellow
            LucilleCore::pressEnterToContinue()
            return
        end

        if Interpreting::match("description", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::editDescription(item)
            return
        end

        if Interpreting::match("description *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            PolyActions::editDescription(item)
            return
        end

        if Interpreting::match("edit", input) then
            item = store.getDefault()
            return if item.nil?
            Operations::editItem(item)
            return
        end

        if Interpreting::match("edit *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            Operations::editItem(item)
            return
        end

        if Interpreting::match("desktop", input) then
            system("open '#{Desktop::filepath()}'")
            return
        end

        if Interpreting::match("done", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::done(item)
            return
        end

        if Interpreting::match("done *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            PolyActions::done(item)
            return
        end

        if Interpreting::match("destroy *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            PolyActions::destroy(item)
            return
        end

        if Interpreting::match("push *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?

            PolyActions::stop(item)
            Operations::interactivelyPush(item)
            return
        end

        if Interpreting::match("expose", input) then
            item = store.getDefault()
            return if item.nil?
            Operations::expose(item)
            return
        end

        if Interpreting::match("expose *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            Operations::expose(item)
            return
        end

        if Interpreting::match("pause", input) then
            item = store.getDefault()
            return if item.nil?
            NxBalls::pause(item)
            return
        end

        if Interpreting::match("pause *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            NxBalls::pause(item)
            return
        end

        if Interpreting::match("pursue", input) then
            item = store.get(listord.to_i)
            return if item.nil?
            PolyActions::pursue(item)
            return
        end

        if Interpreting::match("pursue *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            PolyActions::pursue(item)
            return
        end

        if Interpreting::match("redate *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            PolyActions::stop(item)
            datetime = CommonUtils::interactivelyMakeDateTimeIso8601UsingDateCode()
            Items::setAttribute(item["uuid"], "date", datetime)
            return
        end

        if Interpreting::match("start", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::start(item)
            return
        end

        if Interpreting::match("start *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            PolyActions::start(item)
            return
        end

        if Interpreting::match("stop", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::stop(item)
            return
        end

        if Interpreting::match("stop *", input) then
            _, listord = Interpreting::tokenizer(input)
            item = store.get(listord.to_i)
            return if item.nil?
            PolyActions::stop(item)
            return
        end

        if Interpreting::match("search", input) then
            Search::run()
            return
        end

        if input == "wave" then
            item = Waves::interactivelyMakeNewOrNull()
            puts JSON.pretty_generate(item)
            return
        end

        if input == "waves" then
            Operations::program3(lambda { 
                w1, w2 = Items::mikuType("Wave").partition{|item| DoNotShowUntil::isVisible(item) }
                w2 + w1 # we put the done ones first
            })
            return
        end
    end
end
