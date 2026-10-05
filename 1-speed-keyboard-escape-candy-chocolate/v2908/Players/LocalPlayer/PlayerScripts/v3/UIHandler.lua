local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local UpgradeMultipliers = require(ReplicatedStorage._FRAMEWORK.Libraries.UpgradeMultipliers)
local eventShops = require(ReplicatedStorage._FRAMEWORK.Features.eventShops)
local Items = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("Items"))
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
local BoostSystemConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("BoostSystemConfig"))
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local TrailUISystem = require(ReplicatedStorage:WaitForChild("TrailUISystem"))
local AuraUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("AuraUISystem"))
local SettingsUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("SettingsUISystem"))
local TreadmillSkinUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("TreadmillSkinUISystem"))
local TreadmillBundleUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("TreadmillBundleUISystem"))
local revive = require(ReplicatedStorage._FRAMEWORK.Features.revive)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local updateUI = remotes:WaitForChild("UpdateUI")
local showWin = remotes:WaitForChild("ShowWin")
local showPlayerMessage = remotes:WaitForChild("ShowPlayerMessage")
local showGeneralNotification = remotes:WaitForChild("ShowGeneralNotification")
local funnelShop = remotes:WaitForChild("FunnelShop", 5)
local v = {}
local v2 = {}

for _, currency in ipairs(EventsConfig.Currencies) do
	v[currency.Key] = true
end

local function isEventCurrencyOnlyUpdate(items)
	local v3 = false

	for k in pairs(items) do
		if not v[k] then
			return false
		end

		v3 = true
	end

	return v3
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("SoundPackUISystem"))
require(ReplicatedStorage:WaitForChild("ItemRewardUISystem"))
local AscensionUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("AscensionUISystem"))
AscensionUISystem.Start()
require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("NewBadgeSystem"))
require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("CameraUISystem"))
require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("AutoOpenModalSystem"))
require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("BBWorldInfoMessageUISystem"))
require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("InfoModalUISystem"))

local function getUI(tag)
	if v2[tag] and v2[tag].Parent then
		return v2[tag]
	end

	local tagged = CollectionService:GetTagged(tag)

	for _, v3 in ipairs(tagged) do
		if not v3:IsDescendantOf(playerGui) then
			continue
		end

		v2[tag] = v3
		return v3
	end

	return nil
end

