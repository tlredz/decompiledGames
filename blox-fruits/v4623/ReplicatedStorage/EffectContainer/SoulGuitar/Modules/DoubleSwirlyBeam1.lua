local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("PhoenixEffects").Shockwaves
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
CFrame.lookAt(Vector3.new(), vector.create(1, 0, 0)):inverse()
Random.new()
local energyBeams = FX:WaitForChild("SoulGuitarEffects").EnergyBeams
local BasicBeam1 = require(script.Parent:WaitForChild("BasicBeam1"))
return function(p, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11)
	if p7 <= p6 then
		error("Ensure TimeUntilHit < TimeUntilDissipated")
	end

	local model = Instance.new("Model")
	model.Parent = _WorldOrigin
	model.Name = "DoubleSwirlyBeam1"
	destroyAfter(model, p7 + 2)
	coroutine.wrap(BasicBeam1)(p, p2, p3, p4, p5, p6, p7)
	local v = p6 + (p7 - p6) * 0.5
	local v2 = 1
	task.spawn(function()
		task.wait(v)
		heartbeatLoopFor2(p7 - v, function(_, _, p12)
			v2 = 1 - p12
		end)
	end)
	local magnitude = (p2 - p).Magnitude
	local unit = (p2 - p).Unit
	local v3 = {
		energyBeams.SpiralInner,
		energyBeams.SpiralOuter,
		energyBeams.SpiralInner,
		energyBeams.SpiralOuter
	}
	local v4 = {
		1.92,
		2.2,
		1.92,
		2.2
	}
	local v5 = {
		p8,
		p9,
		p10,
		p11
	}

	for i = 1, 4 do
		local clone = v3[i]:Clone()
		local v6 = v4[i]
		clone.Size = Vector3.new(p5 * v6, p5 * v6, 1)
		clone.Color = v5[i]
		clone.Parent = model
		local v7 = i >= 3 and 3.141592653589793 or 0
		local v11 = clone
		local v12 = v7
		local v13 = v6
		heartbeatLoopFor2(p6, function(p12, p13, p14)
			clone.Size = Vector3.new(p5 * v6, p5 * v6, magnitude * p14)
			clone.CFrame = CFrame.lookAt(p + unit * magnitude * p14 * 0.5, p2) * CFrame.Angles(0, 0, v7 - 24 * p6 * p14)
		end, function()
			v11.CFrame = CFrame.lookAt(p + unit * magnitude * 0.5, p2) * CFrame.Angles(0, 0, v12 - 24 * p6)
			heartbeatLoopFor2(p7 - p6, function(p12, p13, p14)
				v11.Size = Vector3.new(p5 * v13 * v2, p5 * v13 * v2, magnitude)
				v11.CFrame *= CFrame.Angles(0, 0, -0.4)
				v11.Transparency = 1 - v2
			end, function()
				v11.Transparency = 1
			end)
		end)
	end
end