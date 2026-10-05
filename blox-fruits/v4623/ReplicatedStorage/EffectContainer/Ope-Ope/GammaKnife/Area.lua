local createVector = vector.create

local function LerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Tween = require(game.ReplicatedStorage.Util.Tween)
local v = {}
RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Camera.Value, function(_)
	local now = tick()

	for k, v2 in next, v, nil do
		local v3 = now - v2.Start

		if v2.Duration < v3 then
			v2.Part:Destroy()
			table.remove(v, k)
		else
			local quad = Tween.ease.out.quad(v3, 0, 1, v2.Duration)
			v2.Part.Transparency = 0.5 + 0.5 * quad
			v2.Mesh.Scale = v2.OriginalScale:Lerp(Vector3.new(), quad)
		end
	end
end)
return function(list)
	local _, v2, v3, duration = unpack(list)
	local part = Instance.new("Part")
	part.CastShadow = false
	part.Anchored = true
	part.CanCollide = false
	part.Material = "Neon"
	part.TopSurface = 0
	part.BottomSurface = 0
	part.Color = Color3.new(0, 1, 0)
	part.Transparency = 0.5
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(v2)
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.MeshType = "Sphere"
	specialMesh.Scale = createVector(1, 1, 1) * v3
	part.Parent = _WorldOrigin
	table.insert(v, {
		Part = part,
		Mesh = specialMesh,
		OriginalScale = specialMesh.Scale,
		Duration = duration,
		Start = tick()
	})
end