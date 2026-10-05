local Players = game:GetService("Players")
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local equipmentMetricActionSlot = Players.LocalPlayer.PlayerScripts.UserInterface.EquipmentMetricActionSlot
local SecondaryActions = {}
SecondaryActions.__index = SecondaryActions

function SecondaryActions.new(right)
	local self = setmetatable({}, SecondaryActions)
	self.Right = right
	self.Frame = self.Right.Container:WaitForChild("SecondaryActions")
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self._last_state = nil
	self._metric_action_slots = {}
	self:_Init()
	return self
end

function SecondaryActions:SetMetricActionVisible(p, p2)
	if not self._metric_action_slots[p] then
		return
	end

	self._metric_action_slots[p].Visible = p2 and self:_IsMetricActionVisible(p)
	self:_UpdateVisibility()
end

function SecondaryActions:CreateMetricAction(name, image, text, text2)
	local clone = equipmentMetricActionSlot:Clone()
	clone.Icon.Image = image
	clone.Title.Text = text
	clone.Description.Text = text2
	clone.Name = name
	clone.Visible = false
	clone.Parent = self.Container
	self._metric_action_slots[name] = clone
	clone.Button.MouseButton1Click:Connect(function()
		self.Right:SetMetricCardVisible(name, true)
	end)
	ButtonEffect:Add(clone.Button, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
end

function SecondaryActions:OnStateChanged()
	task.defer(self._UpdateInformation, self)
end

function SecondaryActions:OnOpen()
	self:_UpdateInformation(true)
end

function SecondaryActions:_IsMetricActionVisible(value)
	local isCareerPageOpen = self.Right.Interface.Equipment:IsCareerPageOpen()
	PlayerDataController:GetWeaponData((self.Right.Interface.Equipment:GetSelectedWeapon()))
	return not (#value >= 7) or string.sub(value, 1, 7) ~= "season_" or isCareerPageOpen
end

function SecondaryActions:_UpdateInformation(p)
	self.Right.Interface.Equipment:IsCareerPageOpen()
	PlayerDataController:GetWeaponData((self.Right.Interface.Equipment:GetSelectedWeapon()))
	local stateID = self.Right.Interface.Equipment:GetStateID()

	if p or stateID ~= self._last_state then
		self._last_state = stateID
		self.Right:ResetMetricCards()
	end

	self:_UpdateVisibility()
end

function SecondaryActions:_UpdateVisibility()
	local visible = false

	for _, _metric_action_slot in pairs(self._metric_action_slots) do
		visible = visible or _metric_action_slot.Visible
	end

	self.Frame.Visible = visible
end

function SecondaryActions:_UpdateSize()
	self.Frame.Size = UDim2.new(1, 0, 0, self.Layout.AbsoluteContentSize.Y)
end

function SecondaryActions:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateSize()
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_UpdateInformation()
	end)
	self:_UpdateSize()
	self:_UpdateVisibility()
end

return SecondaryActions