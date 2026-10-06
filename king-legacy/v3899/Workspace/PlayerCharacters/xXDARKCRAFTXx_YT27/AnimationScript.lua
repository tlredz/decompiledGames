wait()
local character = game.Players.LocalPlayer.Character
local humanoid = character.Humanoid
local _ = character.HumanoidRootPart

for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
	v:Stop()
end

local track = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Fly)
local track2 = _G.PU.GetAnimator(humanoid):LoadAnimation(script.Idle)
track2:Play()
humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
	if character:FindFirstChild("Doing") then
		if track.IsPlaying then
			track:Stop()
		end

		if not track2.IsPlaying then
			track2:Play()
		end
	else
		local v = humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed

		if v >= 1 then
			if track2.IsPlaying then
				track2:Stop(0.4)
			end

			if not track.IsPlaying then
				track:Play(0.4)
			end
		elseif v <= 0 then
			if track.IsPlaying then
				track:Stop(0.4)
			end

			if not track2.IsPlaying then
				track2:Play(0.4)
			end
		end
	end
end)