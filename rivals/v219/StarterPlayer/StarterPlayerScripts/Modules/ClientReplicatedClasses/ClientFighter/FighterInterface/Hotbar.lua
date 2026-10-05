local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local HotbarSlot = require(script:WaitForChild("HotbarSlot"))
local Hotbar = {}
Hotbar.__index = Hotbar

function Hotbar.new(fighterInterface)
	local self = setmetatable({}, Hotbar)
	self.Clicked = Signal.new()
	self.FighterInterface = fighterInterface
	self.Frame = self.FighterInterface.BottomRight.Container:WaitForChild("Hotbar")
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.EquippedDisplayFrame = self.Container:WaitForChild("EquippedDisplay")
	self._hotbar_slots = {}
	self:_Init()
	return self
end

function Hotbar:UpdateParent()
	task.defer(pcall, function()
		local v = PlayerDataController:GetSetting("Hotbar Display") == "Bottom Center"
		local v2 = PlayerDataController:GetSetting("Hotbar Display") == "Bottom Left"
		self.EquippedDisplayFrame.LayoutOrder = v2 and 100000000 or -1
		self.Layout.HorizontalAlignment = v and Enum.HorizontalAlignment.Center or v2 and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Right
		self.Frame.Parent = v and self.FighterInterface.BottomCenter.Container or v2 and self.FighterInterface.BottomLeft.Container or self.FighterInterface.BottomRight.Container
	end)
end

function Hotbar:EquipEffect(p2, ...)
	local _hotbar_slot = self._hotbar_slots[p2]

	if _hotbar_slot then
		return _hotbar_slot:EquipEffect(...)
	end
end

function Hotbar:RollEffect(p2, ...)
	local _hotbar_slot = self._hotbar_slots[p2]

	if _hotbar_slot then
		return _hotbar_slot:RollEffect(...)
	end
end

function Hotbar:CooldownEffect(p2, ...)
	local _hotbar_slot = self._hotbar_slots[p2]

	if _hotbar_slot then
		return _hotbar_slot:CooldownEffect(...)
	end
end

function Hotbar:UpdateAmmo(...)
	for _, _hotbar_slot in pairs(self._hotbar_slots) do
		_hotbar_slot:UpdateAmmo(...)
	end
end

function Hotbar:UpdateVisuals(...)
	for _, _hotbar_slot in pairs(self._hotbar_slots) do
		_hotbar_slot:UpdateVisuals(...)
	end
end

function Hotbar:UpdateVisibility(...)
	self.EquippedDisplayFrame.Visible = PlayerDataController:GetSetting("Equipped Weapon Display") == "Legacy"
	local visible = self.EquippedDisplayFrame.Visible

	for _, _hotbar_slot in pairs(self._hotbar_slots) do
		_hotbar_slot:UpdateVisibility(...)
		visible = visible or _hotbar_slot.Frame.Visible
	end

	self.Frame.Visible = visible and PlayerDataController:GetSetting("Hotbar Display") ~= "Disabled"
end

function Hotbar:ItemRemoved(p, p2)
	local _hotbar_slot = self._hotbar_slots[p]

	if not _hotbar_slot then
		return
	end

	_hotbar_slot:Destroy()
	self._hotbar_slots[p] = nil
	self:_UpdateSize()
	self:UpdateVisibility()

	if not p2 then
		self:UpdateLayouts()
	end
end

function Hotbar:ItemAdded(p, p2)
	self:ItemRemoved(p, p2)
	local v = HotbarSlot.new(self, p)
	v.Frame.Parent = self.Container
	self._hotbar_slots[p] = v
	v.Clicked:Connect(function(...)
		self.Clicked:Fire(v, ...)
	end)
	v.CooldownsChanged:Connect(function()
		self:_UpdateSize()
	end)
	self:_UpdateSize()
	self:UpdateVisibility()

	if not p2 then
		self:UpdateLayouts()
	end
end

function Hotbar:UpdateLayouts()
	for k, item in pairs(self.FighterInterface.ClientFighter.Items) do
		local _hotbar_slot = self._hotbar_slots[item]

		if _hotbar_slot then
			_hotbar_slot.Frame.LayoutOrder = k
		end
	end
end

function Hotbar:Update(p2, p3)
	for _, _hotbar_slot in pairs(self._hotbar_slots) do
		_hotbar_slot:Update(p2, p3)
	end
end

function Hotbar:Destroy()
	self.Clicked:Destroy()

	for _, _hotbar_slot in pairs(self._hotbar_slots) do
		_hotbar_slot:Destroy()
	end
end

function Hotbar:_UpdateSize()
	local v = 0

	for _, _hotbar_slot in pairs(self._hotbar_slots) do
		v = math.max(v, _hotbar_slot:GetNumCooldownsActive())
	end

	self.Frame.Size = UDim2.new(0.275, 0, v * 0.05 + 0.275, 0)
end

function Hotbar:_Init()
	for _, item in pairs(self.FighterInterface.ClientFighter.Items) do
		self:ItemAdded(item, true)
	end

	self:_UpdateSize()
	self:UpdateLayouts()
	self:UpdateParent()
	self:UpdateVisibility()
end

return Hotbar