local function updateBaseUI()
	local v3 = ClientState:Get()
	local UI = getUI("WinsLabel")
	local UI2 = getUI("SpeedValue")
	local UI3 = getUI("LevelText")
	local UI4 = getUI("XPText")
	local UI5 = getUI("XPBarFill")
	local UI6 = getUI("GamepassMultiplierLabel")
	local UI7 = getUI("RebirthMultiplierLabel")
	local UI8 = getUI("TrailMultiplierLabel")
	local UI9 = getUI("AscendMultiplierLabel")
	local UI10 = getUI("ItemsMultiplierLabel")
	local UI11 = getUI("ItemsMultiplierLabel2")
	local UI12 = getUI("BoomboxMultiplierLabel")
	local UI13 = getUI("CustomSpeedNow")
	local UI14 = getUI("MaxCustomSpeed")
	local UI15 = getUI("TextboxCustomSpeed")
	local UI16 = getUI("Stage15SpeedBoostLabel")
	local world3Stage15Beaten

	if Config.WORLD == 3 then
		world3Stage15Beaten = v3.World3Stage15Beaten
	else
		world3Stage15Beaten = false
	end

	if UI14 then
		local v4

		if world3Stage15Beaten then
			v4 = Config.MAX_LEVEL_SPEED_CAP
		else
			v4 = Config.CalculateMaxSpeed(v3.Level)
		end

		UI14.Text = "Your Max Speed: " .. math.floor(v4)
	end

	if UI15 then
		local v4

		if world3Stage15Beaten then
			v4 = Config.MAX_LEVEL_SPEED_CAP
		else
			v4 = Config.CalculateMaxSpeed(v3.Level)
		end

		UI15.PlaceholderText = math.floor(v4)
	end

	if UI13 then
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChild("Humanoid")
		local walkSpeed = humanoid and humanoid.WalkSpeed or v3.CustomWalkSpeed or Config.DEFAULT_WALKSPEED
		local activeBonus = revive.activeBonus(localPlayer)

		if activeBonus > 0 then
			local v4 = math.max(walkSpeed - activeBonus, 0)
			UI13.Text = string.format("Current: %d + %d - Revive Bonus", math.floor(v4), (math.floor(activeBonus)))
		else
			UI13.Text = "Current speed: " .. math.floor(walkSpeed)
		end
	end

	if UI16 then
		local stage15SpeedBoost = v3.Stage15SpeedBoost or 0
		UI16.Visible = stage15SpeedBoost > 0
		UI16.Text = "+" .. math.floor(stage15SpeedBoost) .. " Speed Boost"
	end

	if UI then
		UI.Text = Numbers.formatNumber(v3.Wins)
	end

	if UI2 then
		UI2.Text = Numbers.formatNumber(v3.TotalXP) .. " " .. Config.GetSpeedLabel()
	end

	if UI3 then
		UI3.Text = "Level " .. v3.Level
	end

	local XP = v3.XP or 0
	local xPRequired = v3.XPRequired or 100

	if UI4 then
		UI4.Text = Numbers.formatNumber(XP) .. " / " .. Numbers.formatNumber(xPRequired)
	end

	if UI6 then
		local currentSpeedTier = v3.CurrentSpeedTier
		local extraSpeedBoostTier = v3.ExtraSpeedBoostTier
		local v4 = not (currentSpeedTier > 0) and 1 or Config.SPEED_UPGRADES[currentSpeedTier].Multiplier
		local v5 = "x" .. Numbers.formatMultiplier(v4)

		if extraSpeedBoostTier > 0 then
			v5 ..= " + x" .. Numbers.formatMultiplier(Config.SPEED_UPGRADES[extraSpeedBoostTier].Multiplier)
		end

		UI6.Text = "Multiplier " .. v5 .. " (" .. (Config.USE_DEVPRODUCT_SPEED and "Speed Boost" or "Gamepass") .. ")"
	end

	if UI7 then
		local rebirths = v3.Rebirths or 0
		local multiplier = rebirths > 0 and Config.REBIRTH_TIERS[rebirths].multiplier or 1
		UI7.Text = "Multiplier x" .. Numbers.formatMultiplier(multiplier) .. " (Rebirth)"
	end

	if UI8 then
		local equippedTrail = v3.EquippedTrail or "None"
		local equippedAura = v3.EquippedAura or "None"
		local trail = UpgradeMultipliers.trail(equippedTrail)
		local aura = UpgradeMultipliers.aura(equippedAura)
		UI8.Text = "Multiplier x" .. Numbers.formatMultiplier(trail * aura) .. " (Trail & Aura)"
	end

	if UI9 then
		local ascensionXpMultiplier = Config.GetAscensionXpMultiplier(v3.GalaxyAscensions)
		UI9.Text = "Multiplier x" .. Numbers.formatMultiplier(ascensionXpMultiplier) .. " (Ascend)"
	end

	local equippedItems = v3.EquippedItems or {}
	local totalBonusPercent = Items.GetTotalBonusPercent(equippedItems)

	if UI10 then
		UI10.Text = "+" .. totalBonusPercent .. "% " .. Config.GetSpeedLabel() .. " (Items)"
	end

	if UI11 then
		UI11.Text = "+" .. totalBonusPercent .. "% " .. Config.GetSpeedLabel()
	end

	if UI12 then
		local v4 = localPlayer:GetAttribute("RELICSxyz_OwnsBoombox") and 2 or 1
		UI12.Text = "Multiplier x" .. Numbers.formatMultiplier(v4) .. " (Boombox)"
	end

	if UI5 then
		local v4 = math.clamp(XP / xPRequired, 0, 1)
		TweenService:Create(UI5, TweenInfo.new(0.15), {
			Size = UDim2.new(v4, 0, 1, 0)
		}):Play()
	end

	for _, v4 in ipairs(CollectionService:GetTagged("UIActionBtn")) do
		if v4:GetAttribute("Action") == "Gift" and v4:IsDescendantOf(playerGui) then
			v4.Visible = not v3.GiftClaimed
		end
	end
end

localPlayer:GetAttributeChangedSignal(revive.bonusAttribute):Connect(function()
	revive.applyLocalWalkSpeed()
	updateBaseUI()
end)
localPlayer:GetAttributeChangedSignal(revive.bonusEndsAttribute):Connect(function()
	revive.applyLocalWalkSpeed()
	updateBaseUI()
end)

local function updateBoostButtonLabels()
	if not BoostSystemConfig.USE_PERCENTAGE_BOOSTS then
		return
	end

	local totalXP = ClientState:Get().TotalXP or 0
	local v3 = {}

	for _, v4 in ipairs(Config.PERCENTAGE_SPEED_BOOSTS or {}) do
		local calculSpeed = BoostSystemConfig.calculSpeed(v4, totalXP)
		v3[v4.Key] = "+" .. BoostSystemConfig.niceFormatNumber(calculSpeed, 2) .. " " .. Config.GetSpeedLabel()
	end

	for _, v4 in ipairs(CollectionService:GetTagged("UIActionBtn")) do
		if not v4:IsDescendantOf(playerGui) then
			continue
		end

		local text = v3[v4:GetAttribute("Action")]

		if not text then
			continue
		end

		local textLabel = v4:FindFirstChildWhichIsA("TextLabel", true)

		if textLabel then
			textLabel.Text = text
		end
	end
end

local updateSpeedBoostButton
local priceInRobuxesByDevProductId = {}
local v3 = {}

