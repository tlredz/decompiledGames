local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local EmoteController = require(Players.LocalPlayer.PlayerScripts.Controllers.EmoteController)
local OutOfBoundsParts = require(Players.LocalPlayer.PlayerScripts.Modules.GameComponents.OutOfBoundsParts)
local EliminatedEffect = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.EliminatedEffect)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local AudioVisualizers = require(script:WaitForChild("AudioVisualizers"))
local DamageIndicators = require(script:WaitForChild("DamageIndicators"))
local EliminationSlots = require(script:WaitForChild("EliminationSlots"))
local EquippedDisplays = require(script:WaitForChild("EquippedDisplays"))
local WarningEffect = require(script:WaitForChild("WarningEffect"))
local BottomCenter = require(script:WaitForChild("BottomCenter"))
local SmokeScreen = require(script:WaitForChild("SmokeScreen"))
local BottomRight = require(script:WaitForChild("BottomRight"))
local BottomLeft = require(script:WaitForChild("BottomLeft"))
local SpeedLines = require(script:WaitForChild("SpeedLines"))
local Spectators = require(script:WaitForChild("Spectators"))
local Keybinds = require(script:WaitForChild("Keybinds"))
local Flashed = require(script:WaitForChild("Flashed"))
local Frozen = require(script:WaitForChild("Frozen"))
local Splats = require(script:WaitForChild("Splats"))
local Health = require(script:WaitForChild("Health"))
local Hotbar = require(script:WaitForChild("Hotbar"))
local Other = require(script:WaitForChild("Other"))
local ESP = require(script:WaitForChild("ESP"))
local fighterInterface = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("FighterInterface")
local FighterInterface = {}
FighterInterface.__index = FighterInterface

function FighterInterface.new(clientFighter)
	local self = setmetatable({}, FighterInterface)
	self.ActiveChanged = Signal.new()
	self.HotbarClicked = Signal.new()
	self.ClientFighter = clientFighter
	self.Frame = fighterInterface:Clone()
	self.AudioVisualizers = AudioVisualizers.new(self)
	self.DamageIndicators = DamageIndicators.new(self)
	self.EliminationSlots = EliminationSlots.new(self)
	self.EquippedDisplays = EquippedDisplays.new(self)
	self.WarningEffect = WarningEffect.new(self)
	self.BottomCenter = BottomCenter.new(self)
	self.BottomRight = BottomRight.new(self)
	self.SmokeScreen = SmokeScreen.new(self)
	self.BottomLeft = BottomLeft.new(self)
	self.Spectators = Spectators.new(self)
	self.SpeedLines = SpeedLines.new(self)
	self.Flashed = Flashed.new(self)
	self.Frozen = Frozen.new(self)
	self.Splats = Splats.new(self)
	self.Health = Health.new(self)
	self.Hotbar = Hotbar.new(self)
	self.Keybinds = Keybinds.new(self)
	self.Other = Other.new(self)
	self.ESP = ESP.new(self)
	self._destroyed = false
	self._connections = {}
	self._original_sizings = {}
	self:_Init()
	return self
end

function FighterInterface:RefillAmmoEffect(...)
	return self.Other:RefillAmmoEffect(...)
end

function FighterInterface:HealEffect(...)
	return self.Health:HealEffect(...)
end

function FighterInterface:HurtEffect(...)
	return self.Health:HurtEffect(...)
end

function FighterInterface.DamageIndicator(p, ...)
	return p.DamageIndicators:Create(...)
end

function FighterInterface.ClearDamageIndicators(p, ...)
	return p.DamageIndicators:Clear(...)
end

function FighterInterface.SplatEffect(p, ...)
	return p.Splats:Create(...)
end

function FighterInterface.EliminationEffect(p, ...)
	return p.EliminationSlots:Create(...)
end

function FighterInterface.HotbarRollEffect(p, ...)
	return p.Hotbar:RollEffect(...)
end

function FighterInterface:IsActive()
	return self.Frame.Visible
end

function FighterInterface:CreateSound(...)
	if self:IsActive() then
		return Utility:CreateSound(...)
	end
end

function FighterInterface:Update(p, p2)
	if p2.IsSpectating then
		self.AudioVisualizers:Update(p, p2)
		self.DamageIndicators:Update(p, p2)
		self.EquippedDisplays:Update(p, p2)
		self.SmokeScreen:Update(p, p2)
		self.SpeedLines:Update(p, p2)
		self.Hotbar:Update(p, p2)
		self.ESP:Update(p, p2)
		self:_SetFrameVisible(true)
	else
		self.SmokeScreen:Hide()
		self:_SetFrameVisible(false)
	end
end

