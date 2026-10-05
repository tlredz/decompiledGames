local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local cosmeticSlotEmpty = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("CosmeticSlotEmpty")
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.SlotsFrame = self.Container:WaitForChild("Slots")
	self.SlotsContainer = self.SlotsFrame:WaitForChild("Container")
	self.SlotsLayout = self.SlotsContainer:WaitForChild("Layout")
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self._slots = {}
	self._generation_queued = false
	self:_Init()
	return self
end

function object:Open(...)
	Page.Open(self, ...)
	self:_Generate()
end

function object:Close(...)
	Page.Close(self, ...)
	self:_Generate()
end

function object:_Generate()
	for _, _slot in pairs(self._slots) do
		_slot:Destroy()
	end

	self._slots = {}

	if not self:IsOpen() then
		return
	end

	local unclaimedRewards = PlayerDataController:Get("UnclaimedRewards")

	if #unclaimedRewards == 0 then
		self.Closed:Fire()
		return
	end

	local clone = table.clone(unclaimedRewards)
	table.sort(clone, function(a, b)
		local v = CosmeticLibrary.Rewards[a.Name] ~= nil
		local selected = CosmeticLibrary.Rewards[b.Name] ~= nil

		if v ~= selected then
			return selected
		end

		local value = not v and CosmeticLibrary.Rarities[CosmeticLibrary.Cosmetics[a.Name].Rarity].Value
		local value2 = not selected and CosmeticLibrary.Rarities[CosmeticLibrary.Cosmetics[b.Name].Rarity].Value

		if value ~= value2 then
			return value2 < value
		end

		local value3 = not v and CosmeticLibrary.Types[CosmeticLibrary.Cosmetics[a.Name].Type].Value
		local value4 = not selected and CosmeticLibrary.Types[CosmeticLibrary.Cosmetics[b.Name].Type].Value

		if value3 ~= value4 then
			return value4 < value3
		end

		local quantity = a.Quantity or 1
		local quantity2 = b.Quantity or 1
		local v3

		if quantity ~= quantity2 then
			v3 = quantity2 < quantity
		end

		local v4

		if a.Name ~= b.Name then
			v4 = Utility:StringLessThan(a.Name, b.Name)
		end

		local v5 = v and CosmeticLibrary.Rewards[a.Name].Type == "Lootbox"
		local v6 = selected and CosmeticLibrary.Rewards[b.Name].Type == "Lootbox"

		if v5 ~= v6 then
			return v6
		end

		if v5 and v6 then
			if v4 ~= nil then
				return v4
			end

			if v3 ~= nil then
				return v3
			end
		else
			if v3 ~= nil then
				return v3
			end

			if v4 ~= nil then
				return v4
			end
		end

		local weapon = a.Weapon
		local weapon2 = b.Weapon

		if weapon == weapon2 or weapon and not weapon2 then
			return false
		end

		if weapon or not weapon2 then
			return Utility:StringLessThan(a.Weapon, b.Weapon)
		end

		return true
	end)

	for k, v in pairs(clone) do
		local index = table.find(unclaimedRewards, v)
		local reward = CosmeticLibrary.Rewards[v.Name]

		if reward then
			local _ = reward.Type == "Lootbox"
		end

		local v2 = RewardSlot.new(v)
		v2.Frame.LayoutOrder = k
		v2:SetParent(self.SlotsContainer)
		table.insert(self._slots, v2)
		v2:OnClick(function()
			self.PromptSystem:Open("InspectBackpackReward", index)
		end)
	end

	for _ = 1, 12 - ((#self._slots - 1) % 6 + 1) do
		local clone2 = cosmeticSlotEmpty:Clone()
		clone2.Background.BackgroundTransparency = 0.5
		clone2.LayoutOrder = 9999999
		clone2.Parent = self.SlotsContainer
		table.insert(self._slots, clone2)
	end
end

function object:_QueueGenerate()
	if self._generation_queued then
		return
	end

	self._generation_queued = true
	task.defer(function()
		self._generation_queued = false
		self:_Generate()
	end)
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
		self.List.Active = self.Layout.AbsoluteContentSize.Y >= self.List.AbsoluteSize.Y
	end)
	self.SlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.SlotsFrame.Size = UDim2.new(1, 0, 0, self.SlotsLayout.AbsoluteContentSize.Y)
	end)
	self.PromptSystem.PromptAdded:Connect(function(p)
		if p.ClosePage then
			p.ClosePage:Connect(function()
				self.Closed:Fire()
			end)
		end
	end)
	PlayerDataController:GetDataChangedSignal("UnclaimedRewards"):Connect(function()
		self:_QueueGenerate()
	end)
	self:_Generate()
	ButtonEffect:Add(self.CloseButton)
end

return object._new()