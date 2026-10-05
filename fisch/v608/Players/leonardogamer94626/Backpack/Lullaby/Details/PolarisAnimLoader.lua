local animator = script.Parent:WaitForChild("AnimationController"):WaitForChild("Animator")
local animation = script:WaitForChild("Animation")

for _, v in animator:GetPlayingAnimationTracks() do
	if v.Animation and v.Animation.AnimationId == script.Animation.AnimationId then
		return
	end
end

local track = animator:LoadAnimation(animation)
track.Looped = true
track.Priority = Enum.AnimationPriority.Idle
track:Play()