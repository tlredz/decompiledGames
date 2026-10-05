local Players = game:GetService("Players")
local Grappler = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Grappler)
local object = setmetatable({}, Grappler)
object.__index = object

function object.new(...)
	local self = setmetatable(Grappler.new(...), object)
	self._rope_constraint = self.ItemModel:WaitForChild("Rope 2"):WaitForChild("Part3"):WaitForChild("Attachment"):WaitForChild("RopeConstraint")
	self._hook_submodel_hidden_until = 0
	self:_Init()
	return self
end

function object:HideHookSubModel(duration)
	self:HideSubModel("Rope 2", duration)
	self._hook_submodel_hidden_until = tick() + duration
	self:_UpdateRopeEnabled()
	task.delay(duration, self._UpdateRopeEnabled, self)
end

function object.PlayShootSounds(object2)
	object2:CreateSound("rbxassetid://125047201358688", 1.25, 0.9 + 0.2 * math.random(), true, 5)
end

function object.PlayPullSounds(object2)
	object2:CreateSound("rbxassetid://125047201358688", 1.25, 1.4 + 0.2 * math.random(), true, 5)
end

function object:_UpdateRopeEnabled()
	local _rope_constraint = self._rope_constraint
	_rope_constraint.Visible = tick() > self._hook_submodel_hidden_until and not (self.Animator:IsAnimationPlaying("Shoot") or self.Animator:IsAnimationPlaying("ShootWaiting"))
end

function object:_Init()
	self.AnimationPlayed:Connect(function()
		self:_UpdateRopeEnabled()
	end)
	self.AnimationStopped:Connect(function()
		self:_UpdateRopeEnabled()
	end)
	self:_UpdateRopeEnabled()
end

return object