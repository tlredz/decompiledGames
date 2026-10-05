local Players = game:GetService("Players")
local Charm = require(Players.LocalPlayer.PlayerScripts.Modules.Charm)
local object = setmetatable({}, Charm)
object.__index = object

function object.new(...)
	local self = setmetatable(Charm.new(...), object)
	self._spin_anchor = self.Model:WaitForChild("Extra"):WaitForChild("SpinAnchor")
	self._spin_objects = {}
	self:_Init()
	return self
end

function object:Update(p2)
	Charm.Update(self, p2)
	local cframe = CFrame.Angles(0, tick() * 3.141592653589793 * 2 % 6.283185307179586, 0)

	for k, _spin_object in pairs(self._spin_objects) do
		k.CFrame = self._spin_anchor.CFrame * cframe * _spin_object
	end
end

function object:_Setup()
	for i = 1, 3 do
		local child = self.Model:WaitForChild("Extra"):WaitForChild("Spin" .. i)
		self._spin_objects[child] = child.CFrame:ToObjectSpace(self._spin_anchor.CFrame):Inverse()
	end
end

function object:_Init()
	self:_Setup()
end

return object