local function getSpeedUpgradePrice(data)
	local devProductId, product

	if Config.USE_DEVPRODUCT_SPEED and data.DevProductId and data.DevProductId ~= 0 then
		devProductId = data.DevProductId
		product = Enum.InfoType.Product
	else
		devProductId = data.ID
		product = Enum.InfoType.GamePass
	end

	if priceInRobuxesByDevProductId[devProductId] then
		return priceInRobuxesByDevProductId[devProductId]
	end

	if not v3[devProductId] then
		v3[devProductId] = true
		task.spawn(function()
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfoAsync(devProductId, product)
			end)
			priceInRobuxesByDevProductId[devProductId] = success and result and result.PriceInRobux or data.Price
			v3[devProductId] = nil
			updateSpeedBoostButton()
		end)
	end

	return data.Price
end

updateSpeedBoostButton = function()
	local v4 = ClientState:Get()
	local v5 = Config.SPEED_UPGRADES[v4.CurrentSpeedTier + 1]
	local UI = getUI("SpeedTierLabel")
	local UI2 = getUI("SpeedPriceButton")
	local UI3 = getUI("SpeedTierWithExtra")

	if UI3 then
		UI3.Visible = false
	end

	if v5 then
		if UI then
			UI.Visible = true
			UI.Text = v5.Multiplier .. "x " .. Config.GetSpeedLabel()
		end

		if UI2 then
			UI2.Text = "ONLY " .. getSpeedUpgradePrice(v5)
		end
	else
		if UI then
			UI.Visible = true
			UI.Text = "MAX SPEED"
		end

		if UI2 then
			UI2.Text = "OWNED"
			UI2.Active = false
		end
	end
end

local v4 = nil

local function bumpCurrentSpeedLabel()
	local UI = getUI("CustomSpeedNow")

	if not UI then
		return
	end

	local uIScale = UI:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uIScale.Parent = UI

	if v4 then
		v4:Cancel()
	end

	uIScale.Scale = 1.3
	v4 = TweenService:Create(uIScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	})
	v4:Play()
end

local v5 = nil
local v6 = nil
updateUI.OnClientEvent:Connect(function(p)
	if not p then
		return
	end

	local v7 = ClientState:Get()
	local _ = v7.Rebirths or 0
	local _ = v7.Level
	local stage15SpeedBoost = v7.Stage15SpeedBoost or 0
	ClientState:Update(p)

	if stage15SpeedBoost < (p.Stage15SpeedBoost or 0) then
		bumpCurrentSpeedLabel()
	end

	local flag = false

	for k in pairs(p) do
		if v[k] then
			flag = true
		else
			flag = false
			break
		end
	end

	if flag then
		return
	end

	if p.OwnedTrails or p.EquippedTrail or p.TrailSkin then
		TrailUISystem:UpdateDisplay()
	end

	if p.OwnedAuras or p.EquippedAura or p.AuraSkin then
		AuraUISystem:UpdateDisplay()
	end

	if p.Settings then
		SettingsUISystem:OnDataUpdated(p.Settings)
	end

	if p.OwnedTreadmillSkins or p.EquippedTreadmillSkin then
		TreadmillSkinUISystem:UpdateDisplay()
		TreadmillBundleUISystem:UpdateDisplay()
	end

	local v9 = ClientState:Get()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local v10 = (v9.Stage15SpeedBoost or 0) > 0

	if humanoid and not v10 and (v9.CustomWalkSpeed == nil or v9.CustomWalkSpeed == 0) then
		local world3Stage15Beaten

		if Config.WORLD == 3 then
			world3Stage15Beaten = v9.World3Stage15Beaten
		else
			world3Stage15Beaten = false
		end

		local walkSpeedWithBonus = revive.walkSpeedWithBonus
		local v12

		if world3Stage15Beaten then
			v12 = Config.MAX_LEVEL_SPEED_CAP
		else
			v12 = Config.CalculateMaxSpeed(v9.Level)
		end

		humanoid.WalkSpeed = walkSpeedWithBonus(localPlayer, v12)
	end

	updateBaseUI()
	updateBoostButtonLabels()

	if p.StepBonus ~= nil or p.Wins ~= nil then
		task.defer(function()
			if _G.RefreshAwardVisuals then
				_G.RefreshAwardVisuals()
			end
		end)
	end

	if p.Rebirths then
		local rebirths = p.Rebirths

		if v6 == nil then
			v6 = rebirths
		elseif v6 < rebirths then
			task.wait(0.5)
			NotificationSystem:ShowRebirth(rebirths)
			v6 = rebirths
		end
	end

	if p.Level then
		local level = p.Level

		if v5 == nil or level < v5 then
			v5 = level
		elseif v5 < level then
			NotificationSystem:ShowLevelUp(v5, level)
			v5 = level
		end
	end

	if p.CurrentSpeedTier ~= nil then
		updateSpeedBoostButton()
	end
end)
local v7 = nil

local function getEventCurrencyInfo()
	local now = os.time()

	for _, event in ipairs(EventsConfig.Events) do
		if event.CurrencyInfo and event.Start <= now and now < event.End then
			return event.CurrencyInfo
		end
	end

	return EventsConfig.EventCoins.Events.Summer2026.InfoModal.EventCurrency
