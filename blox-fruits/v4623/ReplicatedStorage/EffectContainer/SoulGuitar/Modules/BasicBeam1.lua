local createVector = vector.create
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
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local inverse = CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
Random.new()
local energyBeams = FX:WaitForChild("SoulGuitarEffects").EnergyBeams
return function(position, p, color, color2, p2, p3, p4)
	if p4 <= p3 then
		error("Ensure TimeUntilHit < TimeUntilDissipated")
	end

	local model = Instance.new("Model")
	model.Parent = _WorldOrigin
	model.Name = "BasicBeam1"
	destroyAfter(model, p4 + 2)
	local v = 0.1 * p2
	local v2 = v
	heartbeatLoopFor2(p3 + p4 * 0.2, function(_, _, p5)
		v = p2 * (0.1 + 0.9 * p5)
		v2 = v
	end)
	local clone = energyBeams.InnerBeam:Clone()
	local clone2 = energyBeams.OuterBeam:Clone()
	clone.Color = color
	clone2.Color = color2
	clone.Parent = model
	clone2.Parent = model
	local magnitude = (p - position).Magnitude
	local unit = (p - position).Unit

	for i = 1, 2 do
		local clone3 = energyBeams.BeamSpikes:Clone()
		clone3.Transparency = i * 0.4 / 3 + 0.4
		clone3.Color = color
		clone3.Parent = model
		local clone4 = energyBeams.BeamSpikes:Clone()
		clone4.Transparency = i * 0.2 / 3 + 0.7
		clone4.Color = color2
		clone4.Parent = model
		clone3.Size = Vector3.new(1.7, 1.7, i * 0.8 / 3 + 0.8) * v * (i * 0.2 / 3 + 0.8)
		clone4.Size = clone3.Size * 1.5
		local v6 = i
		local v8 = clone3
		local v9 = i
		local v10 = clone4
		heartbeatLoopFor2(p3, function(p5, p6, p7)
			local cframe = CFrame.lookAt(position + unit * magnitude * p7, p + unit)
			clone3.CFrame = cframe * CFrame.Angles(0, 0, 5 * p7 + v6)
			clone4.CFrame = cframe * CFrame.Angles(0, 0, -5 * p7 - v6)
			local v11 = v * (1 + 0.2 * math.random())
			clone3.Size = Vector3.new(1.7, 1.7, v6 * 0.8 / 3 + 0.8) * v11 * (v6 * 0.2 / 3 + 0.8)
			clone4.Size = clone3.Size * 1.5
		end, function()
			v8.CFrame = CFrame.lookAt(p, p + unit) * CFrame.Angles(0, 0, v9 + 5)
			v10.CFrame = CFrame.lookAt(p, p + unit) * CFrame.Angles(0, 0, -5 - v9)
			heartbeatLoopFor2(p4 - p3, function(p5, p6, p7)
				v8.CFrame *= CFrame.Angles(0, 0, v9 * 0.03 + 0.05)
				v10.CFrame *= CFrame.Angles(0, 0, -0.05 - v9 * 0.03)
				local v13 = v * (1 + 0.2 * math.random())
				local v14 = 1 - math.max(0, p7 - 0.5) * 2
				v8.Size = Vector3.new(1.7, 1.7, v9 * 0.8 / 3 + 0.8) * v13 * (v9 * 0.2 / 3 + 0.8) * v14
				v10.Size = v8.Size * 1.5
			end, function()
				local v11 = v10
				v8.Transparency = 1
				v11.Transparency = 1
			end)
		end)
	end

	local clone3 = energyBeams.Ball:Clone()
	local clone4 = energyBeams.InvertedBall:Clone()
	local size = createVector(2.5, 2.5, 2.5) * v * 0.5
	local size2 = createVector(2.5, 2.5, 2.5) * v
	clone3.Size = size
	clone4.Size = size2
	local cframe = CFrame.new(position)
	local cframe2 = CFrame.new(position)
	clone3.CFrame = cframe
	clone4.CFrame = cframe2
	clone3.Color = color
	clone4.Color = color2
	clone3.Parent = model
	clone4.Parent = model
	local clone5 = energyBeams.InitSpikes:Clone()
	clone5.Transparency = 0
	clone5.Color = color
	clone5.Parent = model
	local clone6 = energyBeams.InitSpikes:Clone()
	clone6.Transparency = 0.75
	clone6.Color = color2
	clone6.Parent = model
	clone5.Size = createVector(0.5, 0.5, 0.5) * p2
	clone6.Size = clone5.Size * 1.5
	heartbeatLoopFor2(p3, function(_, _, p5)
		clone5.Size = Vector3.new(0.5 + p5, 0.5 + p5, 0.5 + p5 * 2) * p2
		clone6.Size = clone5.Size * 1.5
		clone5.CFrame = CFrame.lookAt(position + unit * clone5.Size.Z * 0.4, p + unit) * CFrame.Angles(0, 0, -10 * p5)
		clone6.CFrame = CFrame.lookAt(position + unit * clone6.Size.Z * 0.35, p + unit) * CFrame.Angles(0, 0, 10 * p5)
	end, function()
		heartbeatLoopFor2(p4 - p3 * 2, function(_, _, transparency)
			local v6 = 1 - math.max(0, transparency - 0.5) * 2
			clone5.Size = createVector(1.5, 1.5, 2.5) * p2 * Vector3.new(v6, v6, 1)
			clone6.Size = clone5.Size * 1.5
			clone5.CFrame = CFrame.lookAt(position + unit * clone5.Size.Z * 0.4, p + unit) * CFrame.Angles(
				0,
				0,
				-10 * transparency
			)
			clone6.CFrame = CFrame.lookAt(position + unit * clone6.Size.Z * 0.35, p + unit) * CFrame.Angles(
				0,
				0,
				10 * transparency
			)
			clone5.Transparency = transparency
			clone6.Transparency = 0.75 + 0.25 * transparency
		end, function()
			local v6 = clone6
			clone5.Transparency = 1
			v6.Transparency = 1
		end)
	end)
	awaitHeartbeatLoopFor(p3, function(_, _, p5)
		local v6 = v * (0.25 + 0.75 * math.random())
		local v7 = v2 * (0.45 + 0.55 * math.random())
		clone.Size = Vector3.new(magnitude * p5, v6 * 0.25, v6 * 0.25)
		clone2.Size = Vector3.new(magnitude * p5, v6, v6)
		clone.CFrame = CFrame.lookAt(position + unit * magnitude * p5 * 0.5, p) * inverse
		clone2.CFrame = clone.CFrame
		clone4.Size = createVector(2.5, 2.5, 2.5) * v7
		clone3.Size = clone4.Size * 0.5
	end, function()
		clone.Size = Vector3.new(magnitude * 1, v * 0.25, v * 0.25)
		clone2.Size = Vector3.new(magnitude * 1, v, v)
		clone.CFrame = CFrame.lookAt(position + unit * magnitude * 1 * 0.5, p) * inverse
		clone2.CFrame = clone.CFrame
		clone4.Size = createVector(2.5, 2.5, 2.5) * v
		clone3.Size = clone4.Size * 0.5
	end)
	local v6 = p4 - p3
	awaitHeartbeatLoopFor(v6 * 0.5, function()
		local v7 = v * (0.25 + 0.75 * math.random())
		local v8 = v2 * (0.45 + 0.55 * math.random())
		clone.Size = Vector3.new(magnitude, v7 * 0.25, v7 * 0.25)
		clone2.Size = Vector3.new(magnitude, v7, v7)
		clone.CFrame = CFrame.lookAt(position + unit * magnitude * 0.5, p) * inverse
		clone2.CFrame = clone.CFrame
		clone4.Size = createVector(2.5, 2.5, 2.5) * v8
		clone3.Size = clone4.Size * 0.5
	end)
	awaitHeartbeatLoopFor(v6 * 0.5, function(_, _, p5)
		local v7 = v * (0.25 + 0.75 * math.random())
		local v8 = v2 * (0.45 + 0.55 * math.random())
		clone.Size = Vector3.new(magnitude, v7 * 0.25 * (1 - p5), v7 * 0.25 * (1 - p5))
		clone2.Size = Vector3.new(magnitude, v7 * (1 - p5), v7 * (1 - p5))
		clone4.Size = createVector(2.5, 2.5, 2.5) * v8 * (1 - p5)
		clone3.Size = clone4.Size * 0.5
	end, function()
		local v7 = clone2
		clone.Transparency = 1
		v7.Transparency = 1
		local v8 = clone3
		clone4.Transparency = 1
		v8.Transparency = 1
	end)
end