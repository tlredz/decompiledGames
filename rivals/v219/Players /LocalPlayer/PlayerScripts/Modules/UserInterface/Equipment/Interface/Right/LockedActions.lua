local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdService = game:GetService("AdService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ScavengerHuntLibrary = require(ReplicatedStorage.Modules.ScavengerHuntLibrary)
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local CurrencyLibrary = require(ReplicatedStorage.Modules.CurrencyLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local LockedActions = {}
LockedActions.__index = LockedActions

function LockedActions.new(right)
	local self = setmetatable({}, LockedActions)
	self.Right = right
	self.Frame = self.Right.Container:WaitForChild("LockedActions")
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.TryWeaponFrame = self.Container:WaitForChild("TryWeapon")
	self.TryWeaponButton = self.TryWeaponFrame:WaitForChild("Button")
	self.SpecialOfferFrame = self.Container:WaitForChild("SpecialOffer")
	self.SpecialOfferDescription = self.SpecialOfferFrame:WaitForChild("Description")
	self.SpecialOfferCountdown = self.SpecialOfferFrame:WaitForChild("Countdown")
	self.SpecialOfferButton = self.SpecialOfferFrame:WaitForChild("Button")
	self.SpecialOfferButtonLockedFrame = self.SpecialOfferButton:WaitForChild("Locked")
	self.SpecialOfferButtonUnlockedFrame = self.SpecialOfferButton:WaitForChild("Unlocked")
	self.BuyFrame = self.Container:WaitForChild("Buy")
	self.BuyDescription = self.BuyFrame:WaitForChild("Description")
	self.BuyCountdown = self.BuyFrame:WaitForChild("Countdown")
	self.BuyButton = self.BuyFrame:WaitForChild("Button")
	self.BuyButtonLockedFrame = self.BuyButton:WaitForChild("Locked")
	self.BuyButtonFreeFrame = self.BuyButton:WaitForChild("Free")
	self.BuyButtonKeysFrame = self.BuyButton:WaitForChild("Keys")
	self.BuyButtonKeysPrice = self.BuyButtonKeysFrame:WaitForChild("Price")
	self.BuyButtonKeysPriceIconOutline = self.BuyButtonKeysPrice:WaitForChild("Icon")
	self.BuyButtonKeysPriceIcon = self.BuyButtonKeysPriceIconOutline:WaitForChild("ImageLabel")
	self.ScavengerFrame = self.Container:WaitForChild("Scavenger")
	self.ScavengerTitle = self.ScavengerFrame:WaitForChild("Title")
	self.ScavengerProgress = self.ScavengerFrame:WaitForChild("Progress")
	self.ScavengerIcon = self.ScavengerFrame:WaitForChild("Icon")
	self.ScavengerButton = self.ScavengerFrame:WaitForChild("Button")
	self.FreeTrialFrame = self.Container:WaitForChild("FreeTrial")
	self.FreeTrialReadyFrame = self.FreeTrialFrame:WaitForChild("Ready")
	self.FreeTrialNotReadyFrame = self.FreeTrialFrame:WaitForChild("NotReady")
	self.FreeTrialWaitingFrame = self.FreeTrialNotReadyFrame:WaitForChild("Waiting")
	self.FreeTrialWaitingDotsFrame = self.FreeTrialWaitingFrame:WaitForChild("Dots")
	self.FreeTrialUnavailable = self.FreeTrialNotReadyFrame:WaitForChild("Unavailable")
	self.FreeTrialButton = self.FreeTrialNotReadyFrame:WaitForChild("Button")
	self.FreeTrialButtonTitle = self.FreeTrialButton:WaitForChild("Title")
	self.FreeTrialButtonIcon = self.FreeTrialButtonTitle:WaitForChild("Icon")
	self._update_information_hash = 0
	self:_Init()
	return self
end

function LockedActions:OnStateChanged()
	self:_UpdateInformation()
end

function LockedActions:_InteractSpecialOffer()
	local selectedWeapon = self.Right.Interface.Equipment:GetSelectedWeapon()
	local rewardSeasonPassPosition, v = SeasonLibrary:GetRewardSeasonPassPosition(selectedWeapon)
	local v2 = self.SpecialOfferDescription.Text == "Early access!" and "standardweapons_bundle" or MonetizationLibrary:GetBundleContainingReward(selectedWeapon)

	if rewardSeasonPassPosition and v then
		Pages.PageSystem:OpenPage("BattlePass", true)
		Pages.PageSystem:WaitForPage("BattlePass"):Preview(rewardSeasonPassPosition, v)
	elseif v2 == "contrabandseason_bundle" or v2 == "primeseason_bundle" then
		Pages.PageSystem:OpenPage("BattlePass", true)
		Pages.PageSystem:WaitForPage("BattlePass"):InspectBundle(v2)
	elseif v2 then
		Pages.PageSystem:OpenPage("Shop", true)
		Pages.PageSystem:WaitForPage("Shop"):SetPage("Bundles")
		task.delay(0.1, function()
			Pages.PageSystem:WaitForPage("Shop"):InspectBundle(v2)
		end)
	end
end

function LockedActions:_UpdateInformation()
	self._update_information_hash += 1
	local _update_information_hash = self._update_information_hash
	local selectedWeapon = self.Right.Interface.Equipment:GetSelectedWeapon()
	local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)
	local visible = selectedWeapon and not weaponData
	self.Frame.Visible = visible

	if not visible then
		self.FreeTrialWaitingDotsFrame:RemoveTag("UILoadingDots")
		return
	end

	local weaponKeyPriceInfo, _, v2, _ = ShopLibrary:GetWeaponKeyPriceInfo(
		selectedWeapon,
		PlayerDataController:Get("UnlockTokens"),
		PlayerDataController:Get("FreeWeaponUnlockCheck")
	)
	local bundleContainingReward = MonetizationLibrary:GetBundleContainingReward(selectedWeapon)
	local rewardSeasonPassPosition, _ = SeasonLibrary:GetRewardSeasonPassPosition(selectedWeapon)
	local timeUntilWeaponRelease = ShopLibrary:GetTimeUntilWeaponRelease(selectedWeapon)
	local visible2 = not v2 and timeUntilWeaponRelease > 0
	local v4 = visible2 and timeUntilWeaponRelease <= CONSTANTS.WEAPON_REVEAL_TIME_OFFSET
	local v5 = v4 and timeUntilWeaponRelease <= CONSTANTS.WEAPON_EARLY_ACCESS_TIME_OFFSET
	local v6 = ScavengerHuntLibrary.InfoByWeapon[selectedWeapon]
	local numVideoAdsForFreeWeaponTrial = MonetizationLibrary:GetNumVideoAdsForFreeWeaponTrial(selectedWeapon)
	local visible3 = (PlayerDataController:Get("FreeWeaponTrialsRemaining")[selectedWeapon] or 0) > 0
	local visible4 = visible3 or numVideoAdsForFreeWeaponTrial and PlayerDataController:Get("NumFreeWeaponTrialsFromVideoAdsToday") < MonetizationLibrary.MAX_FREE_WEAPON_TRIALS_PER_DAY
	local v9 = bundleContainingReward ~= "superstarter_bundle" or ServerOsTime:GetRounded() - PlayerDataController:Get("SuperStarterBundleStartTime") < MonetizationLibrary.SUPER_STARTER_BUNDLE_OFFER_DURATION
	self.BuyFrame.Visible = v5 or weaponKeyPriceInfo < 1e999
	self.BuyButtonLockedFrame.Visible = visible2
	self.BuyButtonFreeFrame.Visible = not visible2 and weaponKeyPriceInfo <= 0
	self.BuyButtonKeysFrame.Visible = not visible2 and weaponKeyPriceInfo > 0
	self.BuyButtonKeysPrice.Text = visible2 and "" or Utility:PrettyNumber(weaponKeyPriceInfo)
	local buyDescription = self.BuyDescription
	local position

	if visible2 then
		position = UDim2.new(0.175, 0, 0.35, 0)
	else
		position = UDim2.new(0.175, 0, 0.5, 0)
	end

	buyDescription.Position = position
	self.BuyDescription.Text = visible2 and "Coming soon!" or "Unlock now!"
	self.BuyCountdown.Text = not visible2 and "" or "in " .. Utility:TimeFormat2(timeUntilWeaponRelease, 2)
	self.SpecialOfferFrame.Visible = not v2 and (bundleContainingReward and v9 or v4 or rewardSeasonPassPosition)
	self.SpecialOfferButtonLockedFrame.Visible = v4 and not v5
	self.SpecialOfferButtonUnlockedFrame.Visible = not v4 or v5
	local specialOfferDescription = self.SpecialOfferDescription
	local position2

	if v4 and not v5 then
		position2 = UDim2.new(0.175, 0, 0.35, 0)
	else
		position2 = UDim2.new(0.175, 0, 0.5, 0)
	end

	specialOfferDescription.Position = position2
	self.SpecialOfferDescription.Text = v4 and "Early access!" or "Special offer!"
	self.SpecialOfferCountdown.Text = (not v4 or v5) and "" or "in " .. Utility:TimeFormat2(
		timeUntilWeaponRelease - CONSTANTS.WEAPON_EARLY_ACCESS_TIME_OFFSET,
		2
	)
	self.TryWeaponFrame.Visible = not v2 and not visible2 and table.find(ShopLibrary.OwnableWeapons, selectedWeapon)
	self.ScavengerFrame.Visible = v6 ~= nil
	self.ScavengerTitle.Text = not v6 and "" or v6.NumObjects == 1 and v6.ObjectsName or v6.ObjectsNamePlural
	self.ScavengerProgress.Text = not v6 and "" or string.format(
		"%s / %s",
		#(PlayerDataController:Get("ScavengerHunts")[v6.Name] or {}),
		v6.NumObjects
	)
	self.ScavengerIcon.Image = not v6 and "" or v6.ObjectsImage
	self.FreeTrialFrame.Visible = visible4
	self.FreeTrialReadyFrame.Visible = visible3
	self.FreeTrialNotReadyFrame.Visible = not visible3
	self.FreeTrialButtonTitle.Text = string.format(
		"%s <font size=\"8\">/ %s</font>",
		PlayerDataController:Get("FreeWeaponTrialsProgressFromVideoAds")[selectedWeapon] or 0,
		numVideoAdsForFreeWeaponTrial or -1
	)
	self.FreeTrialButton.Visible = false
	self.FreeTrialUnavailable.Visible = false
	self.FreeTrialWaitingFrame.Visible = true
	self.FreeTrialWaitingDotsFrame:AddTag("UILoadingDots")
	task.spawn(function()
		if not visible4 or visible3 then
			return
		end

		local success, adAvailabilityNowAsync = pcall(
			AdService.GetAdAvailabilityNowAsync,
			AdService,
			Enum.AdFormat.RewardedVideo
		)
		wait(1)

		if _update_information_hash ~= self._update_information_hash then
			return
		end

		local visible5 = success and adAvailabilityNowAsync.AdAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable
		self.FreeTrialButton.Visible = visible5
		self.FreeTrialUnavailable.Visible = not visible5
		self.FreeTrialWaitingFrame.Visible = false
		self.FreeTrialWaitingDotsFrame:RemoveTag("UILoadingDots")
	end)
end

function LockedActions:_Update()
	self.Frame.Size = UDim2.new(1, 0, 0, self.Layout.AbsoluteContentSize.Y)
	self.BuyButtonKeysPrice.Position = UDim2.new(0.5, -self.BuyButtonKeysPriceIconOutline.AbsoluteSize.X / 2, 0.5, 0)
	self.BuyButtonKeysPriceIconOutline.Position = UDim2.new(0.5, self.BuyButtonKeysPrice.TextBounds.X / 2, 0.5, 0)
	self.FreeTrialButtonIcon.Position = UDim2.new(0.5, -self.FreeTrialButtonTitle.TextBounds.X / 2, 0.5, 0)
end

function LockedActions:_Setup()
	self.BuyButtonKeysPriceIconOutline.Image = CurrencyLibrary.Info.WeaponKeys.ImageFlatOutline
	self.BuyButtonKeysPriceIcon.Image = CurrencyLibrary.Info.WeaponKeys.ImageFlat
end

function LockedActions:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_Update()
	end)
	self.BuyButtonKeysPrice:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_Update()
	end)
	self.BuyButtonKeysPriceIconOutline:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_Update()
	end)
	self.BuyButton.MouseButton1Click:Connect(function()
		self.Right.Interface.Equipment:UnlockWeapon()
	end)
	self.TryWeaponButton.MouseButton1Click:Connect(function()
		self.Right.Interface.Equipment:TryWeapon()
	end)
	self.SpecialOfferButton.MouseButton1Click:Connect(function()
		self:_InteractSpecialOffer()
	end)
	self.FreeTrialButton.MouseButton1Click:Connect(function()
		local selectedWeapon = self.Right.Interface.Equipment:GetSelectedWeapon()
		ReplicatedStorage.Remotes.Misc.PlayVideoAdWeaponTrial:FireServer(selectedWeapon)
	end)
	self.FreeTrialUnavailable.MouseButton1Click:Connect(function()
		self:_UpdateInformation()
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_UpdateInformation()
	end)
	PlayerDataController:GetDataChangedSignal("UnlockTokens"):Connect(function()
		self:_UpdateInformation()
	end)
	PlayerDataController:GetDataChangedSignal("FreeWeaponUnlockCheck"):Connect(function()
		self:_UpdateInformation()
	end)
	PlayerDataController:GetDataChangedSignal("ScavengerHunts"):Connect(function()
		self:_UpdateInformation()
	end)
	PlayerDataController:GetDataChangedSignal("FreeWeaponTrialsRemaining"):Connect(function()
		self:_UpdateInformation()
	end)
	PlayerDataController:GetDataChangedSignal("FreeWeaponTrialsProgressFromVideoAds"):Connect(function()
		self:_UpdateInformation()
	end)
	PlayerDataController:GetDataChangedSignal("NumFreeWeaponTrialsFromVideoAdsToday"):Connect(function()
		self:_UpdateInformation()
	end)
	self:_Setup()
	self:_Update()
	ButtonEffect:Add(self.BuyButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
	ButtonEffect:Add(self.TryWeaponButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
	ButtonEffect:Add(self.SpecialOfferButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
	ButtonEffect:Add(self.FreeTrialButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
	ButtonEffect:Add(self.FreeTrialUnavailable, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
	ButtonEffect:Add(self.ScavengerButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
end

return LockedActions