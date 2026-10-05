local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local LootLibrary = require(ReplicatedStorage.Modules.LootLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MonetizationController"))
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local storedStreakSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("StoredStreakSlot")
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self._slots = {}
	self._countdown_thread = nil
	self:_Init()
	return self
end

function object:Open(...)
	Page.Open(self, ...)
	self:_Generate()
	self:_StartCountdownLoop()
end

function object:Close(...)
	Page.Close(self, ...)
	self:_StartCountdownLoop()
end

function object:_StartCountdownLoop()
	if self._countdown_thread then
		task.cancel(self._countdown_thread)
		self._countdown_thread = nil
	end

	if not self:IsOpen() then
		return
	end

	self._countdown_thread = task.spawn(function()
		while true do
			self:_UpdateCountdown()
			wait(1)
		end
	end)
end

function object:_UpdateCountdown()
	for _, _slot in pairs(self._slots) do
		local v

		if _slot.StoredStreak.ExpirationTime then
			v = _slot.StoredStreak.ExpirationTime - ServerOsTime:GetRounded()
		end

		_slot.Slot.Countdown.Icon.Visible = v ~= nil
		_slot.Slot.Countdown.Text = not v and "Oh no, you lost your win streak!" or v <= 0 and "Expired" or Utility:TimeFormat2(v)
		local countdown = _slot.Slot.Countdown
		local textColor

		if v and v <= 0 then
			textColor = Color3.fromRGB(255, 50, 50)
		else
			textColor = Color3.fromRGB(255, 255, 255)
		end

		countdown.TextColor3 = textColor
		_slot.Slot.Countdown.Icon.ImageColor3 = _slot.Slot.Countdown.TextColor3
	end
end

function object:_Generate()
	for _, _slot in pairs(self._slots) do
		_slot.Slot:Destroy()
	end

	self._slots = {}

	if not self:IsOpen() then
		return
	end

	for k, storedStreak in pairs(PlayerDataController:Get("StoredStreaks")) do
		local clone = storedStreakSlot:Clone()
		clone.Streak.Value.Text = Utility:PrettyNumber(storedStreak.Value)
		clone.Button.Price.Text = LootLibrary:GetRecoverStreakCost(storedStreak.ConsecutiveRecoveries)
		clone.LayoutOrder = k
		clone.Parent = self.Container
		table.insert(self._slots, {
			Slot = clone,
			StoredStreak = storedStreak
		})
		ButtonEffect:Add(clone.Button)
		local count = 0
		local v2 = storedStreak
		local title = clone.Title
		local v4 = k
		clone.Button.MouseButton1Click:Connect(function()
			if ServerOsTime:Get() > (v2.ExpirationTime or 1e999) then
				Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
				return
			end

			local recoverStreakCost = LootLibrary:GetRecoverStreakCost(v2.ConsecutiveRecoveries)

			if PlayerDataController:Get("WeaponKeys") < recoverStreakCost then
				Pages.PageSystem:OpenPage("Shop")
				Pages.PageSystem:WaitForPage("Shop"):SetPage("Currency")
				MonetizationController:PromptCurrencyBundlePurchase(recoverStreakCost, "WeaponKeys")
				self:CloseRequest()
			elseif title.Text == "Are you sure?" then
				Utility:CreateSound("rbxassetid://18228252652", 1, 1, script, true, 5)
				ReplicatedStorage.Remotes.Data.RecoverStreak:FireServer(v4)
				self:CloseRequest()
			else
				title.Text = "Are you sure?"
				count += 1
				local v5 = count
				wait(3)

				if v5 == count then
					title.Text = "Recover now"
				end
			end
		end)
		local countdown = clone.Countdown
		local icon = clone.Countdown.Icon
		local price = clone.Button.Price
		local icon2 = price.Icon

		local function update()
			price.Position = UDim2.new(0.5, -icon2.AbsoluteSize.X / 2, 0.5, 0)
			icon2.Position = UDim2.new(0.5, price.TextBounds.X / 2, 0.5, 0)
			countdown.Position = UDim2.new(0.5, not icon.Visible and 0 or icon.AbsoluteSize.X / 2, 0.1, 0)
			icon.Position = UDim2.new(0.5, -countdown.TextBounds.X / 2, 0.5, 0)
		end

		price:GetPropertyChangedSignal("TextBounds"):Connect(update)
		icon2:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		countdown:GetPropertyChangedSignal("TextBounds"):Connect(update)
		icon:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		icon:GetPropertyChangedSignal("Visible"):Connect(update)
		update()
	end

	self.CloseButton.Position = #self._slots > 1 and UDim2.new(0.95, 16, 0.0375) or UDim2.new(0.95, 16, 0.2575, 0)
	self.List.Position = #self._slots > 1 and UDim2.new(0.5, 9, 0, 0) or UDim2.new(0.5, 9, 0.22, 0)
	self:_StartCountdownLoop()
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	PlayerDataController:GetDataChangedSignal("StoredStreaks"):Connect(function()
		self:_Generate()
	end)
	self:_Generate()
	ButtonEffect:Add(self.CloseButton)
end

return object._new()