function FighterInterface:Destroy()
	self._destroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self.ActiveChanged:Destroy()
	self.HotbarClicked:Destroy()
	self.AudioVisualizers:Destroy()
	self.DamageIndicators:Destroy()
	self.EliminationSlots:Destroy()
	self.EquippedDisplays:Destroy()
	self.WarningEffect:Destroy()
	self.BottomCenter:Destroy()
	self.SmokeScreen:Destroy()
	self.BottomRight:Destroy()
	self.BottomLeft:Destroy()
	self.SpeedLines:Destroy()
	self.Spectators:Destroy()
	self.Keybinds:Destroy()
	self.Flashed:Destroy()
	self.Frozen:Destroy()
	self.Splats:Destroy()
	self.Health:Destroy()
	self.Hotbar:Destroy()
	self.Other:Destroy()
	self.ESP:Destroy()
	self.Frame:Destroy()
end

function FighterInterface:_UpdateSizing()
	local v = UILibrary.MainGui.AbsoluteSize.X / self.Frame.AbsoluteSize.X
	local v2 = UILibrary.MainGui.AbsoluteSize.Y / self.Frame.AbsoluteSize.Y

	for _, v3 in pairs({
		"ESP",
		"DamageVignette",
		"FrozenVignette",
		"HealVignette",
		"WarningVignette",
		"SpeedLinesThick",
		"SpeedLinesThin",
		"RefillAmmoVignette"
	}) do
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

