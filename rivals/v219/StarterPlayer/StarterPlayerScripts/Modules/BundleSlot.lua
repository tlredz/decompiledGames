local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local CurrencyLibrary = require(ReplicatedStorage.Modules.CurrencyLibrary)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers.MonetizationController)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local Spotlight = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Spotlight)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local bundles = Players.LocalPlayer.PlayerScripts.UserInterface.Bundles
local BundleSlot = {}
BundleSlot.__index = BundleSlot

function BundleSlot.new(name)
	local self = setmetatable({}, BundleSlot)
	self.Tapped = Signal.new()
	self.AvailabilityChanged = Signal.new()
	self.OwnedChanged = Signal.new()
	self.Name = name
	self.Info = MonetizationLibrary.Bundles[self.Name]
	self.Frame = bundles[name]:Clone()
	self._connections = {}
	self._is_currency_bundle = self.Info.Type == "Currency"
	self._is_gamepass_bundle = self.Info.Type == "Gamepass"
	self._is_purchaseable_callback = nil
	self._is_spotlighting_inputs_enabled = true
	self._is_always_spotlighted = false
	self._superstarterbundle_loop_hash = 0
	self._is_owned = false
	self._is_robux_button_hidden = false
	self:_Init()
	return self
end

function BundleSlot:IsAvailableToPurchase()
	if self._is_gamepass_bundle then
		return not PlayerDataController:Get("GamepassBundlesClaimed")[self.Info.GamepassName]
	end

	if self.Name == "superstarter_bundle" then
		return self:_IsSuperStarterBundleAvailable()
	end

	if self.Name == "contrabandseason_bundle" then
		return not self:_IsContrabandSeasonBundleOwned()
	end

	return self.Name ~= "primeseason_bundle" or not self:_IsPrimeSeasonBundleOwned()
end

function BundleSlot:IsAlreadyOwned()
	return self._is_owned
end

function BundleSlot:GetAssetIDForRobuxText()
	return self._is_gamepass_bundle and MonetizationLibrary.Gamepasses[self.Info.GamepassName].GamepassID or self.Info.ProductID
end

function BundleSlot:GetInfoTypeForRobuxText()
	return self._is_gamepass_bundle and Enum.InfoType.GamePass or Enum.InfoType.Product
end

function BundleSlot:SetParent(parent)
	self.Frame.Parent = parent
end

function BundleSlot:SetIsOwned(is_owned)
	self._is_owned = is_owned
	self.OwnedChanged:Fire()
	self:_UpdateOwned()
end

function BundleSlot:SetAlwaysSpotlighted(is_always_spotlighted)
	self._is_always_spotlighted = is_always_spotlighted
	self:_SetSpotlightStatus(false)
end

function BundleSlot:SetSpotlightingInputsEnabled(is_spotlighting_inputs_enabled)
	self._is_spotlighting_inputs_enabled = is_spotlighting_inputs_enabled
	self:_SetSpotlightStatus(false)
end

function BundleSlot:HideRobuxButton()
	self._is_robux_button_hidden = true
	self:_UpdateOwned()
end

function BundleSlot:StartLoops()
	if self._update_superstarterbundle then
		task.spawn(function()
			self._superstarterbundle_loop_hash += 1
			local _superstarterbundle_loop_hash = self._superstarterbundle_loop_hash

			while _superstarterbundle_loop_hash == self._superstarterbundle_loop_hash do
				self._update_superstarterbundle()
				wait(1)
			end
		end)
	end
end

function BundleSlot:StopLoops()
	self._superstarterbundle_loop_hash += 1
end

function BundleSlot:PurchaseRequest()
	if not self:IsAvailableToPurchase() then
		return
	end

	if self._is_gamepass_bundle then
		MonetizationController:PromptGamePassPurchase(MonetizationLibrary.Gamepasses[self.Info.GamepassName].GamepassID)
	else
		MonetizationController:PromptProductPurchase(self.Info.ProductID)
	end
end

function BundleSlot:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self:StopLoops()
	self.Tapped:Destroy()
	self.AvailabilityChanged:Destroy()
	self.OwnedChanged:Destroy()
	self.Frame:Destroy()
end

