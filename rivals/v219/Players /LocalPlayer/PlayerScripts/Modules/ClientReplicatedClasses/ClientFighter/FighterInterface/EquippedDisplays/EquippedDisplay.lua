local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules.WeaponStatusHandler)
local InfiniteParticles = require(Players.LocalPlayer.PlayerScripts.Modules.InfiniteParticles)
require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local equippedDisplay = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EquippedDisplay")
local EquippedDisplay = {}
EquippedDisplay.__index = EquippedDisplay

function EquippedDisplay.new(equippedDisplays, clientItem)
	local self = setmetatable({}, EquippedDisplay)
	self.EquippedDisplays = equippedDisplays
	self.ClientItem = clientItem
	self.Frame = equippedDisplay:Clone()
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.WeaponFrame = self.Container:WaitForChild("Weapon")
	self.WeaponIcon = self.WeaponFrame:WaitForChild("Icon")
	self.DetailsFrame = self.Container:WaitForChild("Details")
	self.NameContainer = self.DetailsFrame:WaitForChild("NameContainer")
	self.ItemNameText = self.NameContainer:WaitForChild("Title")
	self.AmmoContainer = self.DetailsFrame:WaitForChild("AmmoContainer")
	self.AmmoLayout = self.AmmoContainer:WaitForChild("Layout")
	self.AmmoFrame = self.AmmoContainer:WaitForChild("Ammo")
	self.AmmoText = self.AmmoFrame:WaitForChild("Title")
	self.AmmoReserveFrame = self.AmmoContainer:WaitForChild("Reserve")
	self.AmmoReserveText = self.AmmoReserveFrame:WaitForChild("Title")
	self.AmmoIconFrame = self.AmmoContainer:WaitForChild("Icon")
	self.AmmoIcon = self.AmmoIconFrame:WaitForChild("Icon")
	self._connections = {}
	self._infinite_particles = InfiniteParticles.new(self.AmmoText, self.AmmoReserveText)
	self:_Init()
	return self
end

function EquippedDisplay:UpdateParent()
	task.defer(pcall, function()
		local v = PlayerDataController:GetSetting("Equipped Weapon Display") == "Legacy"
		local v2 = PlayerDataController:GetSetting("Equipped Weapon Display") == "Bottom Left" or v and PlayerDataController:GetSetting("Hotbar Display") == "Bottom Left"
		self.WeaponFrame.Visible = PlayerDataController:GetSetting("Equipped Weapon Icon")
		self.AmmoContainer.Visible = PlayerDataController:GetSetting("Equipped Weapon Ammo")
		self.DetailsFrame.LayoutOrder = v2 and 2 or 0
		self.AmmoContainer.AnchorPoint = v2 and Vector2.new(0, 0.5) or Vector2.new(1, 0.5)
		self.AmmoContainer.Position = v2 and UDim2.new(0.075, 0, 0.28, 0) or UDim2.new(0.925, 0, 0.28, 0)
		self.NameContainer.AnchorPoint = v2 and Vector2.new(0, 0.5) or Vector2.new(1, 0.5)
		self.NameContainer.Position = v2 and UDim2.new(0.05, 0, 0.75, 0) or UDim2.new(0.95, 0, 0.75, 0)
		self.ItemNameText.AnchorPoint = v2 and Vector2.new(0, 0.5) or Vector2.new(1, 0.5)
		self.ItemNameText.Position = v2 and UDim2.new(0, 0, 0.5, 0) or UDim2.new(1, 0, 0.5, 0)
		self.ItemNameText.TextXAlignment = v2 and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
		self.AmmoLayout.HorizontalAlignment = v2 and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Right
		self.Layout.HorizontalAlignment = v2 and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Right
		self.Frame.Parent = v and self.EquippedDisplays.FighterInterface.Hotbar.EquippedDisplayFrame or v2 and self.EquippedDisplays.FighterInterface.BottomLeft.Container or self.EquippedDisplays.FighterInterface.BottomRight.Container
		self:_UpdateSize()
	end)
end

function EquippedDisplay:UpdateVisibility()
	self.Frame.Visible = self.ClientItem:IsMainItem() and PlayerDataController:GetSetting("Equipped Weapon Display") ~= "Disabled"
