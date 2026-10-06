wait()
local humanoid = game.Players.LocalPlayer.Character.Humanoid

for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
	v:Stop()
end

local track = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Walk)
local track2 = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Run)
local track3 = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Idle)
local track4 = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Jump)
local track5 = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Fall)
track.Priority = Enum.AnimationPriority.Movement
track2.Priority = Enum.AnimationPriority.Movement
track3.Priority = Enum.AnimationPriority.Idle
track4.Priority = Enum.AnimationPriority.Movement
track5.Priority = Enum.AnimationPriority.Movement
track3:Play(0.1, 1, 0.35)
humanoid.Running:Connect(function(p)
	if p > 0 and p <= 17 then
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

		track2:AdjustSpeed(humanoid.WalkSpeed / 56)

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
			track3:Play(0.1, 1, 0.35)
		end
	end
end)
humanoid.StateChanged:Connect(function(_, p)
	if p == Enum.HumanoidStateType.Jumping then
		if track2.IsPlaying then
			track2:Stop()
		end

		if track.IsPlaying then
			track:Stop()
		end

		if track3.IsPlaying then
			track3:Stop()
		end

		track4:Play()
	elseif p == Enum.HumanoidStateType.Freefall then
		if track2.IsPlaying then
			track2:Stop()
		end

		if track.IsPlaying then
			track:Stop()
		end

		if track3.IsPlaying then
			track3:Stop()
		end

		if not track5.IsPlaying then
			track5:Play()
		end
	elseif p == Enum.HumanoidStateType.Landed then
		if track5.IsPlaying then
			track5:Stop()
		end

		if not track3.IsPlaying then
			track3:Play(0.1, 1, 0.35)
		end

		if track4.IsPlaying then
			track4:Stop()
		end
	end
end)
humanoid.FreeFalling:Connect(function(p)
	if not p and track4.IsPlaying then
		track4:Stop()
	end
end)