local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.ItemLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local fighterKeybindSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("FighterKeybindSlot")
local v = {
	{ "QuickUtility", "Quick Utility" },
	{ "QuickMelee", "Quick Melee" },
	{ "OpenPlayerList", "Scoreboard" },
	{ "SwitchCameraPOV", "Camera" },
	{ "UseEmote", "Emote" },
	{ "LeaveDuel", "Leave Shooting Range" }
}
local Keybinds = {}
Keybinds.__index = Keybinds

function Keybinds.new(fighterInterface)
	local self = setmetatable({}, Keybinds)
	self.FighterInterface = fighterInterface
	self.KeybindGamepadEquipLastFrame = self.FighterInterface.Hotbar.Container:WaitForChild("KeybindGamepadEquipLast")
	self.KeybindGamepadEquipNextFrame = self.FighterInterface.Hotbar.Container:WaitForChild("KeybindGamepadEquipNext")
	self.Frame = self.FighterInterface.BottomRight.Container:WaitForChild("Keybinds")
	self.Layout = self.Frame:WaitForChild("Layout")
	self._destroyed = false
	self._connections = {}
	self._slots = {}
	self:_Init()
	return self
end

function Keybinds:Refresh()
	if self._destroyed then
		return
	end

	local EmoteController = require(Players.LocalPlayer.PlayerScripts.Controllers.EmoteController)
	local frame = self.Frame
	frame.Visible = PlayerDataController:GetSetting("Keybinds Interface") ~= "Disabled" and #self.FighterInterface.ClientFighter.Items > 0 and (ControlsController.CurrentControls == "MouseKeyboard" or ControlsController.CurrentControls == "Gamepad")
	self._slots.QuickUtility.Visible = self:_IsQuickAttackKeybindVisible("Utility")
	self._slots.QuickMelee.Visible = self:_IsQuickAttackKeybindVisible("Melee")
	self._slots.OpenPlayerList.Visible = self.FighterInterface.ClientFighter:Get("IsInDuel")
	self._slots.SwitchCameraPOV.Visible = CameraController:HasThirdPersonAccess()
	self._slots.UseEmote.Visible = EmoteController:CanEmote()
	self._slots.LeaveDuel.Visible = self.FighterInterface.ClientFighter:Get("IsInShootingRange")
	self:_UpdateGamepad()
	self:_UpdateParent()
end

function Keybinds:Destroy()
	self._destroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self._slots = {}
end

function Keybinds:_UpdateParent()
	task.defer(pcall, function()
		local v2 = PlayerDataController:GetSetting("Keybinds Interface") == "Bottom Left"

		for _, _slot in pairs(self._slots) do
			_slot.Container.AnchorPoint = v2 and Vector2.new(0, 0.5) or Vector2.new(1, 0.5)
			_slot.Container.Position = v2 and UDim2.new(0, 0, 0.5, 0) or UDim2.new(1, 0, 0.5, 0)
			_slot.Container.Title.AnchorPoint = v2 and Vector2.new(0, 0.5) or Vector2.new(1, 0.5)
			_slot.Container.Title.Position = v2 and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0, 0, 0.5, 0)
			_slot.Container.Title.TextXAlignment = v2 and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
		end

		self.Layout.HorizontalAlignment = v2 and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Right
		self.Frame.Parent = v2 and self.FighterInterface.BottomLeft.Container or self.FighterInterface.BottomRight.Container
	end)
end

function Keybinds:_IsQuickAttackKeybindVisible(p2)
	local quickAttackIndex = self.FighterInterface.ClientFighter:GetQuickAttackIndex(p2)
	local isLocalPlayer = self.FighterInterface.ClientFighter.IsLocalPlayer

	if isLocalPlayer then
		if quickAttackIndex <= #self.FighterInterface.ClientFighter.Items then
			isLocalPlayer = self.FighterInterface.ClientFighter.EquippedItem ~= self.FighterInterface.ClientFighter.Items[quickAttackIndex]
		else
			isLocalPlayer = false
		end
	end

	return isLocalPlayer
end

function Keybinds:_UpdateGamepad()
	local visible

	if ControlsController.CurrentControls == "Gamepad" then
		visible = #self.FighterInterface.ClientFighter.Items > 1
	else
		visible = false
	end

	self.KeybindGamepadEquipLastFrame.Visible = visible
	self.KeybindGamepadEquipNextFrame.Visible = visible
end

function Keybinds:_UpdateBackground()
	self.Frame.Size = UDim2.new(0, self.Layout.AbsoluteContentSize.X, 0.0934, 0)
end

function Keybinds:_Setup()
	for k, list in pairs(v) do
		local v2, text = table.unpack(list)
		local clone = fighterKeybindSlot:Clone()
		clone.Container.Keybind:SetAttribute("InputName", v2)
		clone.Container.Title.Text = text
		clone.LayoutOrder = -k
		clone.Parent = self.Frame
		self._slots[v2] = clone
		local title = clone.Container.Title

		local function update()
			clone.Size = UDim2.new(1.3, title.TextBounds.X, 1, 0)
		end

		title:GetPropertyChangedSignal("TextBounds"):Connect(update)
	end
end

function Keybinds:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateBackground()
	end)
	self:_Setup()
	self:_UpdateGamepad()
	self:_UpdateBackground()
end

return Keybinds