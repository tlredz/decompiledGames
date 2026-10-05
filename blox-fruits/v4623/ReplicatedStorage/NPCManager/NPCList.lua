require(game.ReplicatedStorage.NPCManager.Types)
local Config = require(game.ReplicatedStorage.NPCManager.NPC.Config)
local Flags = require(game.ReplicatedStorage.Modules.Flags)
local ZiolesShadow = require(game.ReplicatedStorage.DialoguesList.NPCs.ZiolesShadow)
local StagingMarks = require(game.ReplicatedStorage.NPCManager.StagingMarks)
local list = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function registerNPC(name: string, p)
	list[name] = p
	p._name = name
	Config.NPCInfoRegistered:Fire(p)
end

local function legacyRegisterNPC(name: string, dialogueCallback, p: number, idleAnimationId: number?)
	local questInfo = nil

	for _, v4 in Config.QuestInfo do
		if v4.Type ~= p then
			continue
		end

		questInfo = v4
		break
	end

	if not questInfo then
		warn((`Invalid quest info type {p} for NPC {name}`))
	end

	registerNPC(name, {
		QuestInfo = questInfo,
		DialogueCallback = dialogueCallback,
		IdleAnimationId = idleAnimationId
	}) -- equivalent call inferred; original call site unknown
end

task.spawn(function()
	local DialoguesList = require(game.ReplicatedStorage.DialoguesList)
	legacyRegisterNPC("Blox Fruit Dealer", function(_)
		return DialoguesList.FruitShop
	end, 2)
	legacyRegisterNPC("Advanced Fruit Dealer", function(_)
		return DialoguesList.FruitShop2
	end, 2)
	legacyRegisterNPC("Weapon Dealer", function(_)
		return DialoguesList.WeaponDealer
	end, 2)
	legacyRegisterNPC("Advanced Weapon Dealer", function(_)
		return DialoguesList.AdvancedWeaponDealer
	end, 2)
	legacyRegisterNPC("Party Shop", function(_)
		return DialoguesList.PartyShop
	end, 2)
	legacyRegisterNPC("Valentine Shop", function(_)
		return DialoguesList.PartyShop
	end, 2)
	legacyRegisterNPC("Sword Dealer", function(_)
		return DialoguesList.SwordDealer1
	end, 2)
	legacyRegisterNPC("Easter Shop", function(_)
		return DialoguesList.PartyShop
	end, 2)
	legacyRegisterNPC("Sword Dealer of the West", function(_)
		return DialoguesList.SwordDealer2
	end, 2)
	legacyRegisterNPC("Sword Dealer of the East", function(_)
		return DialoguesList.SwordDealer3
	end, 2)
	legacyRegisterNPC("Master Sword Dealer", function(_)
		return DialoguesList.SwordDealer4
	end, 2)
	legacyRegisterNPC("Living Skeleton", function(_)
		return DialoguesList.SwordDealer5
	end, 2)
	legacyRegisterNPC("Boat Dealer", function(_)
		return DialoguesList.BoatDealer
	end, 2)
	legacyRegisterNPC("Marines Boat Dealer", function(_)
		return DialoguesList.BoatDealerMarines
	end, 2)
	legacyRegisterNPC("Advanced Marines Boat Dealer", function(_)
		return DialoguesList.BoatDealerMarines2
	end, 2)
	legacyRegisterNPC("Luxury Boat Dealer", function(_)
		return DialoguesList.LuxuryBoatDealer
	end, 2)
	legacyRegisterNPC("Dark Step Teacher", function(_)
		return DialoguesList.BlackLegTeacher
	end, 2)
	legacyRegisterNPC("Ability Teacher", function(_)
		return DialoguesList.HakiTeacher
	end, 2)
	legacyRegisterNPC("Mad Scientist", function(_)
		return DialoguesList.ElectroTeacher
	end, 2)
	legacyRegisterNPC("Instinct Teacher", function(_)
		return DialoguesList.KenTeacher
	end, 2)
	legacyRegisterNPC("Water Kung-fu Teacher", function(_)
		return DialoguesList.FishmanKarateTeacher
	end, 2)
	legacyRegisterNPC("Cupid Valentine Quest Giver", function(_)
		return DialoguesList.Cupid_ValentineDailyQuests
	end, 1)
	legacyRegisterNPC("Pirate Recruiter", function(_)
		return DialoguesList.JoinPirates
	end, 4)
	legacyRegisterNPC("Marine Recruiter", function(_)
		return DialoguesList.JoinMarines
	end, 4)
	legacyRegisterNPC("Set Home Point", function(_)
		return DialoguesList.SpawnPoint
	end, 4)
	legacyRegisterNPC("Indra", function(_)
		return DialoguesList.Indra
	end, 4)
	legacyRegisterNPC("Sick Man", function(_)
		return DialoguesList.SickMan
	end, 4)
	legacyRegisterNPC("Rich Man", function(_)
		return DialoguesList.RichMan
	end, 4)
	legacyRegisterNPC("Yoshi", function(_)
		return DialoguesList.Yoshi
	end, 2)
	legacyRegisterNPC("Parlus", function(_)
		return DialoguesList.Parlus
	end, 2)
	legacyRegisterNPC("Hasan", function(_)
		return DialoguesList.Hasan
	end, 4)
	legacyRegisterNPC("Desert Merchant", function(_)
		return DialoguesList.DesertMerchant
	end, 4)
	legacyRegisterNPC("Remove Blox Fruit", function(_)
		return DialoguesList.FruitRemover
	end, 2)
	registerNPC("Robotmega", {
		QuestInfo = Config.QuestInfo.MISC,
		IgnoreIdleAnimation = true,
		DisableAnimations = true,
		DialogueCallback = function()
			return DialoguesList.Robotmega
		end
	}) -- equivalent call inferred; original call site unknown
	registerNPC("robotmega superfan", {
		QuestInfo = Config.QuestInfo.MISC,
		DisplayName = "Janus",
		Class = "DevBros",
		DialogueStaging = StagingMarks["robotmega superfan"],
		DialogueCallback = function()
			return {
				Title = "Janus",
				Get = function()
					return {
						Text = { "[The quest dialogue is still loading.]" }
					}
				end
			}
		end
	}) -- equivalent call inferred; original call site unknown
	registerNPC("ZiolesShadow", {
		QuestInfo = Config.QuestInfo.MISC,
		IgnoreIdleAnimation = true,
		DisableAnimations = true,
		IgnoreName = true,
		DisplayName = "Zioles",
		DialogueCallback = function()
			return ZiolesShadow
		end
	}) -- equivalent call inferred; original call site unknown
	legacyRegisterNPC("Love Letter 1", function(_)
		return DialoguesList.LoveLetter1
	end, 4)
	legacyRegisterNPC("Love Letter 2", function(_)
		return DialoguesList.LoveLetter2
	end, 4)
	legacyRegisterNPC("Love Letter 3", function(_)
		return DialoguesList.LoveLetter3
	end, 4)
	legacyRegisterNPC("Military Detective", function(_)
		return DialoguesList.Detective
	end, 4)
	legacyRegisterNPC("Experienced Captain", function(_)
		return DialoguesList.TravelDressrosa
	end, 4)
	legacyRegisterNPC("Sea Captain", function(_)
		return DialoguesList.TravelMain
	end, 4)
	legacyRegisterNPC("Pirate Adventurer", function(_)
		return DialoguesList.BuggyQuest1
	end, 1)
	legacyRegisterNPC("Bandit Quest Giver", function(_)
		return DialoguesList.BanditQuest1
	end, 1)
	legacyRegisterNPC("Adventurer", function(_)
		return DialoguesList.JungleQuest
	end, 1)
	legacyRegisterNPC("Desert Adventurer", function(_)
		return DialoguesList.DesertQuest
	end, 1)
	legacyRegisterNPC("Villager", function(_)
		return DialoguesList.SnowQuest
	end, 1)
	legacyRegisterNPC("Marine Leader", function(_)
		return DialoguesList.MarineQuest
	end, 1)
	legacyRegisterNPC("Sky Adventurer", function(_)
		return DialoguesList.SkyQuest
	end, 1)
	legacyRegisterNPC("Marine", function(_)
		return DialoguesList.MarineQuest2
	end, 1)
	legacyRegisterNPC("Colosseum Quest Giver", function(_)
		return DialoguesList.ColosseumQuest
	end, 1)
	legacyRegisterNPC("Jail Keeper", function(_)
		return DialoguesList.PrisonerQuest
	end, 1)
	legacyRegisterNPC("Head Jailer", function(_)
		return DialoguesList.ImpelQuest
	end, 1)
	legacyRegisterNPC("The Mayor", function(_)
		return DialoguesList.MagmaQuest
	end, 1)
	legacyRegisterNPC("King Neptune", function(_)
		return DialoguesList.FishmanQuest
	end, 1)
	legacyRegisterNPC("Mole", function(_)
		return DialoguesList.SkyExp1Quest
	end, 1)
	legacyRegisterNPC("Sky Quest Giver 2", function(_)
		return DialoguesList.SkyExp2Quest
	end, 1)
	legacyRegisterNPC("Angel Guard", function(_)
		return DialoguesList.AngelGuard
	end, 4)
	legacyRegisterNPC("Freezeburg Quest Giver", function(_)
		return DialoguesList.FountainQuest
	end, 1)
	legacyRegisterNPC("Bartilo", function(_)
		return DialoguesList.Bartilo
	end, 1)
	legacyRegisterNPC("Bounty/Honor Expert", function(_)
		return DialoguesList.BountyHonorExpert
	end, 4)
	legacyRegisterNPC("Manager", function(_)
		return DialoguesList.Manager
	end, 4)
	legacyRegisterNPC("Customer", function(_)
		return DialoguesList.Customer
	end, 4)
	legacyRegisterNPC("Nerd", function(_)
		return DialoguesList.Nerd
	end, 4)
	legacyRegisterNPC("Secrets Master", function(_)
		return DialoguesList.SecretsMaster
	end, 4)
	legacyRegisterNPC("Alchemist", function(_)
		return DialoguesList.Alchemist
	end, 4)
	legacyRegisterNPC("Legendary Sword Dealer", function(_)
		return DialoguesList.LegendarySwordDealer
	end, 2)
	legacyRegisterNPC("arowe", function(_)
		return DialoguesList.Wenlocktoad
	end, 4)
	legacyRegisterNPC("The Strongest God", function(_)
		return DialoguesList.Usoapp
	end, 2)
	legacyRegisterNPC("Sabi", function(_)
		return DialoguesList.Sabi
	end, 4)
	legacyRegisterNPC("Cyborg", function(_)
		return DialoguesList.Cyborg
	end, 4)
	legacyRegisterNPC("tort", function(_)
		return DialoguesList.tort
	end, 2)
	legacyRegisterNPC("Plokster", function(_)
		return DialoguesList.Plokster
	end, 2)
	legacyRegisterNPC("Trevor", function(_)
		return DialoguesList.Trevor
	end, 4)
	legacyRegisterNPC("Mysterious Man", function(_)
		return DialoguesList.MysteriousMan
	end, 4)
	legacyRegisterNPC("Martial Arts Master", function(_)
		return DialoguesList.MartialArtsMaster
	end, 4)
	legacyRegisterNPC("Phoeyu, the Reformed", function(_)
		return DialoguesList.DeathStepTeacher
	end, 4)
	legacyRegisterNPC("Mysterious Scientist", function(_)
		return DialoguesList.MysteriousScientist
	end, 4)
	legacyRegisterNPC("arlthmetic", function(_)
		return DialoguesList.junior
	end, 4)
	legacyRegisterNPC("Mysterious Entity", function(_)
		return DialoguesList.MysteriousEntity
	end, 4)
	legacyRegisterNPC("Crew Captain", function(_)
		return DialoguesList.FamousPirate
	end, 4)
	legacyRegisterNPC("Awakenings Expert", function(_)
		return DialoguesList.AwakeningsExpert
	end, 4)
	legacyRegisterNPC("Doghouse", function(_)
		if workspace:GetAttribute("DogHouseAdminAbuseActive") == true then
			return DialoguesList.Indra
		end

		return DialoguesList.DoghouseSpike
	end, 4)
	legacyRegisterNPC("Aura Editor", function(_)
		return DialoguesList.EnhancementEditor
	end, 4)
	legacyRegisterNPC("Guashiem", function(_)
		return DialoguesList.EctoplasmChecker
	end, 4)
	legacyRegisterNPC("El Rodolfo", function(_)
		return DialoguesList.Ectoplasm1
	end, 4)
	legacyRegisterNPC("El Perro", function(_)
		return DialoguesList.Ectoplasm2
	end, 4)
	legacyRegisterNPC("El Admin", function(_)
		return DialoguesList.Ectoplasm3
	end, 4)
	legacyRegisterNPC("Experimic", function(_)
		return DialoguesList.GhoulGiver
	end, 4)
	legacyRegisterNPC("Titles Specialist", function(_)
		return DialoguesList.TitlesSpecialist
	end, 4)
	legacyRegisterNPC("rip_indra", function(_)
		return DialoguesList.rip_indra
	end, 4)
	legacyRegisterNPC("Blox Fruit Gacha", function(_)
		return DialoguesList.RandomFruitSeller
	end, 2)
	legacyRegisterNPC("Shady Zioles", nil, 5)
	legacyRegisterNPC("Party Gacha", function(_)
		return DialoguesList.CelebrationGacha
	end, 2)
	legacyRegisterNPC("Sharkman Teacher", function(_)
		return DialoguesList.SharkmanTeacher
	end, 4)
	legacyRegisterNPC("Barista Cousin", function(_)
		return DialoguesList.MasterOfEnhancement
	end, 2)
	legacyRegisterNPC("Thunder God", function(_)
		return DialoguesList.ThunderGod
	end, 2)
	legacyRegisterNPC(" ", function(_)
		return DialoguesList.CyborgTrainer
	end, 4)
	legacyRegisterNPC("King Red Head", function(_)
		return DialoguesList.RedHead
	end, 4)
	legacyRegisterNPC("Mr. Captain", function(_)
		return DialoguesList.TravelZou
	end, 4)
	legacyRegisterNPC("Elite Hunter", function(_)
		return DialoguesList.EliteHunter
	end, 4)
	legacyRegisterNPC("Player Hunter", function(_)
		return DialoguesList.PlayerHunter
	end, 4)
	legacyRegisterNPC("Butler", function(_)
		return DialoguesList.Butler
	end, 4)
	legacyRegisterNPC("Hungry Man", function(_)
		return DialoguesList.ObservationV2
	end, 4)
	legacyRegisterNPC("Lunoven", function(_)
		return DialoguesList.Lunoven
	end, 4)
	legacyRegisterNPC("Tacomura", function(_)
		return DialoguesList.Tacomura
	end, 4)
	legacyRegisterNPC("erin", function(_)
		return DialoguesList.Flashback
	end, 4)
	legacyRegisterNPC("layandikit12", function(_)
		return DialoguesList.layandikit12
	end, 4)
	legacyRegisterNPC("Citizen", function(_)
		return DialoguesList.Citizen
	end, 1)
	legacyRegisterNPC("Previous Hero", function(_)
		return DialoguesList.PreviousHero
	end, 4)
	legacyRegisterNPC("Horned Man", function(_)
		return DialoguesList.HornedMan
	end, 1)
	legacyRegisterNPC("Arena Trainer", function(_)
		return DialoguesList.ArenaTrainer
	end, 1)
	legacyRegisterNPC("Magic Elf", function(_)
		return DialoguesList.Xmas1
	end, 2)
	legacyRegisterNPC("Greedy Elf", function(_)
		return DialoguesList.Xmas2
	end, 2)
	legacyRegisterNPC("Santa Claws", function(_)
		return DialoguesList.Xmas3
	end, 2)
	legacyRegisterNPC("Death King", function(_)
		return DialoguesList.Halloween1
	end, 4)
	legacyRegisterNPC("Mysterious Force", function(_)
		return DialoguesList.TempleTeleport
	end, 4)
	legacyRegisterNPC("Valentines Delivery", function(_)
		return DialoguesList.StartValentinesDelivery
	end, 1)
	legacyRegisterNPC("Mysterious Force3", function(_)
		return DialoguesList.TempleTeleportBack
	end, 4)
	legacyRegisterNPC("Blacksmith", function(_)
		return DialoguesList.Blacksmith
	end, 4)
	legacyRegisterNPC("Crypt Master", function(_)
		return DialoguesList.CryptMaster
	end, 4)
	legacyRegisterNPC("Ancient One", function(_)
		return DialoguesList.RaceV4Upgrader
	end, 4)
	legacyRegisterNPC("Dragon Talon Sage", function(_)
		return DialoguesList.Scroll
	end, 2)
	legacyRegisterNPC("Uzoth", function(_)
		return DialoguesList.TalonTeacher
	end, 4)
	legacyRegisterNPC("Dragon Hunter", function(_)
		return DialoguesList.DragonHunter
	end, 4)
	legacyRegisterNPC("Dojo Trainer", function(_)
		return DialoguesList.DojoTrainer
	end, 4)
	legacyRegisterNPC("Dragon Tamer", function(_)
		return DialoguesList.DragonTamer
	end, 2)
	legacyRegisterNPC("Sealed King", function(_)
		return DialoguesList.SealedKing
	end, 4)
	legacyRegisterNPC("Gravestone", function(_)
		return DialoguesList.Gravestone
	end, 4)
	legacyRegisterNPC("drip_mama", function(_)
		return DialoguesList.CakeSpawner
	end, 4)
	legacyRegisterNPC("Sweet Crafter", function(_)
		return DialoguesList.SweetChalice
	end, 4)
	legacyRegisterNPC("Cake Scientist", function(_)
		return DialoguesList.CakeScientist
	end, 4)
	legacyRegisterNPC("Sick Scientist", function(_)
		return DialoguesList.SickScientist
	end, 4)
	legacyRegisterNPC("Ghost", function(_)
		return DialoguesList.GhostPuzzle
	end, 4)
	legacyRegisterNPC("Skeleton Machine", function(_)
		return DialoguesList.SkeletonMachine
	end, 4)
	legacyRegisterNPC("Ancient Monk", function(_)
		return DialoguesList.GodhumanTeacher
	end, 4)
	legacyRegisterNPC("Shafi", function(_)
		return DialoguesList.SanguineTeacher
	end, 4)
	legacyRegisterNPC("Spy", function(_)
		return DialoguesList.Spy
	end, 4)
	legacyRegisterNPC("Shark Hunter", function(_)
		return DialoguesList.SharkHunter
	end, 2)
	legacyRegisterNPC("Beast Hunter", function(_)
		return DialoguesList.BeastHunter
	end, 2)
	legacyRegisterNPC("Fossil Expert", function(_)
		return DialoguesList.FossilExpert
	end, 2)
	legacyRegisterNPC("Area 1 Quest Giver", function(_)
		return DialoguesList.Area1Quest
	end, 1)
	legacyRegisterNPC("Area 2 Quest Giver", function(_)
		return DialoguesList.Area2Quest
	end, 1)
	legacyRegisterNPC("Marine Quest Giver", function(_)
		return DialoguesList.MarineQuest3
	end, 1)
	legacyRegisterNPC("Graveyard Quest Giver", function(_)
		return DialoguesList.ZombieQuest
	end, 1)
	legacyRegisterNPC("Snow Quest Giver", function(_)
		return DialoguesList.SnowMountainQuest
	end, 1)
	legacyRegisterNPC("Ice Quest Giver", function(_)
		return DialoguesList.IceSideQuest
	end, 1)
	legacyRegisterNPC("Fire Quest Giver", function(_)
		return DialoguesList.FireSideQuest
	end, 1)
	legacyRegisterNPC("Rear Crew Quest Giver", function(_)
		return DialoguesList.ShipQuest1
	end, 1)
	legacyRegisterNPC("Front Crew Quest Giver", function(_)
		return DialoguesList.ShipQuest2
	end, 1)
	legacyRegisterNPC("Frost Quest Giver", function(_)
		return DialoguesList.FrostQuest
	end, 1)
	legacyRegisterNPC("Forgotten Quest Giver", function(_)
		return DialoguesList.ForgottenQuest
	end, 1)
	legacyRegisterNPC("Pirate Port Quest Giver", function(_)
		return DialoguesList.PiratePortQuest
	end, 1)
	legacyRegisterNPC("Dragon Crew Quest Giver", function(_)
		return DialoguesList.DragonCrewQuest
	end, 1)
	legacyRegisterNPC("Hydra Town Quest Giver", function(_)
		return DialoguesList.VenomCrewQuest
	end, 1)
	legacyRegisterNPC("Marine Tree Quest Giver", function(_)
		return DialoguesList.MarineTreeIsland
	end, 1)
	legacyRegisterNPC("Deep Forest Quest Giver", function(_)
		return DialoguesList.DeepForestIsland
	end, 1)
	legacyRegisterNPC("Deep Forest Area 2 Quest Giver", function(_)
		return DialoguesList.DeepForestIsland2
	end, 1)
	legacyRegisterNPC("Turtle Adventure Quest Giver", function(_)
		return DialoguesList.DeepForestIsland3
	end, 1)
	legacyRegisterNPC("Haunted Castle Quest Giver 1", function(_)
		return DialoguesList.HauntedQuest1
	end, 1)
	legacyRegisterNPC("Haunted Castle Quest Giver 2", function(_)
		return DialoguesList.HauntedQuest2
	end, 1)
	legacyRegisterNPC("Peanut Quest Giver", function(_)
		return DialoguesList.NutsIslandQuest
	end, 1)
	legacyRegisterNPC("Ice Cream Quest Giver", function(_)
		return DialoguesList.IceCreamIslandQuest
	end, 1)
	legacyRegisterNPC("Cake Quest Giver 1", function(_)
		return DialoguesList.CakeQuest1
	end, 1)
	legacyRegisterNPC("Cake Quest Giver 2", function(_)
		return DialoguesList.CakeQuest2
	end, 1)
	legacyRegisterNPC("Chocolate Quest Giver 1", function(_)
		return DialoguesList.ChocQuest1
	end, 1)
	legacyRegisterNPC("Chocolate Quest Giver 2", function(_)
		return DialoguesList.ChocQuest2
	end, 1)
	legacyRegisterNPC("Candy Cane Quest Giver", function(_)
		return DialoguesList.CandyQuest1
	end, 1)
	legacyRegisterNPC("Tiki Quest Giver 1", function(_)
		return DialoguesList.TikiQuest1
	end, 1)
	legacyRegisterNPC("Tiki Quest Giver 2", function(_)
		return DialoguesList.TikiQuest2
	end, 1)
	legacyRegisterNPC("Tiki Quest Giver 3", function(_)
		return DialoguesList.TikiQuest3
	end, 1)
	legacyRegisterNPC("Submerged Quest Giver 1", function(_)
		return DialoguesList.SubmergedQuest1
	end, 1)
	legacyRegisterNPC("Submerged Quest Giver 2", function(_)
		return DialoguesList.SubmergedQuest2
	end, 1)
	legacyRegisterNPC("Submerged Quest Giver 3", function(_)
		return DialoguesList.SubmergedQuest3
	end, 1)
	legacyRegisterNPC("Frozen Watcher", function(_)
		return DialoguesList.LeviathanGate
	end, 1)
	legacyRegisterNPC("Draco Statue", function(_)
		return DialoguesList.DracoStatue
	end, 4)
	legacyRegisterNPC("Divine", function(_)
		return DialoguesList.Divine
	end, 4)
	legacyRegisterNPC("Barista", function(_)
		return DialoguesList.Barista
	end, 2)
	legacyRegisterNPC("Tournament Master", function(_)
		return DialoguesList.FishTournamentNpc
	end, 1)
	legacyRegisterNPC("Rip Family Recruiter", function(_)
		return DialoguesList.RipRecruiter
	end, 4)
	legacyRegisterNPC("Red Army Recruiter", function(_)
		return DialoguesList.RedRecruiter
	end, 1)

	if Flags.SUBCLASSES_ENABLED == true then
		if Flags.SUBCLASSES.Shipwright then
			legacyRegisterNPC("Shipwright Teacher", function(_)
				return DialoguesList.ShipwrightNPC
			end, 4)
		end

		if Flags.SUBCLASSES.Helmsman then
			legacyRegisterNPC("Helmsman Teacher", function(_)
				return DialoguesList.HelmsmanNPC
			end, 4)
		end
	end

	legacyRegisterNPC("Trinket Expert", function(_)
		return DialoguesList.MergeNPC
	end, 4)
	legacyRegisterNPC("Trinket Refiner", function(_)
		return DialoguesList.ReforgeNPC
	end, 4)
	legacyRegisterNPC("Dragon Wizard", function(_)
		return DialoguesList.DragonWizard
	end, 4, 2)
	registerNPC("DojoHiddenRoom", {
		QuestInfo = Config.QuestInfo.MISC,
		Class = "HiddenRoom",
		IgnoreName = true,
		IgnoreWatch = true,
		NoAura = true,
		DialogueCallback = function()
			return DialoguesList.DojoHiddenRoom
		end
	}) -- equivalent call inferred; original call site unknown
	legacyRegisterNPC("Secret Santa", function(_)
		return DialoguesList.SecretSanta
	end, 1)
	legacyRegisterNPC("Witch", function(_)
		return DialoguesList.HalloweenWitch
	end, 4)
	legacyRegisterNPC("Halloween Gacha Dealer", function(_)
		return DialoguesList.HalloweenGachaDealer
	end, 2)
	legacyRegisterNPC("Valentines Gacha Dealer", function(_)
		return DialoguesList.ValentinesGachaDealer
	end, 2)
	legacyRegisterNPC("Luckymaxer", function(_)
		return DialoguesList.AprilFoolsLuckmax
	end, 5)
	legacyRegisterNPC("Colosseum Emperor", function(_)
		return DialoguesList.ColosseumEmperor
	end, 4)
end)
local v2 = {
	new = legacyRegisterNPC
}
local NPCTable = require(game.ReplicatedStorage.NPCTable)
NPCTable.connect(v2)
task.spawn(function()
	local replicatedStorage = game:WaitForChild("ReplicatedStorage", 999)
	task.spawn(function()
		local SubmarineTransportationController = require(game.ReplicatedStorage.Controllers.SubmarineTransportationController)

		if SubmarineTransportationController.Enabled then
			SubmarineTransportationController.InitializeNPC(v2)
		end
	end)
	task.spawn(function()
		local OniTempleController = require(game.ReplicatedStorage.Controllers.MapServices.OniTempleController)

		if OniTempleController.Enabled then
			OniTempleController.InitializeNPC(v2)
		end
	end)
	task.spawn(function()
		local fishReplicated = replicatedStorage and replicatedStorage:WaitForChild("FishReplicated", 999)
		local nPCFishClient = fishReplicated and fishReplicated:WaitForChild("NPCFishClient", 999)

		if nPCFishClient then
			local module = require(nPCFishClient)
			module.InitializeNPC(v2)
		end
	end)
	task.spawn(function()
		local NPCTable2 = require(game.ReplicatedStorage.NPCTable)
		NPCTable2.connect(v2)
	end)
end)
return {
	List = list,
	new = registerNPC,
	legacy = legacyRegisterNPC
}