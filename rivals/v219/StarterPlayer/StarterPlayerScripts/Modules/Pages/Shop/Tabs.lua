local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
require(ReplicatedStorage.Modules.SeasonLibrary)
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local SeasonController = require(Players.LocalPlayer.PlayerScripts.Controllers.SeasonController)
local ShopController = require(Players.LocalPlayer.PlayerScripts.Controllers.ShopController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local uDim = UDim2.new(0.125, 0, 0.875, 0)
local Tabs = {}
Tabs.__index = Tabs

function Tabs.new(shop)
	local self = setmetatable({}, Tabs)
	self.Shop = shop
	self.Frame = self.Shop.Container:WaitForChild("Tabs")
	self.CloseButton = self.Frame:WaitForChild("Close")
	self.RankedButton = self.Frame:WaitForChild("Ranked")
	self.CurrencyButton = self.Frame:WaitForChild("Currency")
	self.CurrencyIcon = self.CurrencyButton:WaitForChild("Icon")
	self.CurrencyEventIcon = self.CurrencyButton:WaitForChild("EventIcon")
	self.WeaponsButton = self.Frame:WaitForChild("Weapons")
	self.GiftingButton = self.Frame:WaitForChild("Gifting")
	self.RewardsButton = self.Frame:WaitForChild("Rewards")
	self.MoreButton = self.Frame:WaitForChild("More")
	self.LessButton = self.Frame:WaitForChild("Less")
	self._buttons = {}
	self._more_buttons_visible = false
	self:_Init()
	return self
end

function Tabs:Open()
	self:_CloseMoreTabs()
end

function Tabs:Close()
	self:_CloseMoreTabs()
end

function Tabs:Setup()
	self:_CloseMoreTabs()
end

function Tabs:_OpenMoreTabs()
	self._more_buttons_visible = true

	for _, _button in pairs(self._buttons) do
		_button.Visible = false
	end

	self.MoreButton.Visible = false
	self.LessButton.Visible = true

	for _, v in pairs({
		self.RankedButton,
		self.WeaponsButton,
		self.GiftingButton,
		self.RewardsButton
	}) do
		v.Size = UDim2.new(uDim.X.Scale * 0.5, 0, uDim.Y.Scale * 0.5, 0)
		v:TweenSize(uDim, "Out", "Quint", 0.25, true)
		v.Visible = true
	end

	self:_UpdateVisibility()
end

function Tabs:_CloseMoreTabs()
	self._more_buttons_visible = false

	for _, _button in pairs(self._buttons) do
		_button.Size = UDim2.new(uDim.X.Scale * 0.5, 0, uDim.Y.Scale * 0.5, 0)
		_button:TweenSize(uDim, "Out", "Quint", 0.25, true)
		_button.Visible = true
	end

	self.MoreButton.Visible = true
	self.LessButton.Visible = false
	self.WeaponsButton.Visible = false
	self.GiftingButton.Visible = false
	self.RewardsButton.Visible = false
	self.RankedButton.Visible = false
	self:_UpdateVisibility()
end

function Tabs:_UpdateEvent()
	local visible = EventLibrary.IS_ACTIVE and PlayerDataController:GetStatistic("StatisticDuelsPlayed") >= EventLibrary.NUM_GAMES_NEEDED_TO_PARTICIPATE
	self.CurrencyEventIcon.Visible = visible
	self.CurrencyEventIcon.Image = EventLibrary.EVENT_DETAILS.CURRENCY_IMAGE
	self.CurrencyIcon.Position = visible and UDim2.new(0.4, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 0)
end

function Tabs:_UpdateVisibility()
	self.RankedButton.Visible = self._more_buttons_visible and (SeasonController:IsRankedUnlocked() or PlayerDataController:Get("Glory") > 0)
	self.WeaponsButton.Visible = self._more_buttons_visible and self.LocalFighter and not (self.LocalFighter:Get("IsInShootingRange") or self.LocalFighter:Get("IsInDuel"))
end

function Tabs:_Update()
	for _, childName in pairs(self.Shop.PAGE_NAMES) do
		local v = childName == self.Shop.CurrentPage
		local child = self.Frame:WaitForChild(childName)
		local background = child:WaitForChild("Background")
		local title = child:WaitForChild("Title")
		local uIStroke = title:WaitForChild("UIStroke")
		title.TextColor3 = v and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
		uIStroke.Color = v and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
		uIStroke.Transparency = v and 0 or 0.75
		background.ImageColor3 = v and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
		background.ImageTransparency = v and 0 or 0.25
		local uIGradient = background:WaitForChild("UIGradient")
		uIGradient.Enabled = not v
	end

	if self.Shop.CurrentPage == "Daily" and PlayerDataController:Get("LastDailyShopSeen") ~= ShopController.DailyShopDay then
		ReplicatedStorage.Remotes.Misc.ViewedDailyShop:FireServer()
	end
end

function Tabs:_HookLocalFighter()
	self.LocalFighter = FighterController:WaitForLocalFighter()
	self.LocalFighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_UpdateVisibility()
	end)
	self.LocalFighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_UpdateVisibility()
	end)
	self:_UpdateVisibility()
end

function Tabs:_Setup()
	for _, childName in pairs(self.Shop.PAGE_NAMES) do
		local child = self.Frame:WaitForChild(childName)
		self._buttons[childName] = child
		local v = childName
		child.MouseButton1Click:Connect(function()
			self.Shop:SetPage(v)
		end)
		ButtonEffect:Add(child)

		if childName ~= "Daily" then
			continue
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local v2 = child
		local v3 = "Daily"

		local function update()
			local notificationBubble = v2.NotificationBubble
			notificationBubble.Visible = self.Shop.CurrentPage ~= v3 and not PlayerDataController:Get("ClaimedLoginRewardToday")
		end

		PlayerDataController:GetDataChangedSignal("ClaimedLoginRewardToday"):Connect(update)
		self.Shop.CurrentPageChanged:Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end
end

function Tabs:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self.Shop:CloseRequest()
	end)
	self.Shop.CurrentPageChanged:Connect(function()
		self:_Update()
	end)
	self.MoreButton.MouseButton1Click:Connect(function()
		self:_OpenMoreTabs()
	end)
	self.LessButton.MouseButton1Click:Connect(function()
		self:_CloseMoreTabs()
	end)
	PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
		self:_UpdateEvent()
	end)
	PlayerDataController:GetDataChangedSignal("Glory"):Connect(function()
		self:_UpdateVisibility()
	end)
	self:_Setup()
	self:_UpdateEvent()
	self:_UpdateVisibility()
	task.defer(self._HookLocalFighter, self)
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.MoreButton)
	ButtonEffect:Add(self.LessButton)
end

return Tabs