end

local v8 = {
	SpeedBoost = function()
		remotes.PromptSpeedBoost:FireServer()
	end,
	WinsBoost = function()
		remotes.PromptWinsBoost:FireServer()
	end,
	Boost150K = function()
		remotes.Prompt150KSpeed:FireServer()
	end,
	Boost1M = function()
		remotes.Prompt1MSpeed:FireServer()
	end,
	Boost10M = function()
		remotes.Prompt10MSpeed:FireServer()
	end,
	Boost50M = function()
		remotes.Prompt50MSpeed:FireServer()
	end,
	Boost500M = function()
		remotes.Prompt500MSpeed:FireServer()
	end,
	Boost1B = function()
		remotes.Prompt1BSpeed:FireServer()
	end,
	Rebirth = function()
		local RebirthUISystem = require(ReplicatedStorage.RebirthUISystem)
		RebirthUISystem:InitLogic()
		ClientState:ToggleModal(getUI("RebirthModal"), require(ReplicatedStorage.RebirthUISystem))
	end,
	RebirthAscend = function()
		local AscensionUISystem2 = require(ReplicatedStorage.UISystems.AscensionUISystem)
		AscensionUISystem2.open()
	end,
	Gift = function()
		local GiftUISystem = require(ReplicatedStorage.GiftUISystem)
		GiftUISystem:InitLogic()
		ClientState:ToggleModal(getUI("GiftModal"), require(ReplicatedStorage.GiftUISystem))
	end,
	SoundPack = function()
		local SoundPackUISystem = require(ReplicatedStorage.SoundPackUISystem)
		SoundPackUISystem:InitLogic()
		ClientState:ToggleModal(getUI("SoundPackModal"), SoundPackUISystem)
	end,
	TrailsModal = function()
		TrailUISystem:InitLogic()
		local UI = getUI("TrailsModal")

		if ClientState.ActiveModal ~= UI and funnelShop then
			funnelShop:FireServer("open")
		end

		ClientState:ToggleModal(UI, TrailUISystem)
		TrailUISystem:UpdateDisplay()
	end,
	AurasModal = function()
		AuraUISystem:InitLogic()
		local UI = getUI("AurasModal")

		if ClientState.ActiveModal ~= UI and funnelShop then
			funnelShop:FireServer("open")
		end

		ClientState:ToggleModal(UI, AuraUISystem)
		AuraUISystem:UpdateDisplay()
	end,
	RobuxShopModal = function()
		local RobuxShopUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("RobuxShopUISystem"))
		RobuxShopUISystem:InitLogic()
		ClientState:ToggleModal(getUI("RobuxShopModal"), RobuxShopUISystem)
		RobuxShopUISystem:UpdateDisplay()
	end,
	MedalQuestModal = function()
		local MedalUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("MedalUISystem"))
		MedalUISystem:InitLogic()
		local UI = getUI("MedalQuestModal")
		local v9 = ClientState.ActiveModal ~= UI
		ClientState:ToggleModal(UI, MedalUISystem)

		if v9 and ClientState.ActiveModal == UI then
			MedalUISystem:Open()
		end
	end,
	Checkpoint = function()
		local UI = getUI("CheckpointModal")

		if ClientState.ActiveModal ~= UI and funnelShop then
			funnelShop:FireServer("open")
		end

		ClientState:ToggleModal(UI)
	end,
	Shop = function()
		local UI = getUI("ShopModal")

		if ClientState.ActiveModal ~= UI and funnelShop then
			funnelShop:FireServer("open")
		end

		ClientState:ToggleModal(UI)
	end,
	EventShop = function()
		local UI = getUI("EventShopModal")

		if ClientState.ActiveModal ~= UI and funnelShop then
			funnelShop:FireServer("open")
		end

		ClientState:ToggleModal(UI)
	end,
	EventCurrency = function()
		local InfoModalUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("InfoModalUISystem"))
		local eventCurrencyInfo = getEventCurrencyInfo()
		InfoModalUISystem:Open(eventCurrencyInfo.Title, eventCurrencyInfo.Description)
	end,
	InventoryModal = function()
		local UI = getUI("InventoryModal")
		TrailUISystem:InitLogic()
		AuraUISystem:InitLogic()
		TreadmillSkinUISystem:InitLogic()
		TreadmillBundleUISystem:InitLogic()
		ClientState:ToggleModal(UI)
		TrailUISystem:UpdateDisplay()
		AuraUISystem:UpdateDisplay()
		TreadmillSkinUISystem:UpdateDisplay()
		TreadmillBundleUISystem:UpdateDisplay()
	end,
	ItemsMerger = function()
		local UI = getUI("InventoryModal")
		TrailUISystem:InitLogic()
		AuraUISystem:InitLogic()
		TreadmillSkinUISystem:InitLogic()
		TreadmillBundleUISystem:InitLogic()

		if ClientState.ActiveModal ~= UI then
			ClientState:ToggleModal(UI)
		end

		TrailUISystem:UpdateDisplay()
		AuraUISystem:UpdateDisplay()
		TreadmillSkinUISystem:UpdateDisplay()
		TreadmillBundleUISystem:UpdateDisplay()

		if v7 then
			v7("ItemsMerger")
		end
	end,
	ItemShopModal = function()
		ClientState:ToggleModal((getUI("ItemsShopModal")))
	end,
	BBEventItemsShopModal = function()
		local BBEventItemsShopUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("BBEventItemsShopUISystem"))
		BBEventItemsShopUISystem:Open()
	end,
	SummerEventItemsShopModal = function()
		eventShops.toggle("Summer2026")
	end,
	RIAAdminAbuse2026ShopModal = function()
		eventShops.toggle("RIA2026")
	end,
	HalloweenEventItemsShopModal = function()
		eventShops.toggle("Halloween2026")
	end,
	PersonalTreadmill = function()
		local v9 = remotes.PlacePersonalTreadmill:InvokeServer()

		if type(v9) == "table" and not v9.ok then
			NotificationSystem:ShowMessage(
				v9.err or "Couldn't place your treadmill here.",
				Color3.fromRGB(255, 100, 100)
			)
		end
	end,
	OpenTradingTargetModal = function()
		local TargetModal = require(ReplicatedStorage._FRAMEWORK.Features.Trading.Client.TargetModal)
		TargetModal.open()
	end
}

