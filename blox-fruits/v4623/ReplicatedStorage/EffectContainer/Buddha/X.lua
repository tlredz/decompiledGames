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
local LightAbsorption1 = require(script.Parent.Modules.LightAbsorption1)
local Explosion = require(script.Parent.Modules.Explosion)
return function(data)
	local charging = data.charging
	local size = data.size
	local at = data.at

	if (at.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	if charging == true then
		LightAbsorption1(at, 2 * size)
	else
		Explosion(at.Position, size)
	end
end