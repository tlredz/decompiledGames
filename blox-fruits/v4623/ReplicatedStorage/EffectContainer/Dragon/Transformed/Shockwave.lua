local createVector = vector.create

local function CalculateBrightness(data)
	return (math.sqrt(data.R ^ 2 * 0.241 + data.G ^ 2 * 0.691 + data.B ^ 2 * 0.068))
end

local FX = require(game.ReplicatedStorage.FX)
local RunService = game:GetService("RunService")
local shockwave = FX:WaitForChild("Dragon").Assets.Shockwave
local Tween = require(game.ReplicatedStorage.Util.Tween)
local _WorldOrigin = workspace._WorldOrigin
local v = {}
RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Last.Value - 1000, function(_)
	local now = tick()

	for k, v2 in pairs(v) do
		local v3 = now - v2.Start

		if v2.Duration < v3 then
			v2.Part:Destroy()
			v[k] = nil
		else
			local v4 = v3 / v2.Duration
			local quad = Tween.ease.inout.quad(v4, 0, 1, 1)
			local quad2 = Tween.ease.out.quad(v4, 0, 1, 1)
			local quad3 = Tween.ease["in"].quad(v4, 0, 1, 1)
			local v5 = v2.CFrame - v2.CFrame.p
			local point = Tween.point(v2.Scale[1], v2.Scale[2], quad2)
			local lerped = v2.Color[1]:Lerp(v2.Color[2], quad3)
			local lerped2 = CFrame.new():Lerp(v2.Offset, quad2)
			v2.Part.Transparency = quad
			v2.Part.CFrame = v2.CFrame * CFrame.Angles(0, 6.283185307179586 * quad2, 0) * lerped2 * v5
			v2.Mesh.Scale = v2.Unit * v2.Size * point
			v2.Mesh.VertexColor = Vector3.new(lerped.r, lerped.g, lerped.b) * (0.5 + 2 * math.sqrt(lerped.R ^ 2 * 0.241 + lerped.G ^ 2 * 0.691 + lerped.B ^ 2 * 0.068))
		end
	end
end)
return function(instance)
	local clone = shockwave:Clone()
	local mesh = clone.Mesh
	local scale = mesh.Scale
	local cFrame = instance.CFrame
	local offset = instance.Offset
	local color = instance.Color and type(instance.Color) == "userdata" and { instance.Color, instance.Color } or instance.Color or {
		Color3.new(),
		Color3.new()
	}
	local direction = instance.Direction or 1
	local scale2 = instance.Scale and type(instance.Scale) == "number" and { 0, instance.Scale } or instance.Scale or {
		0,
		1
	}
	local size = instance.Size or createVector(1, 1, 1)
	clone.CFrame = cFrame
	mesh.Scale = scale * scale2[1]
	local vector2 = Vector3.new(color[1].r, color[1].g, color[1].b)
	local v4 = color[1]
	mesh.VertexColor = vector2 * (0.5 + 2 * math.sqrt(v4.R ^ 2 * 0.241 + v4.G ^ 2 * 0.691 + v4.B ^ 2 * 0.068))
	clone.Parent = _WorldOrigin
	table.insert(v, {
		CFrame = cFrame,
		Offset = offset,
		Color = color,
		Direction = direction,
		Scale = scale2,
		Size = size,
		Part = clone,
		Mesh = mesh,
		Unit = scale,
		Duration = instance.Duration,
		Start = tick()
	})
end