function BundleSlot:_UpdateOwned()
	self.Frame.Container.Button.Visible = not (self._is_robux_button_hidden or self._is_owned)

	if self.Frame.Container:FindFirstChild("Claimed") then
		self.Frame.Container.Claimed.Visible = not self._is_robux_button_hidden and self._is_owned
	end
end

function BundleSlot:_GetSuperStarterBundleTimeRemaining()
	return (math.max(
		0,
		MonetizationLibrary.SUPER_STARTER_BUNDLE_OFFER_DURATION - (ServerOsTime:GetRounded() - PlayerDataController:Get("SuperStarterBundleStartTime"))
	))
end

function BundleSlot:_IsSuperStarterBundleOwned()
	return PlayerDataController:Get("SuperStarterBundlePurchased")
end

function BundleSlot:_IsSuperStarterBundleAvailable()
	return self:_GetSuperStarterBundleTimeRemaining() > 0 and not self:_IsSuperStarterBundleOwned()
end

function BundleSlot:_IsPrimeSeasonBundleOwned()
	local v = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
	local battlePass = v and v.BattlePass
	return (battlePass and battlePass.MaxPassTrackNum or 0) >= 2
end

function BundleSlot:_IsContrabandSeasonBundleOwned()
	local v = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
	local battlePass = v and v.BattlePass
	return battlePass and battlePass.SeasonPassBundleOwned
end

function BundleSlot:_SetSpotlightStatus(p)
	if self._is_spotlighting_inputs_enabled and p then
		Spotlight:ChangeSubject(self.Frame.Container.Background)
	else
		Spotlight:ChangeSubject(nil, self.Frame.Container.Background)
	end

	if p or self._is_always_spotlighted then
		self.Frame.Container.Icon.ImageColor3 = Color3.fromRGB(32, 32, 32)
		self.Frame.Container.Icon.ImageTransparency = 0.75
		self.Frame.Container.Rewards.Visible = true
		self.Frame.Container.Button.BubbleContainer.Visible = false
	else
		self.Frame.Container.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		self.Frame.Container.Icon.ImageTransparency = 0.25
		self.Frame.Container.Rewards.Visible = false
		self.Frame.Container.Button.BubbleContainer.Visible = true
	end
end

function BundleSlot:_SetupStandardWeaponsBundle()
	for k, name in pairs(MonetizationLibrary:GetStandardWeaponBundleWeapons()) do
		local v2 = not ShopLibrary:IsWeaponReleased(name)
		local v3 = RewardSlot.new({
			Name = name
		})
		v3.Frame.LayoutOrder = -#ShopLibrary.OwnableWeaponsAlphabetized + k + (v2 and -999999999 or 0)
		v3:SetInteractable(ControlsController.CurrentControls ~= "Touch")
		v3:SetParent(self.Frame.Container.Rewards)

		if not v2 then
			continue
		end

		v3:SetNameText("???")
		v3:LockedImage()
	end
end

function BundleSlot:_SetupCurrencyVisuals()
	self.Frame.Container.Value.Text = "+ " .. Utility:PrettyNumber(self.Info.Rewards[1].Quantity)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		self.Frame.Container.Value.Visible = not self.Frame.Container.Rewards.Visible
	end

	self.Frame.Container.Rewards:GetPropertyChangedSignal("Visible"):Connect(update)
	update() -- equivalent call inferred; original call site unknown

	if string.sub(self.Name, 14) == "eventcurrency_" then
		local v = tonumber((string.sub(15)))
		self.Frame.Container.Icon.Image = EventLibrary.EVENT_DETAILS.BUNDLE_BACKGROUND_IMAGES[v] or EventLibrary.EVENT_DETAILS.BUNDLE_BACKGROUND_IMAGES[1]
		self.Frame.Container.Background.ImageColor3 = CurrencyLibrary.Info.EventCurrency.Color
	end
end

function BundleSlot:_SetupGamepassVisuals()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		self:SetIsOwned(PlayerDataController:Get("GamepassBundlesClaimed")[self.Info.GamepassName])
		self.AvailabilityChanged:Fire()
	end

	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("GamepassBundlesClaimed"):Connect(update))
	update() -- equivalent call inferred; original call site unknown
end

function BundleSlot:_SetupContrabandSeasonBundle()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		self:SetIsOwned(self:_IsContrabandSeasonBundleOwned())
		self.AvailabilityChanged:Fire()
	end

	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("Seasons"):Connect(update))
	update() -- equivalent call inferred; original call site unknown
