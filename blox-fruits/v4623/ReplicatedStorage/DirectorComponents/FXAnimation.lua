local class = {}
class.__index = class
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Director"))

function class:Init()
	local animationController = self.Instance.Parent and self.Instance.Parent:FindFirstChildOfClass("AnimationController")

	if not animationController then
		warn((`No AnimationController found for FXAnimation tied to {self.Instance:GetFullName()}`))
		return
	end

	local animator = animationController:FindFirstChildOfClass("Animator") or Instance.new(
		"Animator",
		animationController
	)
	local success, result = pcall(animator.LoadAnimation, animator, self.Instance)

	if not success then
		warn((`FXAnimation tied to {self.Instance:GetFullName()} failed to load animation because {result}`))
		return
	end

	self.Track = result
	result:Play(
		self.FadeTime,
		self.Weight,
		(self.Speed or 1) * (self.RandomSpeedMultiplier and 1 + math.random() * self.RandomSpeedMultiplier or 1)
	)
end

function class.Destroy(p)
	local track = p.Track

	if track then
		track:Stop()
		task.defer(track.Destroy, track)
	end
end

return {
	new = function(instance, _)
		local attributes = instance:GetAttributes()
		return (setmetatable({
			Instance = instance,
			RandomSpeedMultiplier = attributes.RandomSpeedMultiplier,
			FadeTime = attributes.FadeTime,
			Weight = attributes.Weight,
			Speed = attributes.Speed,
			Track = nil
		}, class))
	end,
	ancestor = workspace
}