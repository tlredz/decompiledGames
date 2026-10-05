local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local playerGui = Players.LocalPlayer.PlayerGui

local function fn() end

for _, layerCollector in ReplicatedStorage.Assets.ScreenGui:GetChildren() do
	if layerCollector:IsA("LayerCollector") and layerCollector.ResetOnSpawn then
		warn((`ResetOnSpawn is enabled for {layerCollector.ClassName} {layerCollector.Name}!`))
	end

	layerCollector.Parent = playerGui
end

local featuresToggle = ReplicatedStorage.FeaturesToggle

local function MatchesName(p: string)
	return function(instance)
		local featureEnvironment = instance:GetAttribute("FeatureEnvironment")

		if featureEnvironment then
			local child = featuresToggle:FindFirstChild(featureEnvironment)

			if child and not child.Value then
				return false
			end
		end

		return instance.Name:match(p) ~= nil
	end
end

local clientGameModules = ReplicatedStorage.ClientGameModules
local packages = ReplicatedStorage.Packages
local shared = ReplicatedStorage.Shared
local common = ReplicatedStorage.Common
local utilities = common.Utils.Utilities
local v = {
	clientGameModules.TextUtility,
	common.BoostsInfo,
	packages.Freeze,
	packages.Loader,
	packages.Moonlite,
	packages.Net,
	packages.Signal,
	packages.Squash,
	packages.Trove,
	packages.Observers,
	shared.DeepCopy,
	shared.EmoteIds,
	shared.EmoteTypes.Utils.Types,
	shared.FreezeSwordConstraints,
	shared.InfiniteBattlepass.InfiniteBattlepassData.External,
	shared.InstanceSerde,
	shared.Nanoid,
	shared.RNG.PlaytimeLuck,
	shared.Signal,
	shared.Statable,
	shared.SwordAPI,
	shared.t,
	shared.UniverseIds,
	shared.WeightRandom,
	utilities.Thread,
	shared.RNG.Emotes.Types,
	packages.Replion,
	packages.Serialization,
	ReplicatedStorage.ServerInfo,
	shared.DynArgs,
	shared.Statable,
	utilities.Physics,
	clientGameModules.FFlagClient,
	shared.Inventory.InventoryTypes,
	common.StudioLogger,
	common.Utils.Utilities.Statable,
	shared.ReplicatedInstances,
	shared.ReplicatedInstancesUtils,
	shared.Trading.TradeInfo,
	shared.Inventory.Shared,
	shared.Inventory.Client,
	shared.Inventory,
	utilities.FFlag,
	common.Utils,
	shared.EmoteTypes.Utils.Visual,
	common.RewardInfo,
	shared.LTM,
	shared.TournamentEvent.TournamentEventData,
	shared.RankedSeasonData,
	shared.TitleData,
	shared.ReplicatedInstances.EmoteVFX,
	shared.EmoteTypes.EnableAndEmit,
	shared.RNG.Emotes,
	shared.ReplicatedInstances.Booths,
	shared.ReplicatedInstances.Swords,
	shared.ItemInfo,
	shared.ReplicatedInstances.EmoteAccessories,
	shared.EmotesShared,
	utilities.SwordUtil,
	shared.ReplicatedInstances.Explosions,
	shared.ReplicatedInstances.Finishers,
	shared.ReplicatedInstances.SwordFX,
	shared.ReplicatedInstances.SwordAccessories,
	shared.AbilityUtils
}
local controllers = ReplicatedStorage.Controllers
local v2 = {
	controllers.ABTestController,
	controllers.AdminPanel.AdminPanelUIController,
	controllers.AnalyticsController,
	controllers.AnimationController,
	controllers.AntiFlingController,
	controllers.CinematicController,
	controllers.Clans.ClanController,
	controllers.DuelController,
	controllers.Easter.EggDropController,
	controllers.EmoteController,
	controllers.GamepadIconController,
	controllers.HotbarController,
	controllers.KillstreakController,
	controllers.LeaderboardController,
	controllers.Lobby.ProximityPromptController,
	controllers.LocalPlayerFriendedController,
	controllers.LogController,
	controllers.LTM.LobbyCrateController,
	controllers.NotificationController,
	controllers.PromptController,
	controllers.Ranked.RankedPenaltyController,
	controllers.Ranked.RankedSignalController,
	controllers.RankMenuController,
	controllers.ServerTypeController,
	controllers.SinglePass.SinglePassController,
	controllers.Tournaments.TournamentsController,
	controllers.Trading.RAPController,
	controllers.Trading.TradeController,
	controllers.Tutorial.TutorialController,
	controllers.UI.InviteRewardsController,
	controllers.UI.TooltipController,
	controllers.UI.UIStateController,
	controllers.VFXController,
	controllers.WelcomeBackController,
	controllers.DeleteItemPromptController,
	controllers.QuestController,
	controllers.SettingsController,
	controllers.Trading.ExistCounterController,
	controllers.UI.SpectateController,
	controllers.UI.TopBarController,
	controllers.UI.DailyLoginController,
	controllers.ServerSelectionController,
	controllers.ServerBrowserController,
	controllers.Ranked.RankedQueueController,
	controllers.UI.RankedSelectionController,
	controllers.UI.PlaytimeRewardsController,
	controllers["SwordsController \f"],
	controllers.AbilityController,
	controllers.UI.ShopControllerAPI,
	controllers.AutoDeleteItemController,
	controllers.HoverInfoController,
	controllers.Trading.TradeTokensController,
	controllers.GiftingController,
	controllers.Tournaments.Event.TournamentEventController,
	controllers.LimitedTimePackController,
	controllers.Trading.InventoryController,
	controllers.ViewInventoryController,
	controllers.Trading.TradeRequestController,
	controllers.Trading.TradePINCodeController,
	controllers.PlayerProfileController,
	controllers.UI.HUDController,
	controllers.Clans.ClanPageController,
	controllers.Clans.UI.ClanManagerController,
	controllers.Tournaments.UI.TournamentsUIController,
	controllers.Tournaments.UI.TournamentsUIEventController,
	controllers.UI.QuestsController,
	controllers.ShowRoomController,
	controllers.UI.LimitedSwordPacksController,
	controllers.UI.NewShowcaseController,
	controllers.FinishersController,
	controllers.UI.GenericGachaController,
	controllers.Battlepass.BattlepassViewController,
	controllers.Trading.IndexController,
	controllers.Trading.RAPChartController,
	controllers.Battlepass.BattlepassSpinGachaController,
	controllers.EmoteWheelController,
	controllers.UI.ShopController
}
local ControllerIsolator = require(script:WaitForChild("ControllerIsolator"))
local manifest = ControllerIsolator.GetManifest()
local v3 = {}
local v4

