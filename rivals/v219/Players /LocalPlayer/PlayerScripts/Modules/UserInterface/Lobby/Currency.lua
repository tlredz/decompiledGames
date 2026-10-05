local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local CurrencyLibrary = require(ReplicatedStorage.Modules.CurrencyLibrary)
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
require(ReplicatedStorage.Modules.ItemLibrary)
local TaskLibrary = require(ReplicatedStorage.Modules.TaskLibrary)
local TestLibrary = require(ReplicatedStorage.Modules.TestLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local Matchmaking = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Lobby:WaitForChild("Matchmaking"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileInputs"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local Queue = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Queue"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local testAttribute = TestLibrary:GetTestAttribute("StudioSkipOnboarding")
local currencySlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("CurrencySlot")
local v = {
	EventCurrency = true,
	SkinTickets = true
}
local v2 = {
	Shop = true,
	EventOverview = true,
	StreakRecovery = true
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("MainFrame", "Lobby", "Currency")
	self.Container = self.Frame:WaitForChild("Container")
	self._is_open = false
	self._is_shrinked = false
	self._currency_slots = {}
	self._setup_update_slots_logic = false
	self._scrolled_up_hooked = {}
	self._scrolled_up = {}
	self._keys_bubble = nil
	self._keys_bubble_hash = 0
	self:_Init()
	return self
end

function class:_UpdateOnboardingBubble()
	if not self._keys_bubble or testAttribute then
		return
	end

	local v3 = PlayerDataController:Get("BeginnerTasksCompleted") >= TaskLibrary.NUM_BEGINNER_TASKS
	self._keys_bubble.Visible = self._is_open and not self._is_shrinked and not v3 and PlayerDataController:GetStatistic("StatisticDuelsPlayed") >= 2
	self._keys_bubble_hash += 1
	local _keys_bubble_hash = self._keys_bubble_hash

	if not self._keys_bubble.Visible then
		return
	end

	task.spawn(function()
		while _keys_bubble_hash == self._keys_bubble_hash do
			if self._keys_bubble:IsDescendantOf(Players) then
				self._keys_bubble:TweenPosition(UDim2.new(0.5, 0, 1, 0), "Out", "Sine", 0.5, true)
			end

			wait(0.5)

			if _keys_bubble_hash ~= self._keys_bubble_hash then
				break
			end

			if self._keys_bubble:IsDescendantOf(Players) then
				self._keys_bubble:TweenPosition(UDim2.new(0.5, 0, 0.875, 0), "In", "Sine", 0.5, true)
			end

			wait(0.5)
		end
	end)
end

function class:_IsScrolledUp()
	for _, v3 in pairs(self._scrolled_up) do
		if v3 then
			return true
		end
	end
end

function class:_UpdateVisibility()
	self._is_open = (not Pages.PageSystem.CurrentPage or Pages.PageSystem.CurrentPage.Name == "StreakRecovery" or v2[Pages.PageSystem.CurrentPage.Name]) and not Matchmaking:IsOpened() and not (Equipment:IsUnlocking() or Equipment:IsCustomizing()) and (not Equipment.IsOpen or Equipment:IsOpenEffectDone()) and not Queue:IsVisible() and not (Teleporting.Enabled or MobileInputs.EditorEnabled or GuiService.MenuIsOpen or self:_IsScrolledUp())
	self._is_shrinked = false

	if self.Container:IsDescendantOf(Players) then
		self.Container:TweenPosition(
			self._is_open and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0.5, 0, -0.15, -30),
			"Out",
			"Quint",
			0.25,
			true
		)
		self.Container:TweenSize(
			self._is_shrinked and UDim2.new(0.0375, 20, 0.0375, 20) or UDim2.new(0.075, 40, 0.075, 40),
			"Out",
			"Quint",
			0.25,
			true
		)
	end

	self:_UpdateOnboardingBubble()
end

function class:_UpdateSlots()
	local page = Pages.PageSystem:GetPage("Shop")
	local v3 = page and page:IsOpen()
	local v4 = v3 and page.CurrentPage == "Ranked"
	local page2 = Pages.PageSystem:GetPage("EventOverview")
	local v5 = page2 and page2:IsOpen()

	for k, _currency_slot in pairs(self._currency_slots) do
		local v6 = CurrencyLibrary.Info[k]
		local v7 = PlayerDataController:Get(v6.DataName) or 0
		local visible

		if v6.OnlyDisplayAboveZeroBalance and not (v7 > 0) then
			visible = false
		elseif k == "Glory" and v4 then
			visible = v3 or "Glory" == "WeaponKeys" or v5 and v.Glory
		elseif k == "Glory" then
			visible = false
		else
			visible = not v4

			if visible then
				visible = v3 or k == "WeaponKeys" or v5 and v[k]
			end
		end

		_currency_slot.Visible = visible
		_currency_slot.Title.Text = Utility:PrettyNumber(v7)
	end
end

function class:_SetupUpdateSlotsLogic()
	if self._setup_update_slots_logic then
		return
	end

	self._setup_update_slots_logic = true
	task.spawn(function()
		Pages.PageSystem:WaitForPage("EventOverview").OpenChanged:Connect(function()
			self:_UpdateSlots()
		end)
		self:_UpdateSlots()
	end)
	task.spawn(function()
		local shop = Pages.PageSystem:WaitForPage("Shop")
		shop.OpenChanged:Connect(function()
			self:_UpdateSlots()
		end)
		shop.CurrentPageChanged:Connect(function()
			self:_UpdateSlots()
		end)
		self:_UpdateSlots()
	end)
end

function class:_SetupScrollUpLogic(p)
	if self._scrolled_up_hooked[p] then
		return
	end

	self._scrolled_up_hooked[p] = true
	local v3 = Pages.PageSystem:WaitForPage(p)
	v3.OpenChanged:Connect(function()
		if not v3:IsOpen() then
			self._scrolled_up[p] = false
		end
	end)
	v3.List:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if not v3:IsOpen() or v3.List.CanvasPosition.Y > 10 and self._scrolled_up[p] or v3.List.CanvasPosition.Y <= 10 and not self._scrolled_up[p] then
			return
		end

		self._scrolled_up[p] = v3.List.CanvasPosition.Y > 10
		self:_UpdateVisibility()
	end)
	self:_UpdateVisibility()
end

function class:_Setup()
	for k, v3 in pairs(CurrencyLibrary.Order) do
		local v4 = CurrencyLibrary.Info[v3]

		if v4.IsHidden or not (v3 ~= "EventCurrency" or EventLibrary.IS_ACTIVE) then
			continue
		end

		local clone = currencySlot:Clone()
		clone.LayoutOrder = k
		clone.Icon.Icon.Image = v4.Image
		clone.Buy.Visible = v4.CanBePurchasedWithRobux
		clone.Parent = self.Container
		self._currency_slots[v3] = clone
		PlayerDataController:GetDataChangedSignal(v4.DataName):Connect(function()
			self:_UpdateSlots()
		end)
		clone.Buy.MouseButton1Click:Connect(function()
			Pages.PageSystem:OpenPage("Shop", true)
			Pages.PageSystem:WaitForPage("Shop"):SetPage("Currency")
		end)
		ButtonEffect:Add(clone.Buy)

		if v3 ~= "WeaponKeys" then
			continue
		end

		self._keys_bubble = clone.Icon.Bubble
		clone.Icon.MouseButton1Click:Connect(function()
			Pages.PageSystem:OpenPage("Tasks", true)
		end)
		ButtonEffect:Add(clone.Icon)
	end
end

function class:_Init()
	Equipment.UnlockingChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Equipment.Opened:Connect(function()
		self:_UpdateVisibility()
	end)
	Equipment.SelectedWeaponChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Equipment.CustomizingChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Equipment.FinishedOpenEffect:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PageOpened:Connect(function(p)
		if v2[p.Name] then
			task.spawn(self._SetupScrollUpLogic, self, p.Name)
			task.spawn(self._SetupUpdateSlotsLogic, self)
		end

		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PageClosed:Connect(function()
		self:_UpdateVisibility()
	end)
	Queue.VisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Teleporting.EnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Matchmaking.OpenedChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	PlayerDataController:GetDataChangedSignal("BeginnerTasksCompleted"):Connect(function()
		self:_UpdateOnboardingBubble()
	end)
	PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
		self:_UpdateOnboardingBubble()
		self:_UpdateSlots()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_UpdateVisibility()
	end)
	self:_Setup()
	self:_UpdateSlots()
	self:_UpdateVisibility()
	self:_UpdateOnboardingBubble()
end

return class._new()