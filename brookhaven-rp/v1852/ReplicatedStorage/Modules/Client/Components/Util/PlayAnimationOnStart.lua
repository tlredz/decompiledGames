local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PlayAnimationOnStart"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local animation = self.Instance:WaitForChild("Animation")

	if not animation then
		return
	end

	local animationController = self.Instance:WaitForChild("AnimationController")

	if not animationController then
		return
	end

	local animator = animationController:WaitForChild("Animator")

	if not animator then
		return
	end

	self.animationInstance = animator:LoadAnimation(animation)
	self.animationInstance:Play()
end

function v:Stop()
	self._Janitor:Destroy()
	self.animationInstance:Stop()
end

return v