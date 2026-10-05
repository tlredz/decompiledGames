local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local service = game:service("ReplicatedStorage")
local Util = require(service:WaitForChild("Util"))
local _ = Util.Debris
local _ = Util.Tween
local Queue = require(service:WaitForChild("Queue"))

function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local lightning_Part = Queue.new("Lightning_Part", function(object, p, data, _)
	local _ = data.origin
	local particles = data.particles
	local variance = data.variance
	local origin = data.origin
	local target = data.target
	local distance = data.distance
	local segments = data.segments

	if data.time < data.duration then
		local v = origin

		for k, particle in next, particles, nil do
			local v2 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * variance
			local v3 = CFrame.new(origin, target) * CFrame.new(0, 0, -k * (distance / segments)) * v2
			local magnitude = (v - v3).magnitude

			for k2, v4 in next, particle, nil do
				v4.CFrame = CFrame.new(v, v3) * CFrame.new(0, 0, -magnitude / 2)
				v4.Mesh.Scale = (k2 == 1 and 1 or -1) * Vector3.new(
					k2 == 1 and data.size or data.layerSize,
					k2 == 1 and data.size or data.layerSize,
					magnitude
				) / 0.05
			end

			v = v3
		end
	else
		for _, particle in next, particles, nil do
			for _, v in next, particle, nil do
				v:Destroy()
			end
		end

		object:remove(p)
	end
end, 300, 0.0014285714285714286)
return function(data)
	local segments = data.Segments or 1
	local variance = data.Variance or 1
	local size = data.Size or 0.25
	local layerSize = data.LayerSize or size * 1.5
	local origin = data.Origin or Vector3.new()
	local target = data.Target or Vector3.new()
	local color = data.Color or Color3.new(1, 1, 1)
	local layerColor = data.LayerColor or Color3.new(0, 1, 1)
	local duration = data.Duration or 1
	local magnitude = (origin - target).magnitude
	local v = origin
	local particles = {}

	for i = 1, segments do
		local v3 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * variance
		local v4 = CFrame.new(origin, target) * CFrame.new(0, 0, -i * (magnitude / segments)) * v3
		local magnitude2 = (v - v4).magnitude
		local v5 = {}

		for i2 = 1, 2 do
			local part = Instance.new("Part")
			part.Color = i2 == 1 and color or layerColor
			part.Transparency = i2 == 1 and 0 or 0.5
			part.Material = "Neon"
			part.TopSurface = 0
			part.BottomSurface = 0
			part.Anchored = true
			part.CanCollide = false
			part.Size = createVector(0.05, 0.05, 0.05)
			part.CFrame = CFrame.new(v, v4) * CFrame.new(0, 0, -magnitude2 / 2)
			local blockMesh = Instance.new("BlockMesh")
			blockMesh.Scale = (i2 == 1 and 1 or -1) * Vector3.new(
				i2 == 1 and size or layerSize,
				i2 == 1 and size or layerSize,
				magnitude2
			) / 0.05
			blockMesh.Parent = part
			part.Parent = _WorldOrigin
			table.insert(v5, part)
		end

		table.insert(particles, v5)
		v = v4
	end

	lightning_Part:add({
		duration = duration,
		origin = origin,
		target = target,
		variance = variance,
		distance = magnitude,
		segments = segments,
		particles = particles,
		size = size,
		layerSize = layerSize
	})
end