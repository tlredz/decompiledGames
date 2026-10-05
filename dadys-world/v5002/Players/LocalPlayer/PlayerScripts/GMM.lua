local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local events = ReplicatedStorage:WaitForChild("Events")
events:WaitForChild("GeneratorUpdate")
local skillcheckUpdate = events:WaitForChild("SkillcheckUpdate")
ReplicatedStorage:FindFirstChild("Towers")
local localPlayer = Players.LocalPlayer
local screenGui = localPlayer.PlayerGui:WaitForChild("ScreenGui")
local modules = screenGui:WaitForChild("Modules")

local function safeInit(p, callback)
	local success, result = pcall(callback)

	if not success then
		warn(string.format("[GMM bootstrap] %s init failed: %s", p, (tostring(result))))
	end

	return success
end

local CircleSkillCheckHandler = require(ReplicatedStorage.Modules.Gameplay.CircleSkillCheckHandler)
local GingerHealNotification = require(ReplicatedStorage.Modules.UI.GingerHealNotification)
local GingerPromptController = require(ReplicatedStorage.Modules.ClientUI.GingerPromptController)
local GuiAnimations = require(ReplicatedStorage.Modules.UI.GuiAnimations)
local HealTargetController = require(ReplicatedStorage.Modules.ClientUI.HealTargetController)
local SquirmHoldController = require(ReplicatedStorage.Modules.ClientUI.SquirmHoldController)
local StickerController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ClientUI"):WaitForChild("StickerController"))
local tweens = require(ReplicatedStorage.Modules.Utils.tweens)
require(ReplicatedStorage.SharedData.HolidayEventConfig)
local sharedUtils = ReplicatedStorage:FindFirstChild("SharedUtils")
local hapticEffectsController

if sharedUtils and sharedUtils:FindFirstChild("HapticEffectsController") then
	local success
	success, hapticEffectsController = pcall(require, sharedUtils.HapticEffectsController)

	if not success then
		hapticEffectsController = nil
	end
end

task.spawn(StickerController.init)
task.spawn(GingerHealNotification.init)
local GridScaleSetting = require(modules:WaitForChild("GridScaleSetting"))
GridScaleSetting:Start()
local LoadingScreenController = require(ReplicatedStorage.Modules.ClientUI.LoadingScreenController)
LoadingScreenController.setupAll()
screenGui.SelectionFrame.Visible = workspace.Info.Voting.Value == true
local Floor0ShopClient = require(ReplicatedStorage.Modules.Floor0.Floor0ShopClient)
local Floor0Shop = require(ReplicatedStorage.Modules.Floor0.Floor0Shop)
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
GameContext.init({
	Player = localPlayer,
	Gui = screenGui,
	Character = localPlayer.Character
})
local success, result = pcall(function()
	local GlobalMessageController = require(ReplicatedStorage.Modules.ClientUI.GlobalMessageController)
	GlobalMessageController.setup()
end)

if not success then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "GlobalMessageController", (tostring(result))))
end

for _, uIStroke in pairs(screenGui:GetDescendants()) do
	if uIStroke:IsA("UIStroke") and uIStroke.StrokeSizingMode ~= Enum.StrokeSizingMode.ScaledSize then
		uIStroke.Thickness = 2 * (workspace.CurrentCamera.ViewportSize.X / 1920)
	end
end

