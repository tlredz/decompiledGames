local EquippedDisplay = require(script:WaitForChild("EquippedDisplay"))
local EquippedDisplays = {}
EquippedDisplays.__index = EquippedDisplays

function EquippedDisplays.new(fighterInterface)
	local self = setmetatable({}, EquippedDisplays)
	self.FighterInterface = fighterInterface
	self._equipped_displays = {}
	self:_Init()
	return self
end

function EquippedDisplays:UpdateVisibility(...)
	for _, _equipped_display in pairs(self._equipped_displays) do
		_equipped_display:UpdateVisibility(...)
	end
end

function EquippedDisplays:UpdateAmmo(...)
	for _, _equipped_display in pairs(self._equipped_displays) do
		_equipped_display:UpdateAmmo(...)
	end
end

function EquippedDisplays:UpdateVisuals(...)
	for _, _equipped_display in pairs(self._equipped_displays) do
		_equipped_display:UpdateVisuals(...)
	end
end

function EquippedDisplays:UpdateParents(...)
	for _, _equipped_display in pairs(self._equipped_displays) do
		_equipped_display:UpdateParent(...)
	end
end

function EquippedDisplays:ItemRemoved(p2, _)
	local _equipped_display = self._equipped_displays[p2]

	if not _equipped_display then
		return
	end

	_equipped_display:Destroy()
	self._equipped_displays[p2] = nil
end

function EquippedDisplays:ItemAdded(p, p2)
	self:ItemRemoved(p, p2)
	local v = EquippedDisplay.new(self, p)
	self._equipped_displays[p] = v
end

function EquippedDisplays:Update(p2, p3)
	for _, _equipped_display in pairs(self._equipped_displays) do
		_equipped_display:Update(p2, p3)
	end
end

function EquippedDisplays:Destroy()
	for _, _equipped_display in pairs(self._equipped_displays) do
		_equipped_display:Destroy()
	end

	self._equipped_displays = {}
end

function EquippedDisplays:_Init()
	for _, item in pairs(self.FighterInterface.ClientFighter.Items) do
		self:ItemAdded(item, true)
	end

	self:UpdateParents()
end

return EquippedDisplays