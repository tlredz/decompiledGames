local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
game:GetService("RunService")
Vector3.new()
require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.LightningBolt2
local _ = Util.Promise
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local Shockwave = require(script.Parent.Modules.Shockwave)
return function(p)
	local pos = p.pos

	if (pos - Workspace.CurrentCamera.CFrame.p).Magnitude > 700 then
		return
	end

	local v = Util.Sound:Play("BuddhaJump", pos)
	coroutine.wrap(function()
		wait(0.4)
		Util.Sound:FadeOut(v, 0.3)
	end)()
	Shockwave(pos, 10)
end