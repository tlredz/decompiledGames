local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local Spring = require(ReplicatedStorage.Modules.Spring)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local InfiniteParticles = require(Players.LocalPlayer.PlayerScripts.Modules.InfiniteParticles)
local hotbarCooldownSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("HotbarCooldownSlot")
local hotbarSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("HotbarSlot")
local v = {
	"EquipPrimary",
	"EquipSecondary",
	"EquipMelee",
	"EquipUtility"
}
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(127, 0, 0)
local HotbarSlot = {}
HotbarSlot.__index = HotbarSlot

function HotbarSlot.new(hotbar, clientItem)
	local self = setmetatable({}, HotbarSlot)
	self.Clicked = Signal.new()
	self.CooldownsChanged = Signal.new()
	self.Hotbar = hotbar
	self.ClientItem = clientItem
	self.Frame = hotbarSlot:Clone()
	self.Background = self.Frame:WaitForChild("Background")
	self.Button = self.Frame:WaitForChild("Button")
	self.Icon = self.Frame:WaitForChild("Icon")
	self.CooldownsFrame = self.Frame:WaitForChild("Cooldowns")
	self.MouseKeyboardInputKeybind = self.Frame:WaitForChild("Inputs"):WaitForChild("MouseKeyboard"):WaitForChild("Keybind")
	self.AmmoFrame = self.Frame:WaitForChild("Ammo")
	self.AmmoTitle = self.AmmoFrame:WaitForChild("Title")
	self.AmmoIcon = self.AmmoFrame:WaitForChild("Icon")
	self._connections = {}
	self._item_slot_rotation_spring = Spring.new(0, 1, 20)
	self._item_slot_position_spring = Spring.new(0, 0.75, 20)
	self._item_slot_color_spring = Spring.new(0, 1, 10)
	self._infinite_particles = InfiniteParticles.new(self.AmmoTitle)
	self._num_cooldowns_active = 0
	self:_Init()
	return self
end

function HotbarSlot:GetNumCooldownsActive()
	return self._num_cooldowns_active
end

function HotbarSlot:EquipEffect()
	self._item_slot_position_spring.Velocity = -10
end

function HotbarSlot:RollEffect()
	self._item_slot_position_spring.Velocity = -40
	self._item_slot_rotation_spring.Target += 360
end

function HotbarSlot:UpdateAmmo()
	local ammoVariables, v2, v3, v4 = self.ClientItem:GetAmmoVariables()
	local setting = PlayerDataController:GetSetting("Hotbar Slot Ammo")
	local color3 = ammoVariables and ammoVariables <= 0 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
	local v5 = ammoVariables and ammoVariables <= 0 and "rgb(255,50,50)" or "rgb(255,255,255)"
	local v6 = v4 and "∞" or v2 or ""
	local color4 = v2 and v2 <= 0 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
	local v7 = v2 and v2 <= 0 and "rgb(255,50,50)" or "rgb(255,255,255)"
	self.AmmoFrame.Visible = ammoVariables and setting
	self.AmmoTitle.Text = string.format("<font color=\"%s\">%s</font>", v5, v3 and "∞" or ammoVariables or "") .. (v6 == "" and "" or string.format(
		"<font size=\"8\" color=\"%s\"> %s</font>",
		v7,
		v6
	))
	local ammoIcon = self.AmmoIcon

	if v2 then
		color3 = color4 or color3
	end

	ammoIcon.ImageColor3 = color3
	self._infinite_particles:SetActive(v3, v4)
end

