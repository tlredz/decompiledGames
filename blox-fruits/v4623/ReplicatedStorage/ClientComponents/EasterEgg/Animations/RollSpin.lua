local Anims = require(game.ReplicatedStorage.Util.Anims)

local function getAnimator(instance)
	local animationController = instance:FindFirstChildWhichIsA("AnimationController")

	if not animationController then
		warn((`No animation controller found for {instance.Name}`))
		return nil
	end

	local v = animationController:FindFirstChildWhichIsA("Animator")

	if not v then
		v = Instance.new("Animator")
		v.Parent = animationController
	end

	return v
end

return function(p, flag: boolean)
	local raw = Anims:GetRaw(flag and "EasterEggRollSpinUpright" or "EasterEggRollSpin")
	local animator = getAnimator(p)

	if not animator then
		return function() end
	end

	local track = animator:LoadAnimation(raw)
	track:Play()
	return function()
		track:Stop()
	end
end