return {
	Start = function(p)
		local animationController = p.Instance:FindFirstChild("AnimationController", true)

		if animationController and animationController:IsA("AnimationController") then
			local idle = p.Instance:FindFirstChild("Idle", true)

			if idle and idle:IsA("Animation") then
				local animator = animationController:FindFirstChildOfClass("Animator") or Instance.new("Animator")
				animator.Parent = animationController
				local track = animator:LoadAnimation(idle)
				track:Play()
				p._trove:Add(track)
			end
		end
	end
}