end

function BundleSlot:_SetupPrimeSeasonBundle()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		self:SetIsOwned(self:_IsPrimeSeasonBundleOwned())
		self.AvailabilityChanged:Fire()
	end

	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("Seasons"):Connect(update))
	update() -- equivalent call inferred; original call site unknown
end

function BundleSlot:_SetupSuperStarterBundle()
	function self._update_superstarterbundle()
		local _GetSuperStarterBundleTimeRemaining = self:_GetSuperStarterBundleTimeRemaining()
		self.Frame.Container.Countdown.Title.Text = _GetSuperStarterBundleTimeRemaining <= 0 and "This offer is no longer available" or "Offer ends in " .. Utility:TimeFormat2(_GetSuperStarterBundleTimeRemaining)
		self:SetIsOwned(self:_IsSuperStarterBundleOwned())
		self.AvailabilityChanged:Fire()
	end

	table.insert(
		self._connections,
		PlayerDataController:GetDataChangedSignal("SuperStarterBundlePurchased"):Connect(self._update_superstarterbundle)
	)
	self._update_superstarterbundle()

	local function update()
		self.Frame.Container.Countdown.Background.Size = UDim2.new(
			1.125,
			self.Frame.Container.Countdown.Title.TextBounds.X,
			1,
			0
		)
		self.Frame.Container.Countdown.Title.Icon.Position = UDim2.new(
			1,
			-self.Frame.Container.Countdown.Title.TextBounds.X,
			0.5,
			0
		)
	end

	self.Frame.Container.Countdown.Title:GetPropertyChangedSignal("TextBounds"):Connect(update)
	update()
	self:SetAlwaysSpotlighted(true)
end

function BundleSlot:_SetupRewards()
	for k, reward in pairs(self.Info.Rewards) do
		local reward2 = CosmeticLibrary.Rewards[reward.Name]

		if not (not reward2 or reward2.Type ~= "Lootbox" or not ComplianceController:ArePaidRandomItemsRestricted()) then
			continue
		end

		local v = RewardSlot.new(reward)
		v.Frame.LayoutOrder = k
		v:SetInteractable(ControlsController.CurrentControls ~= "Touch")
		v:SetParent(self.Frame.Container.Rewards)
	end
end

function BundleSlot:_Setup()
	self.Frame.Container.Title.Text = self.Info.DisplayName
	self.Frame.Container.Button.BubbleContainer.Bubble.Title.RichText = true
	self.Frame.Container.Button.BubbleContainer.Bubble.Title.Text = self.Info.BubbleText or ""
	self.Frame.Container.Button.BubbleContainer.Bubble.Visible = self.Frame.Container.Button.BubbleContainer.Bubble.Title.Text ~= ""
	MonetizationController:SetRobuxText(
		self.Frame.Container.Button.Title,
		self:GetAssetIDForRobuxText(),
		self:GetInfoTypeForRobuxText()
	)
	self:_SetupRewards()
	self:_SetSpotlightStatus(false)

	if self._is_currency_bundle then
		self:_SetupCurrencyVisuals()
	end

	if self._is_gamepass_bundle then
		self:_SetupGamepassVisuals()
	end

	if self.Name == "standardweapons_bundle" then
		self:_SetupStandardWeaponsBundle()
	elseif self.Name == "contrabandseason_bundle" then
		self:_SetupContrabandSeasonBundle()
	elseif self.Name == "primeseason_bundle" then
		self:_SetupPrimeSeasonBundle()
	elseif self.Name == "superstarter_bundle" then
		self:_SetupSuperStarterBundle()
	end
end

function BundleSlot:_Init()
	self.Frame.Container.MouseButton1Click:Connect(function()
		self.Tapped:Fire()
	end)
	self.Frame.Container.MouseEnter:Connect(function()
		self:_SetSpotlightStatus(true)
	end)
	self.Frame.Container.MouseLeave:Connect(function()
		self:_SetSpotlightStatus(false)
	end)
	self:_Setup()
	self:_UpdateOwned()
	ButtonEffect:Add(self.Frame.Container, nil, {
		HoverRatio = 1.025,
		ReleaseRatio = 1.025
	})
end

return BundleSlot