local v = { Enum.CoreGuiType.Backpack, Enum.CoreGuiType.ExperienceShop, Enum.CoreGuiType.Health }
task.spawn(function()
	for _, v2 in ipairs(v) do
		local v3 = false

		while not v3 do
			local v4 = v2
			v3 = pcall(function()
				StarterGui:SetCoreGuiEnabled(v4, false)
			end)

			if not v3 then
				task.wait(0.3)
			end
		end
	end
end)
task.spawn(function()
	local bottomLeftCorner = screenGui:WaitForChild("Menu"):WaitForChild("BottomLeftCorner")
	local trinkets = bottomLeftCorner:WaitForChild("Trinkets")
	local staminaBin = bottomLeftCorner:WaitForChild("Status"):WaitForChild("Bottom"):WaitForChild("StaminaBin")
	local staminaFrameBG = staminaBin:WaitForChild("StaminaFrameBG")
	local infoBin = staminaBin:WaitForChild("InfoBin")
	local trinketSlot1 = trinkets:WaitForChild("TrinketSlot1")
	trinketSlot1.Visible = false
	local trinketSlot2 = trinkets:WaitForChild("TrinketSlot2")
	trinketSlot2.Visible = false
	local staminaFrame = staminaFrameBG:WaitForChild("StaminaFrame")
	staminaFrame.Visible = false
	staminaFrameBG.Visible = false
	local pointFrame = infoBin:WaitForChild("PointBin"):WaitForChild("PointFrame")
	pointFrame.Visible = false
	local healthBin = infoBin:WaitForChild("HealthBin")
	healthBin.Visible = false
	local slot1 = screenGui:WaitForChild("Slot1")
	slot1.Visible = false
	local slot2 = screenGui:WaitForChild("Slot2")
	slot2.Visible = false
	local slot3 = screenGui:WaitForChild("Slot3")
	slot3.Visible = false
	local viewStats = screenGui:WaitForChild("ViewStats")
	viewStats.Visible = false
end)
local QuickLinksInitializer = require(ReplicatedStorage.Modules.ClientUI.QuickLinksInitializer)
local resolved = QuickLinksInitializer.resolve()
local quickLinks = resolved.QuickLinks
local readyUpButton = resolved.readyUpButton
local roundTimer = resolved.roundTimer
local trinketSlot1 = resolved.trinketSlot1
local Floor0VotingController = require(ReplicatedStorage.Modules.ClientUI.Floor0VotingController)
Floor0VotingController.init({
	floor0Shop = Floor0Shop
})
Floor0VotingController.setupEventListeners()
Floor0VotingController.setReadyUpButton(readyUpButton)
Floor0VotingController.setRoundTimer(roundTimer)
Floor0VotingController.setQuickLinks(quickLinks)
local success2, result2 = pcall(function()
	local MessagingController = require(ReplicatedStorage.Modules.ClientUI.MessagingController)
	MessagingController.setup()
end)

if not success2 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "MessagingController", (tostring(result2))))
end

function GameContext.updateTextWithDropSupport(instance, text)
	if not instance then
		return
	end

	instance.Text = text

	if instance:GetAttribute("HasDropText") then
		local hasDropText = instance:GetAttribute("HasDropText")
		local child = instance.Parent:FindFirstChild(hasDropText)

		if child then
			child.Text = text
		end
	end
end

local populate = nil
local ToonCatalogController = require(ReplicatedStorage.Modules.ClientUI.ToonCatalogController)
ToonCatalogController.init({
	tweens = tweens
})
local populate2 = ToonCatalogController.populate
Floor0VotingController.setupVotingConnection()

function GameContext.setupCatalogSearchListeners()
	local CatalogSearchController = require(ReplicatedStorage.Modules.ClientUI.CatalogSearchController)
	CatalogSearchController.setupTabSearchBars()
end

GameContext.floor0ShopApi = Floor0VotingController.setupFloor0Shop({
	Floor0ShopClient = Floor0ShopClient,
	TextMessage = GameContext.TextMessage,
	ErrorMessage = GameContext.ErrorMessage,
	ClearTextMessages = GameContext.ClearTextMessages,
	GuiAnimations = GuiAnimations
})

if workspace.Info.Voting.Value == true then
	Floor0VotingController.setupEssentialConnections()
	GameContext.floor0ShopApi.setupFloor0Shop()
	task.spawn(function()
		local v2 = tick() + 5

		while not (populate2 and populate) and tick() < v2 do
			task.wait(0.1)
		end

		if populate2 then
			populate2()
		else
			warn("[GMM] ensureToonCatalogPopulated still nil after 5s — Toon catalog will not auto-populate")
		end

		if populate then
			populate()
		else
			warn("[GMM] ensureTrinketCatalogPopulated still nil after 5s — Trinket catalog will not auto-populate")
		end
	end)
end

Floor0VotingController.setupReadyStateListeners()

repeat
	task.wait()
until pcall(function()
	StarterGui:SetCore("ResetButtonCallback", false)
end)

local playerData = ReplicatedStorage:WaitForChild("PlayerData")
local child = playerData:FindFirstChild((tostring(localPlayer.UserId)))

while not child do
	task.wait(0.1)
	child = playerData:FindFirstChild((tostring(localPlayer.UserId)))
end

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local TreadmillTapSkillCheck = require(ReplicatedStorage.Modules.Gameplay.TreadmillTapSkillCheck)

local function fn()
	local InputService = require(ReplicatedStorage.SharedUtils.InputService)
	local savedBinds = {}
	local getKeybinds = events:WaitForChild("GetKeybinds", 5)

	if getKeybinds then
		local success3, result3 = pcall(function()
			return getKeybinds:InvokeServer()
		end)

		if success3 and typeof(result3) == "table" then
			savedBinds = result3
		end
	end

	InputService.Init({
		replicatedData = child,
		savedBinds = savedBinds,
		gui = screenGui,
		getCharacter = function()
			return character
		end
	})
