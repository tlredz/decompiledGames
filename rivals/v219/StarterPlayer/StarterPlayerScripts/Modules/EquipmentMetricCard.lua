local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local equipmentMetricSeasonRewardsSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EquipmentMetricSeasonRewardsSlot")
local equipmentMetricCard = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EquipmentMetricCard")
local equipmentMetricSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EquipmentMetricSlot")
local EquipmentMetricCard = {}
EquipmentMetricCard.__index = EquipmentMetricCard

function EquipmentMetricCard.new(title, icon)
	local self = setmetatable({}, EquipmentMetricCard)
	self.Clicked = Signal.new()
	self.Opened = Signal.new()
	self.Frame = equipmentMetricCard:Clone()
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.HeaderFrame = self.Container:WaitForChild("Header")
	self.CloseButton = self.HeaderFrame:WaitForChild("Button")
	self.Title = self.HeaderFrame:WaitForChild("Title")
	self.Icon = self.HeaderFrame:WaitForChild("Icon")
	self._title = title
	self._icon = icon
	self._elements = {}
	self._set_opened_hash = 0
	self._reward_slots = {}
	self:_Init()
	return self
end

function EquipmentMetricCard.GetScrollToElement(p)
	return p.Container
end

function EquipmentMetricCard:SetParent(parent)
	self.Frame.Parent = parent
end

function EquipmentMetricCard:SetOpened(visible)
	self._set_opened_hash += 1
	local _set_opened_hash = self._set_opened_hash
	self.Container.Visible = visible

	if visible then
		self.Frame.Visible = true
		self.Opened:Fire()
	elseif self.Frame:IsDescendantOf(Players.LocalPlayer.PlayerGui) then
		self.Frame:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quint", 0.25, true, function()
			if _set_opened_hash ~= self._set_opened_hash then
				return
			end

			self.Frame.Visible = false
		end)
	else
		self.Frame.Visible = false
	end
end

function EquipmentMetricCard:Add(text, text2)
	local clone = equipmentMetricSlot:Clone()
	clone.TitleContainer.Title.Text = text
	clone.Value.RichText = string.find(text2, "<")
	clone.Value.Text = text2
	clone.LayoutOrder = #self._elements
	clone.Parent = self.Container
	table.insert(self._elements, clone)
	UILibrary:ScrollingTextLabel(clone.TitleContainer, clone.TitleContainer.Title, clone.Value)
end

function EquipmentMetricCard:AddSeasonRewards(items)
	local clone = equipmentMetricSeasonRewardsSlot:Clone()
	clone.LayoutOrder = #self._elements

	for _, item in pairs(items) do
		local v = RewardSlot.new(item)
		v:SetParent(clone.RewardContainer)
		table.insert(self._reward_slots, v)
	end

	clone.Parent = self.Container
	table.insert(self._elements, clone)
end

function EquipmentMetricCard:Clear()
	for _, _element in pairs(self._elements) do
		_element:Destroy()
	end

	self._elements = {}
end

function EquipmentMetricCard:Destroy()
	for _, _reward_slot in pairs(self._reward_slots) do
		_reward_slot:Destroy()
	end

	self.Clicked:Destroy()
	self.Opened:Destroy()
	self.Frame:Destroy()
end

function EquipmentMetricCard:_Update()
	if not self.Container.Visible then
		return
	end

	self.Frame.Size = UDim2.new(1, 0, 0, self.Layout.AbsoluteContentSize.Y + self.Frame.AbsoluteSize.X * 0.05)
end

function EquipmentMetricCard:_Setup()
	self.Title.Text = self._title or ""
	self.Icon.Image = self._icon or ""
	self.Frame.Visible = false
end

function EquipmentMetricCard:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_Update()
	end)
	self.Container:GetPropertyChangedSignal("Visible"):Connect(function()
		self:_Update()
	end)
	self.CloseButton.MouseButton1Click:Connect(function()
		self.Clicked:Fire()
	end)
	self:_Setup()
	self:_Update()
	ButtonEffect:Add(self.CloseButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
end

return EquipmentMetricCard