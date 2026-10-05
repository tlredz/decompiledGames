local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
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
local LightAbsorption2 = require(script.Parent.Modules.LightAbsorption2)
local Beam = require(script.Parent.Modules.Beam)
return function(data)
	local charging = data.charging
	local size = data.size
	local at = data.at
	local target = data.target
	local speed = data.speed
	local chargeFor = data.chargeFor

	if (at.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 2000 then
		return
	end

	if charging == true then
		local v = Util.Sound:Play("Buddha2BeamCharge", at)
		coroutine.wrap(function()
			wait(chargeFor - 0.25)
			Util.Sound:FadeOut(v, 0.25)
		end)()
		LightAbsorption2(at, 5 * size, chargeFor - 0.1)
	else
		if (at.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 240 then
			Util.CameraShaker:ShakeOnce(25, 25, 0.1, 0.8)
		end

		local v = Util.Sound:Play("Buddha2BeamShoot", at)
		coroutine.wrap(function()
			task.wait(0.25)
			Util.Sound:FadeOut(v, 0.25)
		end)
		Beam(at.Position, target, size, speed, true)
	end
end