if manifest then
	v4 = manifest.IsolatedControllers
else
	v4 = v2
end

for _, v5 in v4 do
	v3[v5] = true
end

local v5 = {}
local v6 = {}

local function LoadIsolated(moduleScript)
	fn("Load isolated", moduleScript)
	local clone = script.IsolatedRequirer:Clone()
	clone.Target.Value = moduleScript
	clone.Name = moduleScript.Name
	clone.Parent = moduleScript
	local lastTime = os.clock()
	clone:SetAttribute("Loaded", nil)
	clone.Enabled = true

	while clone:GetAttribute("Loaded") == nil do
		clone:GetAttributeChangedSignal("Loaded"):Wait()
	end

	v5[moduleScript] = os.clock() - lastTime
	table.insert(v6, moduleScript)
	return require(moduleScript)
end

local function LoadIsolatedController(parent)
	local clone = script.IsolatedControllerRequirer:Clone()
	clone.Name = parent.Name
	clone.Parent = parent
	local lastTime = os.clock()
	parent:SetAttribute("Loaded", nil)
	clone.Enabled = true

	while parent:GetAttribute("Loaded") == nil do
		parent:GetAttributeChangedSignal("Loaded"):Wait()
	end

	v5[parent] = os.clock() - lastTime
	table.insert(v6, parent)
	return require(parent)
end

local function LoadThroughIsolator(p)
	local lastTime = os.clock()
	local v7 = ControllerIsolator.Require(p)
	v5[p] = os.clock() - lastTime
	table.insert(v6, p)
	return v7
end

local function Load(moduleScript)
	local v7 = RunService:IsServer() and 5 or 1
	local thread = task.delay(v7, function()
		task.spawn(error, (`"{moduleScript.Name}" module took more than {v7}s to be required!`))
	end)
	local module = require(moduleScript)

	if coroutine.status(thread) == "suspended" then
		pcall(task.cancel, thread)
	end

	return module
end