end

local success3, result3 = pcall(fn)

if not success3 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "InputService", (tostring(result3))))
end

local success4, result4 = pcall(function()
	local ProximityPromptInput = require(ReplicatedStorage.SharedUtils.ProximityPromptInput)
	ProximityPromptInput.setup()
end)

if not success4 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "ProximityPromptInput", (tostring(result4))))
end

local SkillCheckController = require(ReplicatedStorage.Modules.ClientUI.SkillCheckController)
SkillCheckController.init({
	haptic = hapticEffectsController,
	circleHandler = CircleSkillCheckHandler,
	treadmillHandler = TreadmillTapSkillCheck
})
local updatePromptText = SkillCheckController.updatePromptText
local hideAllUI = SkillCheckController.hideAllUI
local handleInvoke = SkillCheckController.handleInvoke
GameContext.updateSkillCheckPromptText = updatePromptText
GameContext.hideAllSkillCheckUI = hideAllUI
SkillCheckController.startCleanupLoop()
local AstroMonitorController = require(ReplicatedStorage.Modules.ClientUI.AstroMonitorController)

local function watchMask(character2)
	character2:GetAttributeChangedSignal("MaskToon"):Connect(AstroMonitorController.setup)
	character2:GetAttributeChangedSignal("MaskStatsOnly"):Connect(AstroMonitorController.setup)
	character2:GetAttributeChangedSignal("MaskPassive"):Connect(AstroMonitorController.setup)
end

AstroMonitorController.setup()
watchMask(character)
localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
	AstroMonitorController.setup()
	watchMask(character2)
end)
local equippedTrinket1 = child:WaitForChild("EquippedTrinket1")
local equippedTrinket2 = child:WaitForChild("EquippedTrinket2")
local trinkets = screenGui:WaitForChild("Menu"):WaitForChild("BottomLeftCorner"):WaitForChild("Trinkets")
local trinketSlot12 = trinkets:WaitForChild("TrinketSlot1")
local trinketSlot2 = trinkets:WaitForChild("TrinketSlot2")
local TrinketSlotsUpdater = require(ReplicatedStorage.Modules.ClientUI.TrinketSlotsUpdater)
TrinketSlotsUpdater.init({
	Slot1 = equippedTrinket1,
	Slot2 = equippedTrinket2,
	trinketSlot1 = trinketSlot1,
	trinketSlot1UI = trinketSlot12,
	trinketSlot2UI = trinketSlot2
})
local TrinketCatalogController = require(ReplicatedStorage.Modules.ClientUI.TrinketCatalogController)
TrinketCatalogController.init({
	tweens = tweens
})
populate = TrinketCatalogController.populate
require(modules.CardVote)
local success5, result5 = pcall(function()
	local PanicModeController = require(ReplicatedStorage.Modules.ClientUI.PanicModeController)
	PanicModeController.setupAll()
end)

if not success5 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "PanicModeController", (tostring(result5))))
end

local NewbieGuideController = require(ReplicatedStorage.Modules.ClientUI.NewbieGuideController)
NewbieGuideController.setupAll()
local success6, result6 = pcall(function()
	local EventHandlersController = require(ReplicatedStorage.Modules.ClientUI.EventHandlersController)
	EventHandlersController.setupAll()
end)

if not success6 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "EventHandlersController", (tostring(result6))))
end

local success7, result7 = pcall(function()
	local GuardMarkController = require(ReplicatedStorage.Modules.ClientUI.GuardMarkController)
	GuardMarkController.setupAll()
end)

if not success7 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "GuardMarkController", (tostring(result7))))
end

local success8, result8 = pcall(function()
	local StunFxController = require(ReplicatedStorage.Modules.ClientUI.StunFxController)
	StunFxController.setupAll()
end)

if not success8 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "StunFxController", (tostring(result8))))
end

local success9, result9 = pcall(function()
	local GuardAwarenessController = require(ReplicatedStorage.Modules.ClientUI.GuardAwarenessController)
	GuardAwarenessController.setupAll()
end)

if not success9 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "GuardAwarenessController", (tostring(result9))))
end

local success10, result10 = pcall(function()
	local ShellProjector = require(ReplicatedStorage.Modules.ClientUI.ShellProjector)
	ShellProjector.setupAll()
end)

if not success10 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "ShellProjector", (tostring(result10))))
end

local success11, result11 = pcall(function()
	local AbilityController = require(ReplicatedStorage.Modules.ClientUI.AbilityController)
	AbilityController.init({
		HealTargetController = HealTargetController,
		GingerPromptController = GingerPromptController,
		SquirmHoldController = SquirmHoldController
	})
	AbilityController.setupAll()
end)

