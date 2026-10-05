local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Camera_Traffic_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Camera_Traffic_Handler"))
game:GetService("RunService");
(game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
local Hiarchee = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Camera_Traffic_Handler"):WaitForChild("Hiarchee"))

for _, v in pairs(Hiarchee) do
	if v.RespawnReset == true then
		Camera_Traffic_Handler[v.Name] = false
	end
end

Checker.Enabled = true
Checker.Dashing = false
Checker.Climbing = false