local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
require(ReplicatedStorage.Modules.CurrencyLibrary)
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local LootLibrary = require(ReplicatedStorage.Modules.LootLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers.MonetizationController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local BigShopSlot = require(Players.LocalPlayer.PlayerScripts.Modules.BaseShopSlot.BigShopSlot)
local ShopController = require(Players.LocalPlayer.PlayerScripts.Controllers.ShopController)
local ShopSlot = require(Players.LocalPlayer.PlayerScripts.Modules.BaseShopSlot.ShopSlot)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local LoginRewards = require(script:WaitForChild("LoginRewards"))
local Daily = {}
Daily.__index = Daily

function Daily.new(pages)
	local self = setmetatable({}, Daily)
	self.Pages = pages
	self.Frame = self.Pages.Frame:WaitForChild("Daily")
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.CountdownFrame = self.Container:WaitForChild("Countdown")
	self.CountdownTimer = self.CountdownFrame:WaitForChild("Timer")
	self.CountdownRefreshButton = self.CountdownFrame:WaitForChild("Refresh")
	self.CountdownRefreshPrice = self.CountdownRefreshButton:WaitForChild("Price")
	self.CountdownRefreshPriceIcon = self.CountdownRefreshPrice:WaitForChild("Icon")
	self.SkinsFrame = self.Container:WaitForChild("Skins")
	self.SkinsContainer = self.SkinsFrame:WaitForChild("Container")
	self.SkinsLayout = self.SkinsContainer:WaitForChild("Layout")
	self.FinishersFrame = self.Container:WaitForChild("Finishers")
	self.FinishersContainer = self.FinishersFrame:WaitForChild("Container")
	self.FinishersHeaderIcon = self.FinishersContainer:WaitForChild("Header"):WaitForChild("Icon")
	self.FinishersSlotsFrame = self.FinishersContainer:WaitForChild("Slots")
	self.FinishersSlotsLayout = self.FinishersSlotsFrame:WaitForChild("Layout")
	self.WrapsFrame = self.Container:WaitForChild("Wraps")
	self.WrapsContainer = self.WrapsFrame:WaitForChild("Container")
	self.WrapsHeaderIcon = self.WrapsContainer:WaitForChild("Header"):WaitForChild("Icon")
	self.WrapsSlotsFrame = self.WrapsContainer:WaitForChild("Slots")
	self.WrapsSlotsLayout = self.WrapsSlotsFrame:WaitForChild("Layout")
	self.CharmsFrame = self.Container:WaitForChild("Charms")
	self.CharmsContainer = self.CharmsFrame:WaitForChild("Container")
	self.CharmsHeaderIcon = self.CharmsContainer:WaitForChild("Header"):WaitForChild("Icon")
	self.CharmsSlotsFrame = self.CharmsContainer:WaitForChild("Slots")
	self.CharmsSlotsLayout = self.CharmsSlotsFrame:WaitForChild("Layout")
	self.LoginRewards = LoginRewards.new(self)
	self._is_open_hash = 0
	self._shop_slots = {}
	self:_Init()
	return self
end

function Daily:Generate()
	for _, _shop_slot in pairs(self._shop_slots) do
		_shop_slot:Destroy()
	end

	self._shop_slots = {}

	if not self.Pages.Shop:IsOpen() then
		return
	end

	local v = PlayerDataController:GetStatistic("StatisticDuelsPlayed") >= EventLibrary.NUM_GAMES_NEEDED_TO_PARTICIPATE
	PlayerDataController:Get("CosmeticInventory")

	for k, v2 in pairs(ShopController:GetDailyShop()) do
		if not (not v2.Prices.EventCurrency or v) then
			continue
		end

		local reward = v2.Rewards[1]
		local cosmetic = CosmeticLibrary.Cosmetics[reward.Name]
		local finishersSlotsFrame = cosmetic.Type == "Finisher" and self.FinishersSlotsFrame or cosmetic.Type == "Wrap" and self.WrapsSlotsFrame or cosmetic.Type == "Charm" and self.CharmsSlotsFrame or self.SkinsContainer
		local v3

		if cosmetic.Type == "Skin" or cosmetic.Type == "Emote" then
			v3 = BigShopSlot
		else
			v3 = ShopSlot
		end

		local shopSlot = self.Pages.Shop:CreateShopSlot(v3, nil, v2.EntryName)
		shopSlot.Frame.LayoutOrder = k
		shopSlot.Frame.ZIndex = k
		shopSlot.Frame.Parent = finishersSlotsFrame
		table.insert(self._shop_slots, shopSlot)

		if cosmetic.Type == "Emote" and cosmetic.EmoteDescription then
			shopSlot:SetDescription(cosmetic.EmoteDescription)
		end
	end
end

function Daily:Open()
	self._is_open_hash += 1
	task.spawn(self._CountdownLoop, self)
	self:Generate()
	self:_UpdateFrame()
	self:_UpdateSizes()
	self.LoginRewards:Open()
end

function Daily:Close()
	self._is_open_hash += 1
	self:Generate()
	self.LoginRewards:Close()
end

function Daily:Setup()
	self:Generate()
	self.LoginRewards:Setup()
end

function Daily:_CountdownLoop()
	self._is_open_hash += 1
	local _is_open_hash = self._is_open_hash

	while _is_open_hash == self._is_open_hash do
		self.CountdownTimer.Text = "<font transparency=\"0.5\" size=\"9\">shop will refresh in</font> " .. Utility:TimeFormat2(ShopController:GetDailyShopRefreshTimeRemaining())
		wait(1)
	end
end

function Daily:_UpdateRefreshText()
	self.CountdownRefreshPrice.Text = LootLibrary:GetCostToRefreshDailyShop(PlayerDataController:Get("DailyShopRefreshesToday"))
end

function Daily:_UpdateSizes()
	self.SkinsFrame.Size = UDim2.new(
		1,
		0,
		0,
		self.SkinsLayout.AbsoluteContentSize.Y + self.SkinsFrame.AbsoluteSize.X * 440 / 1173 * 0.05
	)
	self.FinishersFrame.Size = UDim2.new(
		1,
		0,
		0,
		self.FinishersSlotsLayout.AbsoluteContentSize.Y + self.FinishersSlotsFrame.AbsolutePosition.Y - self.FinishersContainer.AbsolutePosition.Y + 0.05 * self.FinishersContainer.AbsoluteSize.Y
	)
	self.WrapsFrame.Size = UDim2.new(
		1,
		0,
		0,
		self.WrapsSlotsLayout.AbsoluteContentSize.Y + self.WrapsSlotsFrame.AbsolutePosition.Y - self.WrapsContainer.AbsolutePosition.Y + 0.05 * self.WrapsContainer.AbsoluteSize.Y
	)
	self.CharmsFrame.Size = UDim2.new(
		1,
		0,
		0,
		self.CharmsSlotsLayout.AbsoluteContentSize.Y + self.CharmsSlotsFrame.AbsolutePosition.Y - self.CharmsContainer.AbsolutePosition.Y + 0.05 * self.CharmsContainer.AbsoluteSize.Y
	)
end

function Daily:_UpdateFrame()
	self.Frame.Size = UDim2.new(1, 0, 0, self.Layout.AbsoluteContentSize.Y)
end

function Daily:_Setup()
	self.FinishersHeaderIcon = CosmeticLibrary.Types.Finisher.Image
	self.WrapsHeaderIcon = CosmeticLibrary.Types.Wrap.Image
	self.CharmsHeaderIcon = CosmeticLibrary.Types.Charm.Image
end

function Daily:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateFrame()
	end)
	self.SkinsFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateSizes()
	end)
	self.SkinsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateSizes()
	end)
	self.FinishersSlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateSizes()
	end)
	self.FinishersSlotsFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateSizes()
	end)
	self.FinishersContainer:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateSizes()
	end)
	self.FinishersContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateSizes()
	end)
	self.WrapsSlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateSizes()
	end)
	self.WrapsSlotsFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateSizes()
	end)
	self.WrapsContainer:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateSizes()
	end)
	self.WrapsContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateSizes()
	end)
	self.CharmsSlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateSizes()
	end)
	self.CharmsSlotsFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateSizes()
	end)
	self.CharmsContainer:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateSizes()
	end)
	self.CharmsContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateSizes()
	end)
	self.CountdownRefreshPriceIcon:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self.CountdownRefreshPrice.Position = UDim2.new(0.5, -self.CountdownRefreshPriceIcon.AbsoluteSize.X / 2, 0.5, 0)
		self.CountdownRefreshPriceIcon.Position = UDim2.new(0.5, self.CountdownRefreshPrice.TextBounds.X / 2, 0.5, 0)
	end)
	self.CountdownRefreshButton.MouseButton1Click:Connect(function()
		local costToRefreshDailyShop = LootLibrary:GetCostToRefreshDailyShop(PlayerDataController:Get("DailyShopRefreshesToday"))

		if PlayerDataController:Get("WeaponKeys") < costToRefreshDailyShop then
			self.Pages.Shop:SetPage("Currency")
			MonetizationController:PromptCurrencyBundlePurchase(costToRefreshDailyShop, "WeaponKeys")
		else
			ShopController:BuyDailyShopRefresh()
			Utility:CreateSound("rbxassetid://18100002432", 1.25, 1, script, true, 5)
		end
	end)
	PlayerDataController:GetDataChangedSignal("DailyShopRefreshesToday"):Connect(function()
		self:_UpdateRefreshText()
	end)
	PlayerDataController:GetDataChangedSignal("CosmeticInventory"):Connect(function()
		self:Generate()
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:Generate()
	end)
	ShopController.DailyShopRefreshed:Connect(function()
		self:Generate()
	end)
	self:_Setup()
	self:_UpdateFrame()
	self:_UpdateSizes()
	self:_UpdateRefreshText()
	ButtonEffect:Add(self.CountdownRefreshButton)
end

return Daily