local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
game:GetService("ServerStorage")
require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
return function(p)
	local root = p.root

	if (Workspace.CurrentCamera.CFrame.Position - root:GetPivot().Position).Magnitude >= 850 then
		return
	end

	if p.success then
		Util.Sound:Play("GiggleLaugh", root)
	else
		Util.Sound:Play("EvilLaugh", root)
	end
end