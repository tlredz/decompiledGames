wait()
local humanoid = game.Players.LocalPlayer.Character.Humanoid

if not Animator then
	Animator = Instance.new("Animator")
	Animator.Parent = humanoid
end

for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
	v:Stop()
end

local track = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Walk)
local track2 = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Idle)
track2:Play()
humanoid.Running:Connect(function(p)
	if p > 1 then
		if not track.IsPlaying then
			track:Play()
		end

		track:AdjustSpeed(p / 36)

		if track2.IsPlaying then
			track2:Stop()
		end
	elseif p <= 0 then
		if track.IsPlaying then
			track:Stop()
		end

		if not track2.IsPlaying then
			track2:Play()
		end
	end
end)