local function LoadDescendants(folder, fn2)
	local moduleScripts = {}
	local result = {}

	for _, moduleScript in folder:GetDescendants() do
		if v3[moduleScript] or not moduleScript:IsA("ModuleScript") or not (not fn2 or fn2(moduleScript)) then
			continue
		end

		table.insert(moduleScripts, moduleScript)
	end

	for _, v7 in moduleScripts do
		result[v7] = Load(v7)
	end

	return result
end

fn("Load")

if manifest then
	for _, isolatedModule in manifest.IsolatedModules do
		local lastTime = os.clock()
		ControllerIsolator.Require(isolatedModule)
		v5[isolatedModule] = os.clock() - lastTime
		table.insert(v6, isolatedModule)
	end
else
	for _, v7 in v do
		LoadIsolated(v7)
	end
end

table.sort(v6, function(a, b)
	return v5[a] > v5[b]
end)

for _, v7 in v6 do
	fn(v7, v5[v7])
end

table.clear(v5)
table.clear(v6)
workspace:SetAttribute("ClientModulesLoaded", true)
local Bootstrapper = require(script:WaitForChild("Bootstrapper"))
Bootstrapper:BeforeKnitInit()
local v7 = {}
local v8 = nil

if manifest then
	local v9 = "Controller"

	local function fn2(isolatedController)
		local featureEnvironment = isolatedController:GetAttribute("FeatureEnvironment")

		if featureEnvironment then
			local child = featuresToggle:FindFirstChild(featureEnvironment)

			if child and not child.Value then
				return false
			end
		end

		return isolatedController.Name:match(v9) ~= nil
	end

	v8 = {}

	for _, isolatedController in manifest.IsolatedControllers do
		if not fn2(isolatedController) then
			continue
		end

		local lastTime = os.clock()
		ControllerIsolator.Require(isolatedController)
		v5[isolatedController] = os.clock() - lastTime
		table.insert(v6, isolatedController)
		v8[isolatedController] = true
	end
else
	for _, v9 in v2 do
		v7[v9] = LoadIsolatedController(v9)
	end
end

table.sort(v6, function(a, b)
	return v5[a] > v5[b]
end)

for _, v9 in v6 do
	fn(v9, v5[v9])
end

table.clear(v5)
table.clear(v6)
fn("Load controllers")
local v9 = "Controller"
local loadDescendants = LoadDescendants(ReplicatedStorage.Controllers, function(instance)
	local featureEnvironment = instance:GetAttribute("FeatureEnvironment")

	if featureEnvironment then
		local child = featuresToggle:FindFirstChild(featureEnvironment)

		if child and not child.Value then
			return false
		end
	end

	return instance.Name:match(v9) ~= nil
end)
fn("Init")

local function callInits(items, flag: boolean?)
	for k, item in items do
		if flag then
			k:SetAttribute("Init", false)

			while not k:GetAttribute("Init") do
				k:GetAttributeChangedSignal("Init"):Wait()
			end
		elseif item.Init then
			local success, result = pcall(item.Init, item)

			if not success then
				task.spawn(error, (`{k.Name}:Init() - {result}`))
			end
		end
	end
end

if v8 then
	ControllerIsolator.InitAll(v8)
else
	callInits(v7, true)
end

callInits(loadDescendants)
fn("Start")

local function spawnStarts(items, flag: boolean?)
	for k, item in items do
		if flag then
			k:SetAttribute("Start", false)

			while not k:GetAttribute("Start") do
				k:GetAttributeChangedSignal("Start"):Wait()
			end
		else
			local start = item.Start

			if type(start) == "function" then
				local v11 = k
				local start2 = start
				local v13 = item
				task.spawn(function()
					debug.setmemorycategory(v11.Name)
					start2(v13)
				end)
			end
		end
	end
end

if v8 then
	ControllerIsolator.StartAll(v8)
else
	spawnStarts(v7, true)
end

spawnStarts(loadDescendants)
Bootstrapper:AfterKnitStarted()
workspace:SetAttribute("ClientStarted", true)
fn("Client started")
local Loader = require(ReplicatedStorage.Packages.Loader)
Loader.LoadDescendants(ReplicatedStorage.Observers, function(instance)
	local featureEnvironment = instance:GetAttribute("FeatureEnvironment")

	if featureEnvironment then
		local child = featuresToggle:FindFirstChild(featureEnvironment)

		if child and not child.Value then
			return false
		end
	end

	return true
end)
fn("Loaded observers")
require(ReplicatedStorage.Shared.SharedModifiers)
require(ReplicatedStorage.Shared.SpeedModifiers)
require(ReplicatedStorage.Shared.JumpModifiers)