function FighterInterface:_UpdateVisibility()
	local v = not Pages.PageSystem.CurrentPage
	local isVisible = EliminatedEffect:IsVisible()
	self.EliminationSlots:SetVisible(v and not isVisible)
	local bottomCenter = self.BottomCenter
	local v2

	if v then
		if #self.ClientFighter.Items > 0 then
			v2 = not isVisible
		else
			v2 = false
		end
	else
		v2 = v
	end

	bottomCenter:SetVisible(v2)
	local bottomRight = self.BottomRight
	local v3

	if v then
		if #self.ClientFighter.Items > 0 then
			v3 = not isVisible
		else
			v3 = false
		end
	else
		v3 = v
	end

	bottomRight:SetVisible(v3)
	self.BottomLeft:SetVisible(v and #self.ClientFighter.Items > 0)
end

function FighterInterface:_SetFrameVisible(visible)
	if self.Frame.Visible == visible then
		return
	end

	self.Frame.Visible = visible
	self.ActiveChanged:Fire()
end

function FighterInterface:_EntityRemoved()
	self.Frozen:Refresh()
end

function FighterInterface:_EntityAdded()
	self.EliminationSlots:Clear()
	self.DamageIndicators:Clear()
	self.SmokeScreen:Clear()

	if self.ClientFighter.Entity then
		table.insert(self._connections, self.ClientFighter.Entity.HealthChanged:Connect(function()
			self.Health:Refresh()
		end))
		table.insert(self._connections, self.ClientFighter.Entity:GetDataChangedSignal("IsFrozen"):Connect(function()
			self.Frozen:Refresh()
		end))
		table.insert(self._connections, self.ClientFighter.Entity.Died:Connect(function()
			self.Frozen:Refresh()
			self.Keybinds:Refresh()
		end))
		self.Health:Refresh()
		self.Frozen:Refresh()
		self.Keybinds:Refresh()
	else
		self.Health:Refresh()
		self.Frozen:Refresh()
	end
end

function FighterInterface:_Setup()
	self:_SetFrameVisible(false)
	self.Frame.Name = self.ClientFighter.Player.Name
	self.Frame.Parent = UILibrary:GetTo("MainFrame", "FighterInterfaces")
end

function FighterInterface:_Init()
	self.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateSizing()
	end)
	self.Hotbar.Clicked:Connect(function(...)
		self.HotbarClicked:Fire(...)
	end)
	table.insert(self._connections, self.ClientFighter.EntityAdded:Connect(function()
		self:_EntityAdded()
	end))
	table.insert(self._connections, self.ClientFighter.EntityRemoved:Connect(function()
		self:_EntityRemoved()
	end))
	table.insert(self._connections, self.ClientFighter.EquippedItemChanged:Connect(function()
		self.Keybinds:Refresh()
		self.Hotbar:UpdateVisuals()
		self.Hotbar:EquipEffect(self.ClientFighter.EquippedItem)
		self.EquippedDisplays:UpdateVisibility()
		self.EquippedDisplays:UpdateVisuals()
	end))
	table.insert(self._connections, self.ClientFighter.ItemAdded:Connect(function(p)
		self.Keybinds:Refresh()
		self.Hotbar:ItemAdded(p)
		self.EquippedDisplays:ItemAdded(p)
		self:_UpdateVisibility()
	end))
	table.insert(self._connections, self.ClientFighter.ItemRemoved:Connect(function(p)
		self.Keybinds:Refresh()
		self.Hotbar:ItemRemoved(p)
		self.EquippedDisplays:ItemRemoved(p)
		self:_UpdateVisibility()
	end))
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("NumSpectators"):Connect(function()
		self.Spectators:Refresh()
	end))
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self.Keybinds:Refresh()
	end))
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("QuickAttackOverrides"):Connect(function()
		self.Keybinds:Refresh()
	end))
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("CheaterMode"):Connect(function()
		self.ESP:Refresh()
	end))
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("IsAprilFools"):Connect(function()
		self.Health:Refresh()
	end))
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("InfiniteAmmo"):Connect(function()
		self.Hotbar:UpdateAmmo()
		self.EquippedDisplays:UpdateAmmo()
	end))
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("InfiniteAmmoReserve"):Connect(function()
		self.Hotbar:UpdateAmmo()
		self.EquippedDisplays:UpdateAmmo()
	end))
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("EquippedItemID"):Connect(function()
		self.Hotbar:UpdateLayouts()
	end))
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self.Keybinds:Refresh()
	end))
	table.insert(self._connections, CameraController.StateChanged:Connect(function()
		self.Keybinds:Refresh()
	end))
	table.insert(self._connections, ControlsController.ControlsChanged:Connect(function()
		self.Keybinds:Refresh()
		self.Spectators:Refresh()
		self.Hotbar:UpdateVisibility()
	end))
	table.insert(self._connections, EmoteController.CanEmoteChanged:Connect(function()
		self.Keybinds:Refresh()
	end))
	table.insert(self._connections, Pages.PageSystem.PageOpened:Connect(function()
		self:_UpdateVisibility()
	end))
	table.insert(self._connections, Pages.PageSystem.PageClosed:Connect(function()
		self:_UpdateVisibility()
	end))
	table.insert(self._connections, EliminatedEffect.VisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end))
	table.insert(
		self._connections,
		PlayerDataController:GetSettingChangedSignal("Spectators Display"):Connect(function()
			self.Spectators:UpdateParent()
		end)
	)
	table.insert(self._connections, PlayerDataController:GetSettingChangedSignal("Padded HUD"):Connect(function()
		self.Spectators:Refresh()
	end))
	table.insert(
		self._connections,
		PlayerDataController:GetSettingChangedSignal("Health Bar Display"):Connect(function()
			self.Health:UpdateParent()
		end)
	)
	table.insert(
		self._connections,
		PlayerDataController:GetSettingChangedSignal("Keybinds Interface"):Connect(function()
			self.Keybinds:Refresh()
		end)
	)
	table.insert(
		self._connections,
		PlayerDataController:GetSettingChangedSignal("Equipped Weapon Display"):Connect(function()
			self.Hotbar:UpdateAmmo()
			self.Hotbar:UpdateVisibility()
			self.EquippedDisplays:UpdateAmmo()
			self.EquippedDisplays:UpdateVisibility()
			self.EquippedDisplays:UpdateParents()
		end)
	)
	table.insert(self._connections, PlayerDataController:GetSettingChangedSignal("Hotbar Slot Ammo"):Connect(function()
		self.Hotbar:UpdateAmmo()
		self.EquippedDisplays:UpdateAmmo()
	end))
	table.insert(
		self._connections,
		PlayerDataController:GetSettingChangedSignal("Equipped Weapon Icon"):Connect(function()
			self.EquippedDisplays:UpdateParents()
		end)
	)
	table.insert(
		self._connections,
		PlayerDataController:GetSettingChangedSignal("Equipped Weapon Ammo"):Connect(function()
			self.EquippedDisplays:UpdateParents()
		end)
	)
	table.insert(self._connections, PlayerDataController:GetSettingChangedSignal("Hotbar Display"):Connect(function()
		self.Hotbar:UpdateParent()
		self.Hotbar:UpdateVisibility()
		self.EquippedDisplays:UpdateParents()
	end))

	if self.ClientFighter.IsLocalPlayer then
		table.insert(self._connections, OutOfBoundsParts.Warning:Connect(function(p)
			self.WarningEffect:SetEnabled(true, p)
		end))
		table.insert(self._connections, OutOfBoundsParts.SteppedOut:Connect(function()
			self.WarningEffect:SetEnabled(false)
		end))
	end

	self:_Setup()
	self:_UpdateSizing()
	self:_UpdateVisibility()
	self.ESP:Refresh()
	self.Keybinds:Refresh()
	self.Spectators:Refresh()
	self.EliminationSlots:Refresh()
	task.defer(self._EntityAdded, self)
end

return FighterInterface