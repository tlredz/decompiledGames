local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules.WeaponStatusHandler)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local equipmentMetricActionSlot = Players.LocalPlayer.PlayerScripts.UserInterface.EquipmentMetricActionSlot
local PrimaryActions = {}
PrimaryActions.__index = PrimaryActions

function PrimaryActions.new(right)
	local self = setmetatable({}, PrimaryActions)
	self.Right = right
	self.Frame = self.Right.Container:WaitForChild("PrimaryActions")
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.ContractsFrame = self.Container:WaitForChild("Contracts")
	self.ContractsButton = self.ContractsFrame:WaitForChild("Button")
	self.DuelHistoryFrame = self.Container:WaitForChild("DuelHistory")
	self.DuelHistoryButton = self.DuelHistoryFrame:WaitForChild("Button")
	self.MapsFrame = self.Container:WaitForChild("Maps")
	self.MapsButton = self.MapsFrame:WaitForChild("Button")
	self.CollectionFrame = self.Container:WaitForChild("Collection")
	self.CollectionButton = self.CollectionFrame:WaitForChild("Button")
	self.CareerFrame = self.Container:WaitForChild("Career")
	self.CareerButton = self.CareerFrame:WaitForChild("Button")
	self.CareerIcon = self.CareerFrame:WaitForChild("Icon")
	self.WeaponFrame = self.Container:WaitForChild("Weapon")
	self.WeaponButton = self.WeaponFrame:WaitForChild("Button")
	self.WeaponTitle = self.WeaponFrame:WaitForChild("Title")
	self.WeaponIcon = self.WeaponFrame:WaitForChild("Icon")
	self._last_state = nil
	self._back_to_weapon = nil
	self._metric_action_slots = {}
	self:_Init()
	return self
end

function PrimaryActions:SetMetricActionVisible(p, p2)
	if not self._metric_action_slots[p] then
		return
	end

	self._metric_action_slots[p].Visible = p2 and self:_IsMetricActionVisible(p)
	self:_UpdateVisibility()
end

function PrimaryActions:CreateMetricAction(name, image, text, text2)
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

function PrimaryActions:OnStateChanged()
	task.defer(self._UpdateInformation, self)
end

function PrimaryActions:OnOpen()
	self:_UpdateInformation(true)
end

function PrimaryActions:_IsMetricActionVisible(value)
	local isCareerPageOpen = self.Right.Interface.Equipment:IsCareerPageOpen()
	local weaponData = PlayerDataController:GetWeaponData((self.Right.Interface.Equipment:GetSelectedWeapon()))

	if value == "Performance" then
		if weaponData == nil then
			return isCareerPageOpen
		end
	else
		if value == "Overview" then
			return weaponData ~= nil
		end

		if #value >= 7 and string.sub(value, 1, 7) == "season_" then
			return isCareerPageOpen
		end
	end

	return true
end

function PrimaryActions:_UpdateInformation(p)
	local isCareerPageOpen = self.Right.Interface.Equipment:IsCareerPageOpen()
	local weaponData = PlayerDataController:GetWeaponData((self.Right.Interface.Equipment:GetSelectedWeapon()))
	local stateID = self.Right.Interface.Equipment:GetStateID()

	if p or stateID ~= self._last_state then
		self._last_state = stateID
		local back_to_weapon

		if isCareerPageOpen then
			back_to_weapon = self._back_to_weapon
		end

		self._back_to_weapon = back_to_weapon
		self.Right:ResetMetricCards()
	end

	local item = ItemLibrary.Items[self._back_to_weapon]
	self.WeaponIcon.Image = not item and "" or item.Image or ""
	self.WeaponTitle.Text = self._back_to_weapon or ""
	WeaponStatusHandler:ClearStatusElements(self.WeaponTitle)
	WeaponStatusHandler:ApplyItemStatusToText(self.WeaponTitle, item and item.Status)
	self.WeaponFrame.Visible = isCareerPageOpen and self._back_to_weapon
	self.CareerFrame.Visible = false
	self.ContractsFrame.Visible = weaponData
	self.DuelHistoryFrame.Visible = isCareerPageOpen
	self.MapsFrame.Visible = isCareerPageOpen
	self.CollectionFrame.Visible = isCareerPageOpen
	self:_UpdateVisibility()
end

function PrimaryActions:_UpdateVisibility()
	local visible = self.ContractsFrame.Visible or self.DuelHistoryFrame.Visible or self.MapsFrame.Visible or self.CollectionFrame.Visible or self.CareerFrame.Visible
	local v = false

	for _, _metric_action_slot in pairs(self._metric_action_slots) do
		v = v or _metric_action_slot.Visible
	end

	self.Frame.Visible = visible or v
end

function PrimaryActions:_UpdateSize()
	self.Frame.Size = UDim2.new(1, 0, 0, self.Layout.AbsoluteContentSize.Y)
end

function PrimaryActions:_Setup()
	self.CareerIcon.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, Players.LocalPlayer.UserId)
end

function PrimaryActions:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateSize()
	end)
	self.ContractsButton.MouseButton1Click:Connect(function()
		Pages.PageSystem:OpenPage("Contracts")
		Pages.PageSystem:WaitForPage("Contracts"):SetWeapon(self.Right.Interface.Equipment:GetSelectedWeapon())
	end)
	self.DuelHistoryButton.MouseButton1Click:Connect(function()
		Pages.PageSystem:OpenPage("DuelHistory")
	end)
	self.MapsButton.MouseButton1Click:Connect(function()
		Pages.PageSystem:OpenPage("Maps")
	end)
	self.CollectionButton.MouseButton1Click:Connect(function()
		Pages.PageSystem:OpenPage("Collection")
	end)
	self.CareerButton.MouseButton1Click:Connect(function()
		self._back_to_weapon = self.Right.Interface.Equipment:GetSelectedWeapon()
		self.Right.Interface.Equipment:OpenCareerPage(true)
	end)
	self.WeaponButton.MouseButton1Click:Connect(function()
		self.Right.Interface.Equipment:SelectWeapon(self._back_to_weapon)
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_UpdateInformation()
	end)
	self:_Setup()
	self:_UpdateSize()
	self:_UpdateVisibility()
	self:CreateMetricAction("Overview", "rbxassetid://18404346057", "Overview", "View weapon metrics")
	self:CreateMetricAction("Performance", "rbxassetid://17336063541", "Statistics", "See lifetime data")
	ButtonEffect:Add(self.ContractsButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
	ButtonEffect:Add(self.DuelHistoryButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
	ButtonEffect:Add(self.MapsButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
	ButtonEffect:Add(self.CollectionButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
	ButtonEffect:Add(self.CareerButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
	ButtonEffect:Add(self.WeaponButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
end

return PrimaryActions