local function setupButton(guiObject)
	local action = guiObject:GetAttribute("Action")

	if action == "Checkpoint" and not Config.FEATURES.CHECKPOINTS then
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = false
		end
	else
		if action == "Gift" then
			local v9 = ClientState:Get()

			if v9 and v9.GiftClaimed and guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		if action and v8[action] then
			guiObject.MouseButton1Click:Connect(v8[action])
		end
	end
end

for _, v9 in ipairs(CollectionService:GetTagged("UIActionBtn")) do
	setupButton(v9)
end

CollectionService:GetInstanceAddedSignal("UIActionBtn"):Connect(setupButton)

-- equivalent calls inferred from this helper; original call sites unknown
local function setupInventoryClose(instance)
	if instance:IsDescendantOf(playerGui) then
		instance.MouseButton1Click:Connect(function()
			ClientState:CloseCurrentModal()
		end)
	end
end

for _, v9 in ipairs(CollectionService:GetTagged("InventoryCloseModal")) do
	if v9:IsDescendantOf(playerGui) then
		v9.MouseButton1Click:Connect(function()
			ClientState:CloseCurrentModal()
		end)
	end
end

CollectionService:GetInstanceAddedSignal("InventoryCloseModal"):Connect(function(p)
	task.defer(function()
		setupInventoryClose(p) -- equivalent call inferred; original call site unknown
	end)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function setupItemsShopClose(instance)
	if instance:IsDescendantOf(playerGui) then
		instance.MouseButton1Down:Connect(function()
			ClientState:CloseCurrentModal()
		end)
	end
end

for _, v9 in ipairs(CollectionService:GetTagged("ItemsShopCloseModal")) do
	if v9:IsDescendantOf(playerGui) then
		v9.MouseButton1Down:Connect(function()
			ClientState:CloseCurrentModal()
		end)
	end
end

CollectionService:GetInstanceAddedSignal("ItemsShopCloseModal"):Connect(function(p)
	task.defer(function()
		setupItemsShopClose(p) -- equivalent call inferred; original call site unknown
	end)
end)
local color = Color3.fromRGB(204, 194, 255)
local tweenInfo = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v9 = nil
local v10 = nil
local zIndex = 6
local v12 = {}
local v13 = {}
local v14 = {}

local function getAllButtons()
	local result = {}

	for _, v15 in ipairs(CollectionService:GetTagged("InventoryButtons")) do
		if v15:IsDescendantOf(playerGui) then
			table.insert(result, v15)
		end
	end

	return result
end

local function getAllWindows()
	local result = {}

	for _, v15 in ipairs(CollectionService:GetTagged("InventoryWindow")) do
		if v15:IsDescendantOf(playerGui) then
			table.insert(result, v15)
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setModalY(p, p2)
	p.Position = UDim2.new(p.Position.X.Scale, 0, p2, 0)
end

local function hideModal(p)
	local v15 = v12[p]

	if v15 and v15.tween then
		v15.tween:Cancel()
	end

	if p.Parent then
		p.Visible = false
		setModalY(p, 0.45) -- equivalent call inferred; original call site unknown
	end

	v12[p] = {
		tween = nil,
		phase = "idle"
	}
end

local function tweenModalIn(window)
	local v15 = v12[window]

	if v15 and v15.tween then
		v15.tween:Cancel()
	end

	window.Visible = true
	setModalY(window, 0.6) -- equivalent call inferred; original call site unknown
	zIndex += 1
	window.ZIndex = zIndex
	local tween = TweenService:Create(window, tweenInfo2, {
		Position = UDim2.new(window.Position.X.Scale, 0, 0.45, 0)
	})
	v12[window] = {
		tween = tween,
		phase = "in"
	}
	tween.Completed:Connect(function(p)
		local v16 = v12[window]

		if p == Enum.PlaybackState.Completed and v16 and v16.tween == tween then
			v16.tween = nil
			v16.phase = "idle"
		end
	end)
	tween:Play()
end

local function ensureIdleColors(p)
	local v15 = v14[p]

	if v15 then
		return v15
	end

	local v16 = {
		background = p.BackgroundColor3,
		image = p.ImageColor3
	}
	v14[p] = v16
	return v16
end

local function applyButtonVisual(data, p)
	local v15 = v14[data]

	if not v15 then
		v15 = {
			background = data.BackgroundColor3,
			image = data.ImageColor3
		}
		v14[data] = v15
	end

	local icon = data.Icon
	local title = data.Title
	local v16 = p and 2.5 or 2.1
	local v19 = v13[data]

	if v19 then
		for _, v20 in ipairs(v19) do
			v20:Cancel()
		end
	end

	local v20 = { TweenService:Create(icon, tweenInfo, {
			Position = UDim2.new(icon.Position.X.Scale, 0, p and 0.15 or 0.35, 0),
			Size = UDim2.fromScale(v16, v16)
		}), TweenService:Create(title, tweenInfo, {
			Size = UDim2.new(title.Size.X.Scale, 0, p and 0.65 or 0.55, 0)
		}), TweenService:Create(data, tweenInfo, {
			BackgroundColor3 = p and color or v15.background,
			ImageColor3 = p and color or v15.image
		}) }
	v13[data] = v20

	for _, v21 in ipairs(v20) do
		v21:Play()
	end
end

local function findWindow(p)
	for _, v15 in ipairs((getAllWindows())) do
		if string.lower(v15:GetAttribute("Window") or "") == p then
			return v15
		end
	end

	return nil
end

local function switchTab(value)
	local v15 = string.lower(value)

	if v9 == v15 and v10 then
		return
	end

	local window = findWindow(v15)
	local v16 = v10
	v9 = v15
	v10 = window

	if v16 and v16 ~= window then
		hideModal(v16)
	end

	if window and window ~= v16 then
		tweenModalIn(window)
	end

	for _, v17 in ipairs((getAllButtons())) do
		applyButtonVisual(v17, string.lower(v17:GetAttribute("Action") or "") == v15)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupTabButton(instance)
	local action = instance:GetAttribute("Action")

	if instance:IsDescendantOf(playerGui) and action then
		instance.MouseButton1Click:Connect(function()
			switchTab(action)
		end)
	end
end

for _, v15 in ipairs(CollectionService:GetTagged("InventoryButtons")) do
	local action = v15:GetAttribute("Action")

	if not (v15:IsDescendantOf(playerGui) and action) then
		continue
	end

	local v16 = action
	v15.MouseButton1Click:Connect(function()
		switchTab(v16)
	end)
end

CollectionService:GetInstanceAddedSignal("InventoryButtons"):Connect(function(instance)
	task.defer(function()
		setupTabButton(instance) -- equivalent call inferred; original call site unknown
		local action = v9 and instance:IsDescendantOf(playerGui) and instance:GetAttribute("Action")

		if action then
			applyButtonVisual(instance, string.lower(action) == v9)
		end
	end)
end)
CollectionService:GetInstanceAddedSignal("InventoryWindow"):Connect(function(instance)
	task.defer(function()
		if instance:IsDescendantOf(playerGui) and v9 then
			if string.lower(instance:GetAttribute("Window") or "") == v9 then
				v10 = instance
				setModalY(instance, 0.45) -- equivalent call inferred; original call site unknown
				instance.Visible = true
				v12[instance] = {
					tween = nil,
					phase = "idle"
				}
			else
				instance.Visible = false
			end
		end
	end)
end)
v7 = switchTab
task.defer(function()
	switchTab("Trails")
end)
updateBoostButtonLabels()
localPlayer:GetAttributeChangedSignal("RELICSxyz_OwnsBoombox"):Connect(updateBaseUI)
local flag = false
local flag2 = false
local flag3 = false
local flag4 = false
localPlayer.CharacterAdded:Connect(function()
	flag = false
	flag2 = false
	flag3 = false
	flag4 = false
	v2 = {}
	ClientState:ForceResetModal()
end)

local function setupCheckpointPortal(part)
	if not (Config.FEATURES.CHECKPOINTS and part:IsA("BasePart")) then
		return
	end

	part.Touched:Connect(function(otherPart)
		if flag then
			return
		end

		local character = localPlayer.Character

		if character and otherPart:IsDescendantOf(character) then
			flag = true

			if funnelShop then
				funnelShop:FireServer("open")
			end

			ClientState:ToggleModal((getUI("CheckpointModal")))
		end
	end)
	part.TouchEnded:Connect(function(otherPart)
		local character = localPlayer.Character

		if character and otherPart:IsDescendantOf(character) then
			task.delay(0.15, function()
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = { character }
				overlapParams.FilterType = Enum.RaycastFilterType.Include

				if #workspace:GetPartsInPart(part, overlapParams) == 0 then
					flag = false

					if ClientState.ActiveModal == getUI("CheckpointModal") then
						ClientState:CloseCurrentModal()
					end
				end
			end)
		end
	end)
end

for _, v15 in ipairs(CollectionService:GetTagged("OpenCheckpointModal")) do
	setupCheckpointPortal(v15)
end

CollectionService:GetInstanceAddedSignal("OpenCheckpointModal"):Connect(setupCheckpointPortal)

local function isAnyEventShopActive()
	local now = os.time()

	for _, event in ipairs(EventsConfig.Events) do
		if event.ShowEventShop ~= false and event.Start <= now and now < event.End then
			return true
		end
	end

	return false
end

local function setupEventShopPortal(part)
	if not part:IsA("BasePart") then
		return
	end

	part.Touched:Connect(function(otherPart)
		if flag2 or not isAnyEventShopActive() then
			return
		end

		local character = localPlayer.Character

		if character and otherPart:IsDescendantOf(character) then
			flag2 = true

			if funnelShop then
				funnelShop:FireServer("open")
			end

			ClientState:ToggleModal((getUI("EventShopModal")))
		end
	end)
	part.TouchEnded:Connect(function(otherPart)
		local character = localPlayer.Character

		if character and otherPart:IsDescendantOf(character) then
			task.delay(0.15, function()
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = { character }
				overlapParams.FilterType = Enum.RaycastFilterType.Include

				if #workspace:GetPartsInPart(part, overlapParams) == 0 then
					flag2 = false

					if ClientState.ActiveModal == getUI("EventShopModal") then
						ClientState:CloseCurrentModal()
					end
				end
			end)
		end
	end)
end

for _, v15 in ipairs(CollectionService:GetTagged("OpenEventShopModal")) do
	setupEventShopPortal(v15)
end

CollectionService:GetInstanceAddedSignal("OpenEventShopModal"):Connect(setupEventShopPortal)

local function setupItemsShopZone(part)
	if not part:IsA("BasePart") then
		return
	end

	part.Touched:Connect(function(otherPart)
		if flag3 then
			return
		end

		local character = localPlayer.Character

		if character and otherPart:IsDescendantOf(character) then
			flag3 = true
			ClientState:ToggleModal((getUI("ItemsShopModal")))
		end
	end)
	part.TouchEnded:Connect(function(otherPart)
		local character = localPlayer.Character

		if character and otherPart:IsDescendantOf(character) then
			task.delay(0.15, function()
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = { character }
				overlapParams.FilterType = Enum.RaycastFilterType.Include

				if #workspace:GetPartsInPart(part, overlapParams) == 0 then
					flag3 = false

					if ClientState.ActiveModal == getUI("ItemsShopModal") then
						ClientState:CloseCurrentModal()
					end
				end
			end)
		end
	end)
end

for _, v15 in ipairs(CollectionService:GetTagged("OpenItemsShopZone")) do
	setupItemsShopZone(v15)
end

CollectionService:GetInstanceAddedSignal("OpenItemsShopZone"):Connect(setupItemsShopZone)

-- equivalent calls inferred from this helper; original call sites unknown
local function getBBEventItemsShopSystem()
	return require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("BBEventItemsShopUISystem"))
