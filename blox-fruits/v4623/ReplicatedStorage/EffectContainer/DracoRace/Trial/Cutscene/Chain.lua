-- failed to load script (decompiled with syntax error):
-- rMaJBklcRAnLlBGfBdpzaGPSp:11: Expected identifier when parsing variable name, got 'end'

local createVector = vector.create
local FX = require(game.ReplicatedStorage.FX)
local v = {}
local Chain = {}
Chain.__index = Chain

function Chain.new(end, end2)
	local object = setmetatable({}, Chain)
	object.Model = Instance.new("Model", end.Parent.Parent.Parent)
	object.Particles = {}
	object.Positions = {}
	object.PrevPositions = {}
	object.Velocities = {}
	object.End1 = end
	object.End2 = end2

	for i = 1, 20 do
		local lerped = end.Position:Lerp(end2.Position, (i - 1) / 19)
		table.insert(object.Positions, lerped)
		table.insert(object.PrevPositions, lerped)
		table.insert(object.Velocities, createVector(0, 0, 0))
	end

	for _ = 1, 19 do
		local clone = FX:WaitForChild("DracoRace").Trial.Cutscene.Chain.Link:Clone()
		clone.Parent = object.Model
		table.insert(object.Particles, clone)
	end

	for _ = 1, 300 do
		object:AdvanceFrame()
	end

	table.insert(v, object)
	return object
end

function Chain:AdvanceFrame()
	local velocities = self.Velocities
	local positions = self.Positions
	local prevPositions = self.PrevPositions
	local position = self.End1.WorldCFrame.Position
	local position2 = self.End2.WorldCFrame.Position

	for i = 2, 19 do
		local v2 = (velocities[i] + createVector(0, -16.350002, 0)) * 0.96
		local position3 = positions[i]
		local v3 = position3 + v2 * 0.016666666666666666
		prevPositions[i] = position3
		positions[i] = v3
	end

	for _ = 1, 2 do
		for i = 1, 19 do
			local position3 = positions[i]
			local v2 = positions[i + 1] - position3
			local magnitude = v2.Magnitude
			local v3 = (magnitude - 30.94736842105263) / magnitude
			local v4 = i == 1 and 0 or 0.5
			local v5 = i + 1 == 20 and 0 or 0.5
			local v6 = v4 + v5

			if not (v6 > 0) then
				continue
			end

			positions[i] += v4 / v6 * v2 * v3
			positions[i + 1] = positions[i + 1] - v5 / v6 * v2 * v3
		end

		positions[1] = position
		positions[20] = position2
	end

	for i = 2, 19 do
		velocities[i] = (positions[i] - prevPositions[i]) * Vector3.new(1, math.sin(0.15707963267948966 * i), 1) / 0.016666666666666666
	end

	for k, particle in pairs(self.Particles) do
		particle.CFrame = CFrame.new(positions[k], positions[k + 1]) * CFrame.new(0, 0, -16) * CFrame.Angles(
			0,
			1.5707963267948966,
			0
		) * CFrame.Angles(k % 2 == 0 and 0 or 1.5707963267948966, 0, 0)
	end
end

function Chain.Earthquake(p, p2, value, value2, value3)
	local v2 = value or 0.001
	local v3 = value2 or 15
	local v4 = value3 or 6
	task.spawn(function()
		local total = 0

		while total < p2 do
			total += task.wait()
			local v5 = math.min(total / v2, 1) * v3
			local v6 = (CFrame.new(p.Positions[1], p.Positions[20]).RightVector + createVector(0, 0.3, 0)) * (v5 + (math.random() - 0.5) * v5 * 0.2)

			for i = 2, 19 do
				p.Velocities[i] = p.Velocities[i] + v6 * math.cos(0.15707963267948966 * i * v4 + total * 3.141592653589793 * v4)
			end
		end
	end)
end

function Chain.Destroy(p, _)
	table.remove(v, table.find(v, p))
end

task.spawn(function()
	local now = os.clock()

	while task.wait() do
		if os.clock() - now + 0.001 < 0.016666666666666666 then
			continue
		end

		local v2 = math.floor((os.clock() - now) * 60)
		now += v2 / 60

		for _ = 1, v2 * 2 do
			for _, v3 in pairs(v) do
				v3:AdvanceFrame()
			end
		end
	end
end)
return Chain