function HotbarSlot:UpdateVisuals()
	local isMainItem = self.ClientItem:IsMainItem()
	local itemIndex = self.ClientItem:Get("ItemIndex")
	local v2 = self.ClientItem.ClientFighter.IsLocalPlayer and v[itemIndex]
	self.Frame.ZIndex = isMainItem and 999 or itemIndex
	self.Frame.LayoutOrder = itemIndex
	self.Frame.Size = isMainItem and UDim2.new(1, 0, 1, 0) or UDim2.new(0.75, 0, 0.75, 0)
	local background = self.Background
	local image

	if itemIndex % 2 == 0 then
		image = isMainItem and "rbxassetid://13220167337" or "rbxassetid://13188242287"
	else
		image = isMainItem and "rbxassetid://13220167472" or "rbxassetid://13188242420"
	end

	background.Image = image
	self.Background.ImageTransparency = isMainItem and 0 or 0.7
	self.MouseKeyboardInputKeybind.Visible = false
	self.MouseKeyboardInputKeybind:SetAttribute("InputName", v2)
end

function HotbarSlot:UpdateVisibility()
	self.Frame.Visible = ControlsController.CurrentControls ~= "Touch" or not self.Hotbar.FighterInterface.ClientFighter.IsLocalPlayer
end

function HotbarSlot:Update(p, _)
	self.Icon.Rotation = self._item_slot_rotation_spring.Value
	self.Icon.Position = UDim2.new(0.5, 0, 0.5 + self._item_slot_position_spring.Value, 0)
	self.Icon.ImageColor3 = color:Lerp(color2, 1 - (1 - self._item_slot_color_spring.Value) ^ 2)
	self._infinite_particles:Update(p)
end

function HotbarSlot:Destroy()
	self._infinite_particles:Destroy()

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self.CooldownsChanged:Destroy()
	self.Clicked:Destroy()
	self.Frame:Destroy()
end

function HotbarSlot:_EquipFailedEffect()
	self._item_slot_position_spring.Value = 0.25
	self._item_slot_color_spring.Value = 1
	self.Hotbar.FighterInterface:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
end

function HotbarSlot:_CooldownEffect(data)
	if data.IsReversed then
		return
	end

	local variables, v2, v3 = data.GetVariables()
	local clone = hotbarCooldownSlot:Clone()
	clone.Icon.Image = data.Image
	clone.Bar.Bar.Size = UDim2.new(v2, 0, 1.5, 0)
	clone.Parent = self.CooldownsFrame
	table.insert(data.Cleanup, clone)
	BetterDebris:AddItem(clone, variables)
	TweenService:Create(clone.Bar.Bar, TweenInfo.new(variables, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
		Size = UDim2.new(v3, 0, 1.5, 0)
	}):Play()
	self._num_cooldowns_active += 1
	self.CooldownsChanged:Fire()
	task.delay(variables, function()
		self._num_cooldowns_active -= 1
		self.CooldownsChanged:Fire()
	end)
end

function HotbarSlot:_Setup()
	self.Frame.Name = self.ClientItem.Name
	self.Icon.Image = self.ClientItem.ViewModel:GetImage()
	self.AmmoIcon.Image = self.ClientItem.Info.AmmoType and ItemLibrary.Ammos[self.ClientItem.Info.AmmoType].Image or ""
end

function HotbarSlot:_Init()
	self.Button.MouseButton1Click:Connect(function()
		self.Clicked:Fire()
	end)
	table.insert(self._connections, self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:UpdateAmmo()
	end))
	table.insert(self._connections, self.ClientItem:GetDataChangedSignal("AmmoReserve"):Connect(function()
		self:UpdateAmmo()
	end))
	table.insert(self._connections, self.ClientItem:GetDataChangedSignal("ItemIndex"):Connect(function()
		self:UpdateVisuals()
	end))
	table.insert(self._connections, self.ClientItem.EquipFailedEffect:Connect(function(_)
		self:_EquipFailedEffect()
	end))
	table.insert(self._connections, self.ClientItem.Cooldowns.CooldownAdded:Connect(function(p)
		self:_CooldownEffect(p)
	end))

	for _, cooldown in pairs(self.ClientItem.Cooldowns.Cooldowns) do
		task.spawn(self._CooldownEffect, self, cooldown)
	end

	self:_Setup()
	self:UpdateVisuals()
	self:UpdateVisibility()
	self:UpdateAmmo()
end

return HotbarSlot