end

local function setupBBEventItemsShopZone(part)
	if not part:IsA("BasePart") then
		return
	end

	part.Touched:Connect(function(otherPart)
		if flag4 then
			return
		end

		local character = localPlayer.Character

		if character and otherPart:IsDescendantOf(character) then
			flag4 = true
			local bBEventItemsShopSystem = getBBEventItemsShopSystem() -- equivalent call inferred; original call site unknown
			bBEventItemsShopSystem:Open()
		end
	end)
	part.TouchEnded:Connect(function(otherPart)
		local character = localPlayer.Character

		if character and otherPart:IsDescendantOf(character) then
			task.delay(0.15, function()
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = { character }
				overlapParams.FilterType = Enum.RaycastFilterType.Include

				if #workspace:GetPartsInPart(part, overlapParams) == 0 then
					flag4 = false
					local UI = getUI("BBEventItemsShopModal")

					if ClientState.ActiveModal == UI then
						ClientState:CloseCurrentModal()
					end
				end
			end)
		end
	end)
end

for _, v15 in ipairs(CollectionService:GetTagged("BBNoMoneyItemsShopZone")) do
	setupBBEventItemsShopZone(v15)
end

CollectionService:GetInstanceAddedSignal("BBNoMoneyItemsShopZone"):Connect(setupBBEventItemsShopZone)
task.spawn(function()
	while true do
		task.wait(5)

		if isAnyEventShopActive() then
			continue
		end

		local UI = getUI("EventShopModal")

		if not (UI and ClientState.ActiveModal == UI) then
			continue
		end

		flag2 = false
		ClientState:CloseCurrentModal()
	end
end)
showWin.OnClientEvent:Connect(function(p, p2)
	NotificationSystem:ShowWinNotification(p, p2)
end)
showPlayerMessage.OnClientEvent:Connect(function(p, p2)
	NotificationSystem:ShowMessage(p, p2)
end)
showGeneralNotification.OnClientEvent:Connect(function(p, p2, p3)
	NotificationSystem:ShowGeneralNotification(p, p2, p3)
end)
local bossHit = remotes:WaitForChild("BossHit", 10)

