return function(animator, animationId, ...)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = animator:LoadAnimation(animation)
	track:Play(...)
	return track, animation
end