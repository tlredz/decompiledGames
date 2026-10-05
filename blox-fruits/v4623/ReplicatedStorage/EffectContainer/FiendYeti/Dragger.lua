local _ = workspace._WorldOrigin
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
return function(data)
	local _ = data.player
	local hrp = data.hrp

	if (workspace.CurrentCamera.CFrame.p - hrp.Position).Magnitude > 2500 then
		return
	end

	local syncedEndTime = data.syncedEndTime
	local v = syncedEndTime - workspace:GetServerTimeNow()

	if v < 0 then
		return
	end

	local offset = data.offset
	local victimRoot = data.victimRoot

	if not (victimRoot ~= nil and victimRoot.Parent ~= nil and victimRoot.Parent.Parent ~= nil and victimRoot.Anchored ~= true) then
		return
	end

	heartbeatLoopFor2(v, function()
		if not hrp.Parent or not victimRoot.Parent or victimRoot.Anchored or hrp.Anchored then
			return
		end

		if syncedEndTime <= workspace:GetServerTimeNow() or not hrp:IsDescendantOf(workspace) or not victimRoot:IsDescendantOf(workspace) then
			return
		end

		victimRoot.CFrame = hrp.CFrame * offset
	end)
end