local Players = game:GetService("Players")
local Gunblade = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Gunblade)
local object = setmetatable({}, Gunblade)
object.__index = object

function object.new(...)
	local self = setmetatable(Gunblade.new(...), object)
	self._spike_toggle = false
	self._next_toggle = 0
	self._spikes1 = self.ItemModel:WaitForChild("Body"):WaitForChild("Spikes1")
	self._spikes2 = self.ItemModel:WaitForChild("Body"):WaitForChild("Spikes2")
	self:_Init()
	return self
end

function object:Update(p, p2, p3)
	Gunblade.Update(self, p, p2, p3)

	if not p3.IsActive or tick() < self._next_toggle then
		return
	end

	self._next_toggle = tick() + 0.03
	self._spike_toggle = not self._spike_toggle
	self:_LocalTransparencyModifier(self._spikes1, "Update", self._spike_toggle and 0 or 1)
	self:_LocalTransparencyModifier(self._spikes2, "Update", self._spike_toggle and 1 or 0)
end

function object:_PlayIdleSound()
	local sound = self:CreateSound("rbxassetid://13645858587", 0.375, 1, true, nil, 10, 40)

	if sound then
		sound.Looped = true
	end

	local sound2 = self:CreateSound("rbxassetid://13646484249", 0.375, 1, true, nil, 10, 40)

	if sound2 then
		sound2.Looped = true
	end

	local sound3 = self:CreateSound("rbxassetid://13646484113", 0.25, 1, true, nil, 10, 40)

	if sound3 then
		sound3.Looped = true
	end
end

function object:_Init()
	self.Equipped:Connect(function()
		self:_PlayIdleSound()
	end)
end

return object