wait()
local humanoid = game.Players.LocalPlayer.Character.Humanoid

for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
	v:Stop()
end

local track = humanoid:LoadAnimation(script.Walking)
local track2 = humanoid:LoadAnimation(script.Run)
local track3 = humanoid:LoadAnimation(script.Idle)
local track4 = humanoid:LoadAnimation(script.Jump)
track3:Play()
humanoid.Running:Connect(function(p)
	if p >= 1 and p <= 16 then
		if not track2.IsPlaying then
			track2:Stop()
		end

		if track.IsPlaying then
			track:AdjustSpeed(p / 16)
		else
			track:Play()
			track:AdjustSpeed(1.5)
		end

		if track3.IsPlaying then
			track3:Stop()
		end
	elseif p >= 17 then
		if not track2.IsPlaying then
			track2:Play()
		end

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
			track3:Play(0.1, 1, 0.5)
		end
	end
end)
humanoid.StateChanged:Connect(function(_, p)
	if p == Enum.HumanoidStateType.Jumping then
		track4:Play()
	elseif p == Enum.HumanoidStateType.Landed and track4.IsPlaying then
		track4:Stop()
	end
end)
humanoid.FreeFalling:Connect(function(p)
	if not p and track4.IsPlaying then
		track4:Stop()
	end
end)