if bossHit then
	bossHit.OnClientEvent:Connect(function() end)
end

task.wait(1)
remotes.RequestInitialData:FireServer()
local connectionsByUI = {}

local function connectSpeedLogic()
	local UI = getUI("TextboxCustomSpeed")
	local UI2 = getUI("ButtonCustomSpeed")

	if not (UI and UI2) or connectionsByUI[UI2] then
		return
	end

	local function applyCustomSpeed()
		local v15 = ClientState:Get()
		local text = tonumber(UI.Text)

		if not text then
			NotificationSystem:ShowMessage("Enter a valid number!", Color3.fromRGB(255, 100, 100))
			return
		end

		local world3Stage15Beaten

		if Config.WORLD == 3 then
			world3Stage15Beaten = v15.World3Stage15Beaten
		else
			world3Stage15Beaten = false
		end

		local v16

		if world3Stage15Beaten then
			v16 = Config.MAX_LEVEL_SPEED_CAP
		else
			v16 = Config.CalculateMaxSpeed(v15.Level)
		end

		local customWalkSpeed = math.clamp(text, Config.DEFAULT_WALKSPEED, v16)
		remotes.SetCustomSpeed:FireServer(customWalkSpeed)
		ClientState:Update({
			CustomWalkSpeed = customWalkSpeed
		})
		local character = localPlayer.Character

		if character and character:FindFirstChild("Humanoid") then
			character.Humanoid.WalkSpeed = revive.walkSpeedWithBonus(
				localPlayer,
				(math.min(customWalkSpeed + (v15.Stage15SpeedBoost or 0), Config.MAX_LEVEL_SPEED_CAP))
			)
		end

		updateBaseUI()
		UI.Text = ""
		NotificationSystem:ShowMessage("Speed updated!", Color3.fromRGB(200, 255, 200))
	end

	connectionsByUI[UI2] = UI2.MouseButton1Click:Connect(applyCustomSpeed)
