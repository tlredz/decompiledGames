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
	local color = data.color

	if (at.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	if charging == true then
		local v = "GrayscaleStack" .. math.floor((math.random(1000000, 10000000)))
		local v2 = {
			Min = Workspace:GetServerTimeNow() + 2,
			Max = Workspace:GetServerTimeNow() + 8
		}

		for _, child in pairs(Workspace.Map:GetChildren()) do
			if child.Name ~= data.Tree then
				continue
			end

			child:SetAttribute(v .. "Min", v2.Min)
			child:SetAttribute(v .. "Max", v2.Max)
		end

		data.Map:SetAttribute(v .. "Min", v2.Min)
		data.Map:SetAttribute(v .. "Max", v2.Max)
		Util.Sound:Play("BF_TreeFight_Magic_Tree_Death_03", at, 60, nil, 3)
		task.spawn(function()
			LightAbsorption1(at, 8 * size, color)
		end)
		task.wait(2)
		Explosion(at.Position, size, false, color)
	else
		Util.Sound:Play("BF_TreeFight_Tree_Snap_01", at, 60, nil, 3)
		Explosion(at.Position, size, false, color)
	end
end