end

function EquippedDisplay:UpdateAmmo()
	local ammoVariables, v, v2, v3 = self.ClientItem:GetAmmoVariables()
	local isMainItem = self.ClientItem:IsMainItem()
	self.AmmoReserveText.Text = not v and "" or v3 and "∞" or not ammoVariables and "" or " " .. v or ""
	self.AmmoReserveText.TextColor3 = v and v <= 0 and Color3.fromRGB(255, 50, 50) or isMainItem and Color3.fromRGB(
		255,
		255,
		255
	) or Color3.fromRGB(0, 0, 0)
	self.AmmoText.Text = v2 and "∞" or ammoVariables or ""
	self.AmmoText.TextColor3 = ammoVariables and ammoVariables <= 0 and Color3.fromRGB(255, 50, 50) or isMainItem and Color3.fromRGB(
		255,
		255,
		255
	) or Color3.fromRGB(0, 0, 0)
	self.AmmoIcon.Visible = ammoVariables ~= nil
	self.AmmoIcon.ImageColor3 = v and self.AmmoReserveText.TextColor3 or self.AmmoText.TextColor3
	self.AmmoIcon.ImageTransparency = v and self.AmmoReserveText.TextTransparency or self.AmmoText.TextTransparency
	self._infinite_particles:SetActive(v2, v3)
	self:_UpdateSize()
end

function EquippedDisplay:UpdateVisuals()
	local isMainItem = self.ClientItem:IsMainItem()
	self.ItemNameText.TextColor3 = isMainItem and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	self.ItemNameText.TextTransparency = isMainItem and 0 or 0.7
	self.AmmoText.TextTransparency = isMainItem and 0 or 0.7
	self.AmmoReserveText.TextTransparency = isMainItem and 0 or 0.7
	self:UpdateAmmo()
	self:UpdateVisibility()
	self:_UpdateSize()
end

function EquippedDisplay:Update(p2, _)
	self._infinite_particles:Update(p2)
end

function EquippedDisplay:Destroy()
	self._infinite_particles:Destroy()

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self.Frame:Destroy()
end

function EquippedDisplay:_UpdateSize()
	local v = PlayerDataController:GetSetting("Equipped Weapon Display") == "Legacy" and 1 or 0.275
	local v2 = self.ClientItem:IsMainItem() and 1 or 0.5
	local v3 = self.AmmoIcon.Visible and 1 or 0.5
	self.Frame.Size = UDim2.new(v * v2, 0, v * v2 * v3, 0)
end

function EquippedDisplay:_UpdateLayouts()
	self.AmmoFrame.Size = UDim2.new(0, self.AmmoText.TextBounds.X, 1, 0)
	self.AmmoReserveFrame.Size = UDim2.new(0, self.AmmoReserveText.TextBounds.X, 1, 0)
end

function EquippedDisplay:_Setup()
	self.WeaponIcon.Image = self.ClientItem.ViewModel:GetImage()
	self.AmmoIcon.Image = not self.ClientItem.Info.AmmoType and "" or ItemLibrary.Ammos[self.ClientItem.Info.AmmoType].Image or ""
	self.ItemNameText.Text = self.ClientItem.Name
	self.NameContainer.ClipsDescendants = false
	WeaponStatusHandler:ApplyItemStatusToText(self.ItemNameText, self.ClientItem.Info.Status)
end

function EquippedDisplay:_Init()
	self.AmmoText:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.AmmoReserveText:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateLayouts()
	end)
	table.insert(self._connections, self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:UpdateAmmo()
	end))
	table.insert(self._connections, self.ClientItem:GetDataChangedSignal("AmmoReserve"):Connect(function()
		self:UpdateAmmo()
	end))
	table.insert(self._connections, self.ClientItem.EquippedChanged:Connect(function()
		self:UpdateVisuals()
	end))
	self:_Setup()
	self:_UpdateLayouts()
	self:UpdateAmmo()
	self:UpdateVisuals()
	self:UpdateVisibility()
	self:UpdateParent()
end

return EquippedDisplay