end

CollectionService:GetInstanceAddedSignal("TextboxCustomSpeed"):Connect(connectSpeedLogic)
CollectionService:GetInstanceAddedSignal("ButtonCustomSpeed"):Connect(connectSpeedLogic)
task.spawn(connectSpeedLogic)

local function applyImageIfPossible(guiObject, image: string)
	if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
		guiObject.Image = image
	end
end

local function applyTaggedIcon(tag: string, image: string?)
	if not image then
		return
	end

	for _, guiObject in ipairs(CollectionService:GetTagged(tag)) do
		if not (guiObject:IsDescendantOf(playerGui) and (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton"))) then
			continue
		end

		guiObject.Image = image
	end
end

local function applyStatIcons()
	applyTaggedIcon("WinsIcon", Config.GetWinsIcon and Config.GetWinsIcon() or nil)
	applyTaggedIcon("SpeedIcon", Config.GetSpeedIcon and Config.GetSpeedIcon() or nil)
end

local v16

if Config.GetWinsIcon then
	v16 = Config.GetWinsIcon() or nil
end

applyTaggedIcon("WinsIcon", v16)
local v18

if Config.GetSpeedIcon then
	v18 = Config.GetSpeedIcon() or nil
end

applyTaggedIcon("SpeedIcon", v18)
CollectionService:GetInstanceAddedSignal("WinsIcon"):Connect(function(guiObject)
	local image = Config.GetWinsIcon and Config.GetWinsIcon()

	if image and guiObject:IsDescendantOf(playerGui) and (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
		guiObject.Image = image
	end
end)
CollectionService:GetInstanceAddedSignal("SpeedIcon"):Connect(function(guiObject)
	local image = Config.GetSpeedIcon and Config.GetSpeedIcon()

	if image and guiObject:IsDescendantOf(playerGui) and (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
		guiObject.Image = image
	end
end)
localPlayer.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	local v19 = ClientState:Get()
	task.wait(0.1)
	local world3Stage15Beaten

	if Config.WORLD == 3 then
		world3Stage15Beaten = v19.World3Stage15Beaten
	else
		world3Stage15Beaten = false
	end

	local customWalkSpeed = v19.CustomWalkSpeed and v19.CustomWalkSpeed > 0 and v19.CustomWalkSpeed

	if not customWalkSpeed then
		if world3Stage15Beaten then
			customWalkSpeed = Config.MAX_LEVEL_SPEED_CAP
		else
			customWalkSpeed = Config.CalculateMaxSpeed(v19.Level)
		end
	end

	humanoid.WalkSpeed = revive.walkSpeedWithBonus(localPlayer, customWalkSpeed)
end)