if not success11 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "AbilityController", (tostring(result11))))
end

local success12, result12 = pcall(function()
	local CharacterStatsController = require(ReplicatedStorage.Modules.ClientUI.CharacterStatsController)
	CharacterStatsController.init({})
	CharacterStatsController.setupAll()
end)

if not success12 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "CharacterStatsController", (tostring(result12))))
end

local TeamDisplayController = require(ReplicatedStorage.Modules.ClientUI.TeamDisplayController)
TeamDisplayController.init({
	teamFrameTemplate = resolved.teamFrameTemplate,
	quickLinks = quickLinks
})
TeamDisplayController.setupAll()
local CharacterLifecycleController = require(ReplicatedStorage.Modules.ClientUI.CharacterLifecycleController)
CharacterLifecycleController.init({
	circleHandler = CircleSkillCheckHandler,
	treadmillHandler = TreadmillTapSkillCheck,
	onCharacterAdded = function(p)
		character = p
	end,
	getCurrentCharacter = function()
		return character
	end
})
CharacterLifecycleController.setupAll()
CharacterLifecycleController.reconcile()
local LoadoutSlotsController = require(ReplicatedStorage.Modules.ClientUI.LoadoutSlotsController)
LoadoutSlotsController.init({
	ReplicatedData = child,
	GuiAnimations = GuiAnimations
})

function setupGui()
	local TrinketSlotController = require(ReplicatedStorage.Modules.ClientUI.TrinketSlotController)
	TrinketSlotController.setupAll()
	local CurrencyDisplayController = require(ReplicatedStorage.Modules.ClientUI.CurrencyDisplayController)
	CurrencyDisplayController.setupAll(child)
	local GeneratorUIController = require(ReplicatedStorage.Modules.ClientUI.GeneratorUIController)
	GeneratorUIController.init({
		circleHandler = CircleSkillCheckHandler,
		treadmillHandler = TreadmillTapSkillCheck
	})
	GeneratorUIController.setupAll()
	local SprintController = require(ReplicatedStorage.Modules.ClientUI.SprintController)
	SprintController.init({
		gui = screenGui,
		replicatedData = child,
		getCharacter = function()
			return character
		end
	})
	SprintController.start()

	skillcheckUpdate.OnClientInvoke = function(p, p2, p3)
		return handleInvoke(p, p2, p3)
	end
end

local StoryEventsController = require(ReplicatedStorage.Modules.ClientUI.StoryEventsController)
StoryEventsController.init({
	circleHandler = CircleSkillCheckHandler,
	treadmillHandler = TreadmillTapSkillCheck
})
StoryEventsController.setupAll()
local success13, result13 = pcall(function()
	local FloorController = require(ReplicatedStorage.Modules.ClientUI.FloorController)
	FloorController.setupAll()
end)

if not success13 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "FloorController", (tostring(result13))))
end

local setupGui2 = setupGui
local success14, result14 = pcall(setupGui2)

if not success14 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "setupGui", (tostring(result14))))
end

local success15, result15 = pcall(function()
	if GameContext.Update_Stats then
		GameContext.Update_Stats()
	end
end)

if not success15 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "Update_Stats seed", (tostring(result15))))
end

local success16, result16 = pcall(function()
	if GameContext.Update_Slots then
		GameContext.Update_Slots()
	end
end)

if not success16 then
	warn(string.format("[GMM bootstrap] %s init failed: %s", "Update_Slots seed", (tostring(result16))))
end

local CatalogSearchController = require(ReplicatedStorage.Modules.ClientUI.CatalogSearchController)
CatalogSearchController.init({
	quickLinks = quickLinks
})
TeamDisplayController.seedInitialFrames()

-- equivalent calls inferred from this helper; original call sites unknown
local function updateServerMatchDisplay()
	local v2 = "SERVER ID: " .. workspace.Info.ServerID.Value .. "\nMATCH ID: " .. (localPlayer:GetAttribute("CurrentMatchID") or "N/A")
	screenGui.StatsFrame.ServerBox.Text = v2
	screenGui.StatsFrame.ServerBox.PlaceholderText = v2
end

updateServerMatchDisplay() -- equivalent call inferred; original call site unknown
workspace.Info.ServerID.Changed:Connect(updateServerMatchDisplay)
localPlayer:GetAttributeChangedSignal("CurrentMatchID"):Connect(updateServerMatchDisplay)
screenGui.SelectionFrame.Visible = workspace.Info.Voting.Value == true

if character.Parent == workspace.InGamePlayers and GameContext.setupStats then
	GameContext.setupStats()
end