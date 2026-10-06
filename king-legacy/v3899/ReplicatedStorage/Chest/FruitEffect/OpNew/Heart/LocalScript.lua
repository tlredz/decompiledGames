local parent = script.Parent
local v = true
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character

if not character then
	repeat
		wait(0.15)
		character = localPlayer.Character
	until character
end

character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local track = humanoid:LoadAnimation((script:WaitForChild("ControlHeartIdle", 30)))
game:GetService("RunService")
parent.Equipped:Connect(function()
	track:Play()
end)
parent.Unequipped:Connect(function()
	if track.IsPlaying then
		track:Stop()
	end
end)
parent.Activated:Connect(function()
	if not v then
		return
	end

	v = false
	_G.StopAnimationClient(humanoid, {
		ControlHeartIdle = true
	})
	spawn(function()
		wait(0.05)
		v = true
	end)

	if track.IsPlaying then
		track:Stop()
	end
end)