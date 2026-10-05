workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Tween
local _ = Util.Debris
local Queue = require(ReplicatedStorage:WaitForChild("Queue"))
local random = math.random
local _ = math.max
local new = CFrame.new
local angles = CFrame.Angles
local lightning_Beam = Queue.new("Lightning_Beam", function(object, p, data, _)
	if data.time < data.dur then
		local variance = data.variance
		local particle = data.particle
		local layer = data.layer
		data.b.CFrame = new(data.target + data.displacement * data.time) * angles(
			(random() - 0.5) * 3.141592653589793 * 4,
			(random() - 0.5) * 3.141592653589793 * 4,
			(random() - 0.5) * 3.141592653589793 * 4
		)

		if variance > 0 and data.segments > 0 then
			local curveSize = variance * 3.141592653589793 * 2 * (random() - 0.5) * 2
			local curveSize2 = variance * 3.141592653589793 * 2 * (random() - 0.5) * 2
			particle.CurveSize0 = curveSize
			particle.CurveSize1 = curveSize2
			local curveSize0 = particle.CurveSize0
			local curveSize1 = particle.CurveSize1
			layer.CurveSize0 = curveSize0
			layer.CurveSize1 = curveSize1
		end

		if data.fade and data.time > data.fade then
			local numberSequence = NumberSequence.new((data.time - data.fade) / (data.dur - data.fade))
			particle.Transparency = numberSequence
			layer.Transparency = numberSequence
		end
	else
		data.a:Destroy()
		data.b:Destroy()
		object:remove(p)
	end
end, 300, 0.0014285714285714286)
return function(data)
	local segments = data.Segments or 3
	local variance = data.Variance or 1
	local size = data.Size or 0.5
	local layerSize = data.LayerSize or size * 1.5
	local origin = data.Origin or Vector3.new()
	local target = data.Target or Vector3.new()
	local color = data.Color or Color3.new(1, 1, 1)
	local layerColor = data.LayerColor or Color3.new(0, 1, 1)
	local duration = data.Duration or 1
	local v = data.Curvy and 0 or 1
	local texture = data.Texture or ""
	local lightEmission = data.LightEmission or 1
	local attachment = Instance.new("Attachment")
	local attachment2 = Instance.new("Attachment")
	local cframe = CFrame.new(origin)
	local cframe2 = CFrame.new(target)
	attachment.CFrame = cframe
	attachment2.CFrame = cframe2
	local clone = FX:WaitForChild("Lightning"):Clone()
	clone.LightEmission = lightEmission
	clone.Texture = texture
	clone.Color = ColorSequence.new(color)
	clone.Width0 = size * v
	clone.Width1 = size
	clone.Attachment0 = attachment
	clone.Attachment1 = attachment2
	clone.Segments = segments
	local clone2 = clone:Clone()
	clone2.LightEmission = lightEmission
	clone2.Color = ColorSequence.new(layerColor)
	clone2.Width0 = layerSize * v
	clone2.Width1 = layerSize
	clone2.Attachment0 = attachment
	clone2.Attachment1 = attachment2
	clone2.Segments = segments
	clone2.ZOffset = -0.05
	clone.Parent = attachment
	clone2.Parent = attachment
	local terrain = workspace.Terrain
	local terrain2 = workspace.Terrain
	attachment.Parent = terrain
	attachment2.Parent = terrain2
	lightning_Beam:add({
		dur = duration,
		a = attachment,
		b = attachment2,
		target = target,
		variance = variance,
		layer = clone2,
		particle = clone,
		displacement = data.Displacement or Vector3.new(),
		fade = data.FadeOut,
		segments = segments
	})
end