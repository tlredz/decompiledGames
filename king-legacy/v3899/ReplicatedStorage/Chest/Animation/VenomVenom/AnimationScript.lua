wait()
local humanoid = game.Players.LocalPlayer.Character.Humanoid

for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
	v:Stop()
end

local track = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Demon_Walking)
local track2 = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Demon_Idle)
track2:Play()
humanoid.Running:Connect(function(p)
	if p > 1 then
		if track.IsPlaying then
			track:AdjustSpeed(p / 16)
		else
			track:Play()
			track:AdjustSpeed(1.5)
		end

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