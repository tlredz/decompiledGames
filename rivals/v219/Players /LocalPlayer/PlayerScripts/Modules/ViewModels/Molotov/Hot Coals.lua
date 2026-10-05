local Players = game:GetService("Players")
local Molotov = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Molotov)
local object = setmetatable({}, Molotov)
object.__index = object

function object.new(...)
	local self = setmetatable(Molotov.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	self.Animator.AnimationStopped:Connect(function(p2)
		local equipAnimationKey = self.Animator:GetEquipAnimationKey()
		local idleAnimationKey = self.Animator:GetIdleAnimationKey()

		if p2 ~= equipAnimationKey then
			return
		end

		local animationTrack = self.Animator:GetAnimationTrack(equipAnimationKey)

		if animationTrack then
			animationTrack:Stop(0)
		end

		local animationTrack2 = self.Animator:GetAnimationTrack(idleAnimationKey)

		if animationTrack2 then
			animationTrack2:Stop(0)
			animationTrack2:Play(0)
		end
	end)
end

return object