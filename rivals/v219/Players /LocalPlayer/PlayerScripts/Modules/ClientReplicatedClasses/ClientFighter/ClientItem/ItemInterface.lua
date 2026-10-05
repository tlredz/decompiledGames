local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local SettingsLibrary = require(ReplicatedStorage.Modules.SettingsLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local SpeedLines = require(script:WaitForChild("SpeedLines"))
local Mouse = require(script:WaitForChild("Mouse"))
local Other = require(script:WaitForChild("Other"))
local itemInterface = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ItemInterface")
local ItemInterface = {}
ItemInterface.__index = ItemInterface

function ItemInterface.new(clientItem)
	local self = setmetatable({}, ItemInterface)
	self.ActiveChanged = Signal.new()
	self.ClientItem = clientItem
	self.Frame = itemInterface:Clone()
	self.SpeedLines = SpeedLines.new(self)
	self.Mouse = Mouse.new(self)
	self.Other = Other.new(self)
	self._destroyed = false
	self._connections = {}
	self._fighter_interface_connections = {}
	self._is_equipped = false
	self._original_sizings = {}
	self._current_duel_subject = nil
	self._current_duel_subject_connections = {}
	self:_Init()
	return self
end

function ItemInterface.SetScopeActive(p, ...)
	return p.Mouse.Scope:SetActive(...)
end

function ItemInterface.IsScopeActive(p, ...)
	return p.Mouse.Scope:IsActive(...)
end

function ItemInterface.PlaySpeedLines(p, ...)
	return p.SpeedLines:Create(...)
end

function ItemInterface:DamageEffect(...)
	return self.Mouse.MouseCrosshair:DamageEffect(...)
end

function ItemInterface:IsActive()
	return self.ClientItem.ClientFighter.FighterInterface and self.ClientItem.ClientFighter.FighterInterface:IsActive()
end

function ItemInterface:CreateSound(...)
	if self:IsActive() then
		return Utility:CreateSound(...)
	end
end

function ItemInterface:Equip()
	self._is_equipped = true
end

function ItemInterface:Unequip()
	self._is_equipped = false
	self.Mouse.Scope:SetActive(false)
end

function ItemInterface:Update(p, p2, p3)
	if not p2.IsSpectating or p2.IsHiddenByCutscene or not p3.IsActive then
		self.Frame.Visible = false
		return
	end

	self.Other:Update(p, p2, p3)
	self.Mouse:Update(p, p2, p3)
	self.SpeedLines:Update(p, p2, p3)
	self.Frame.Visible = true
end

function ItemInterface:Destroy()
	self._destroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	for _, _fighter_interface_connection in pairs(self._fighter_interface_connections) do
		_fighter_interface_connection:Disconnect()
	end

	self._connections = {}
	self._fighter_interface_connections = {}
	self:_UpdateCurrentDuelSubject()
	self.ActiveChanged:Destroy()
	self.SpeedLines:Destroy()
	self.Mouse:Destroy()
	self.Other:Destroy()
	self.Frame:Destroy()
end

function ItemInterface:_UpdateSizing()
	local v = UILibrary.MainGui.AbsoluteSize.X / self.Frame.AbsoluteSize.X
	local v2 = UILibrary.MainGui.AbsoluteSize.Y / self.Frame.AbsoluteSize.Y

	for _, v3 in pairs({ "AimingVignette", "SpeedLinesThick", "SpeedLinesThin" }) do
		local v4 = self.Frame[v3]
		self._original_sizings[v4] = self._original_sizings[v4] or {
			Position = v4.Position,
			Size = v4.Size
		}
		v4.Size = UDim2.new(
			self._original_sizings[v4].Size.X.Scale * v,
			self._original_sizings[v4].Size.X.Offset * v,
			self._original_sizings[v4].Size.Y.Scale * v2,
			self._original_sizings[v4].Size.Y.Offset * v2
		)
		v4.Position = UDim2.new(
			0.5 + (self._original_sizings[v4].Position.X.Scale - 0.5) * v,
			0,
			0.5 + (self._original_sizings[v4].Position.Y.Scale - 0.5) * v2,
			0
		)
	end
end

function ItemInterface:_UpdateVisibility()
	local v = not (Pages.PageSystem.CurrentPage or GuiService.MenuIsOpen or SpectateController:IsSubjectEmoting() or self._current_duel_subject and self._current_duel_subject.DuelInterface and self._current_duel_subject.DuelInterface.Scoreboard:IsOpen())
	self.Mouse:SetVisible(v)
end

function ItemInterface:_UpdateCurrentDuelSubject()
	for _, _current_duel_subject_connection in pairs(self._current_duel_subject_connections) do
		_current_duel_subject_connection:Disconnect()
	end

	self._current_duel_subject_connections = {}

	if self._destroyed then
		return
	end

	self._current_duel_subject = SpectateController.CurrentDuelSubject
	self:_UpdateVisibility()

	if not self._current_duel_subject then
		return
	end

	table.insert(
		self._current_duel_subject_connections,
		self._current_duel_subject.DuelInterface.Scoreboard.VisibilityChanged:Connect(function()
			self:_UpdateVisibility()
		end)
	)
end

function ItemInterface:_FighterInterfaceRemoved()
	for _, _fighter_interface_connection in pairs(self._fighter_interface_connections) do
		_fighter_interface_connection:Disconnect()
	end

	self._fighter_interface_connections = {}
end

function ItemInterface:_FighterInterfaceAdded(p)
	self:_FighterInterfaceRemoved()
	table.insert(self._fighter_interface_connections, p.ActiveChanged:Connect(function()
		self.ActiveChanged:Fire()
	end))
	self.ActiveChanged:Fire()
end

function ItemInterface:_Setup()
	self.Frame.Visible = false
	self.Frame.Name = self.ClientItem.ClientFighter.Player.Name .. " - " .. self.ClientItem.Name
	self.Frame.Parent = UILibrary:GetTo("MainFrame", "ItemInterfaces")
end

function ItemInterface:_Init()
	self.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateSizing()
	end)
	table.insert(self._connections, self.ClientItem.ClientFighter.InterfaceAdded:Connect(function(p)
		self:_FighterInterfaceAdded(p)
	end))
	table.insert(self._connections, self.ClientItem.ClientFighter.InterfaceRemoved:Connect(function()
		self:_FighterInterfaceRemoved()
	end))
	table.insert(self._connections, UserInputService:GetPropertyChangedSignal("MouseIconEnabled"):Connect(function()
		self.Mouse:Refresh()
	end))
	table.insert(self._connections, UserInputService:GetPropertyChangedSignal("MouseBehavior"):Connect(function()
		self.Mouse:Refresh()
	end))
	table.insert(self._connections, CameraController.POVStateChanged:Connect(function()
		self.Mouse:Refresh()
	end))
	table.insert(self._connections, Pages.PageSystem.PagesActivity:Connect(function()
		self:_UpdateVisibility()
	end))
	table.insert(self._connections, GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_UpdateVisibility()
	end))
	table.insert(self._connections, SpectateController.DuelSubjectChanged:Connect(function()
		self:_UpdateCurrentDuelSubject()
	end))
	table.insert(self._connections, SpectateController.SubjectEmoteStatusChanged:Connect(function()
		self:_UpdateVisibility()
	end))

	if self.ClientItem.ClientFighter.IsLocalPlayer then
		for k, v in pairs(SettingsLibrary.Info) do
			if v.Section == "Crosshair" then
				table.insert(self._connections, PlayerDataController:GetSettingChangedSignal(k):Connect(function()
					self.Mouse.MouseCrosshair:Refresh()
				end))
			end
		end
	else
		table.insert(
			self._connections,
			self.ClientItem.ClientFighter:GetDataChangedSignal("CompressedCrosshairAppearance"):Connect(function()
				self.Mouse.MouseCrosshair:Refresh()
			end)
		)
	end

	if self.ClientItem.ClientFighter.FighterInterface then
		task.defer(self._FighterInterfaceAdded, self, self.ClientItem.ClientFighter.FighterInterface)
	end

	self:_Setup()
	self:_UpdateSizing()
	self:_UpdateVisibility()
	self.Mouse.MouseCrosshair:Refresh()
	self.Mouse:Refresh()
	self:Unequip()
	task.defer(self._UpdateCurrentDuelSubject, self)
end

return ItemInterface