local parent = script.Parent
local localPlayer = game.Players.LocalPlayer

repeat
	task.wait()
until localPlayer.Character

local track = localPlayer.Character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(script:WaitForChild("UseAnim"))
parent.Activated:Connect(function()
	if track.IsPlaying then
		return
	end

	track:Play()
end)