wait()
local humanoid = game.Players.LocalPlayer.Character.Humanoid

for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
	v:Stop()
end

local track = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Walk)
local track2 = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Run)
local track3 = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Idle)
track3:Play()
humanoid.Running:Connect(function(p)
	if p >= 1 and p <= 17 then
		if track2.IsPlaying then
			track2:Stop()
		end

		if not track.IsPlaying then
			track:Play()
			track:AdjustSpeed(1.5)
		end

		if track3.IsPlaying then
			track3:Stop()
		end
	elseif p >= 18 then
		if not track2.IsPlaying then
			track2:Play()
		end

		track2:AdjustSpeed(humanoid.WalkSpeed / 46)

		if track.IsPlaying then
			track:Stop()
		end

		if track3.IsPlaying then
			track3:Stop()
		end
	elseif p <= 0 then
		if track2.IsPlaying then
			track2:Stop()
		end

		if track.IsPlaying then
			track:Stop()
		end

		if not track3.IsPlaying then
			track3:Play()
		end
	end
end)