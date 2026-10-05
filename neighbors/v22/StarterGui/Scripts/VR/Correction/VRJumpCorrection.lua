local humanoid = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
local VRService = game:GetService("VRService")
local UserInputService = game:GetService("UserInputService")

if not VRService then
	return
end

UserInputService.InputBegan:connect(function(p, p2)
	if not p2 and p.KeyCode == Enum.KeyCode.ButtonL3 then
		humanoid.Jump = true
	end
end)