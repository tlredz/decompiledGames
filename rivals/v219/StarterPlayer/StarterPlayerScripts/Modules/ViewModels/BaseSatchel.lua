local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ChainsawParticles")
local v = { 1, 0.1 }
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._beep_parts = {}
	self._beep_visible = false
	self._toggle_index = 0
	self._next_toggle = 0
	self:_Init()
	return self
end

function object:Update(p, p2, p3)
	ClientViewModel.Update(self, p, p2, p3)

	if not p3.IsActive or tick() < self._next_toggle then
		return
	end

	self._toggle_index = self._toggle_index % #v + 1
	self._next_toggle = tick() + v[self._toggle_index]
	self._beep_visible = not self._beep_visible

	for k, _ in pairs(self._beep_parts) do
		self:_LocalTransparencyModifier(k, "Update", self._beep_visible and 0 or 1)
	end
end

function object._PlayBeepAnimation(_, instance)
	while instance:IsDescendantOf(workspace) do
		wait(1)
		instance.LocalTransparencyModifier = 1
		wait(0.1)
		instance.LocalTransparencyModifier = 0
	end
end

function object:_RegisterBeepPart(p2)
	self._beep_parts[p2] = true
end

function object:_Init()
	task.defer(function()
		self.ClientItem.ProjectileThrown:Connect(function(p2, _)
			wait(0.5)
			local createSound = Utility:CreateSound(
				"rbxassetid://104924027407060",
				0.05,
				1 + 0.1 * math.random(),
				p2,
				true
			)
			createSound.Looped = true
		end)
	end)
end

return object