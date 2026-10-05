local createVector = vector.create

-- equivalent calls inferred from this helper; original call sites unknown
local function InvertCFrame(object)
	local components, v, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11 = object:components()
	return CFrame.new(components, v, v2, v3, v4, v5, v6, v7, v8, -v9, -v10, -v11)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local tween = Util.Tween
local expo = tween.ease.out.expo
local _ = tween.ease.out.quad
local _ = tween.ease.out.sine
require(game.ReplicatedStorage:WaitForChild("Effect"))
local FX = require(game.ReplicatedStorage.FX)
local renderDistance = Util.RenderDistance
local currentCamera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local v = {}
RunService:BindToRenderStep("BasicExplosion", Enum.RenderPriority.Last.Value + 1004, function(p)
	for k, v2 in pairs(v) do
		local inner = v2.Inner
		local outer = v2.Outer
		local v3 = math.min(v2.Duration, tick() - v2.Start)

		if v2.RenderDistance:WithinRange(p) then
			local v4 = v2.Duration * 0.8
			local scale = expo(v3, v2.Size[1], v2.Size[2] - v2.Size[1], v4) * createVector(1, 1, 1)
			inner.Mesh.Scale = scale
			outer.Mesh.Scale = scale * 1.125
			local v6 = v2.Duration * 0.15
			local v7 = v2.Duration * 0.65

			if v6 < v3 then
				local transparency = (v3 - v6) / (v7 - v6)
				inner.Transparency = transparency
				outer.Transparency = transparency * 1.3
				inner.CFrame = CFrame.new(v2.CF.p, v2.CF.p + currentCamera.CFrame.lookVector) * CFrame.new(0, 0, 0.1)
				outer.CFrame = InvertCFrame(CFrame.new(inner.CFrame.p, inner.CFrame.p + currentCamera.CFrame.lookVector) * CFrame.new(
					0,
					0,
					-0.1
				))
			end
		end

		if v3 ~= v2.Duration then
			continue
		end

		inner:Destroy()
		outer:Destroy()
		v[k] = nil
	end
end)

local function Sphere()
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Size = createVector(1, 1, 1)
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Scale = createVector(1, 1, 1)
	return part
end

local _WorldOrigin = workspace._WorldOrigin
local BasicExplosion = {}
BasicExplosion.__index = BasicExplosion

function BasicExplosion.new(data)
	if data.Position then
		local cframe = CFrame.new(data.Position)
		return (setmetatable({
			Size = data.Size or { 0, 25 },
			Color = data.Color or {
				Outer = Color3.new(1, 0.6, 0),
				Inner = Color3.new(1, 1, 1)
			},
			Duration = data.Duration or 0.6,
			CF = cframe,
			Rocks = data.Rocks,
			Quality = data.Quality or 1
		}, {
			__index = BasicExplosion
		}))
	else
		print(script.Name, "Position not found")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, scar, p, _)
	local clone = scar:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	return clone
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { workspace.Map }
local RocksModule = require(game.ReplicatedStorage.Util.RocksModule)

function BasicExplosion.Run(data)
	local CF = data.CF
	local size = data.Size or { 0, 1 }
	local color = data.Color or {
		Outer = Color3.new(1, 0.6, 0),
		Inner = Color3.new(1, 1, 1)
	}
	local duration = data.Duration or 1
	local renderDistance2 = renderDistance.new(CF.p, 330, 330 + size[2] * 6, 0.2)

	if (CF.p - workspace.CurrentCamera.CFrame.p).magnitude > 400 + size[2] * 10 then
		return data
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Size = createVector(1, 1, 1)
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Scale = createVector(1, 1, 1)
	part.Color = color.Outer
	part.CFrame = InvertCFrame(CF)
	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.Material = Enum.Material.Neon
	part2.Size = createVector(1, 1, 1)
	local specialMesh2 = Instance.new("SpecialMesh", part2)
	specialMesh2.MeshType = Enum.MeshType.Sphere
	specialMesh2.Scale = createVector(1, 1, 1)
	part2.Color = color.Inner
	part2.CFrame = CF
	part.Parent = _WorldOrigin
	part2.Parent = _WorldOrigin
	table.insert(v, {
		Start = tick(),
		CF = CF,
		Duration = duration,
		Inner = part2,
		Outer = part,
		Size = size,
		RenderDistance = renderDistance2
	})

	if data.Rocks then
		local raycastResult = workspace:Raycast(
			CF.Position + createVector(0, 2.5, 0),
			Vector3.new(0, -data.Size[2] / 3, 0),
			raycastParams
		)

		if raycastResult then
			local v3 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
			local scar, v4, _ = FX:WaitForChild("Scar")
			local effect = createEffect(v3, scar, v4) -- equivalent call inferred; original call site unknown
			effect.Size = Vector3.new(data.Size[2], 0, data.Size[2]) * 1.25
			effect.Parent = workspace._WorldOrigin
			task.delay(data.Duration * 1.5, function()
				local TweenService = game:GetService("TweenService")
				TweenService:Create(effect.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Transparency = 1
				}):Play()
			end)
			Util.Debris:AddItem(effect, data.Duration * 1.5 + 1)
		end

		RocksModule.Ground(
			CF.p,
			data.Size[2] * 0.75,
			createVector(6, 6.6666665, 6) * data.Size[2] / 60,
			{ workspace.Map },
			10 * data.Size[2] / 60,
			false,
			data.Duration * 1.5,
			true
		)
	end

	if not (data.Quality >= 1) then
		return data
	end

	local attachment = Instance.new("Attachment")
	attachment.Position = CF.p
	attachment.Parent = workspace.Terrain
	local clone = FX:WaitForChild("EnergyRing"):Clone()
	clone.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, size[1]),
		NumberSequenceKeypoint.new(0.2, size[2] * 0.9),
		NumberSequenceKeypoint.new(0.3, size[2] * 1.1),
		NumberSequenceKeypoint.new(0.6, size[2] * 1.35),
		NumberSequenceKeypoint.new(1, size[2] * 1.5)
	})
	clone.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.25, 0.75),
		NumberSequenceKeypoint.new(1, 1)
	})
	clone.Enabled = false
	clone.Color = ColorSequence.new(color.Outer)
	clone.Lifetime = NumberRange.new(duration * 1.35, duration * 1.35)
	clone.Parent = attachment
	clone:Emit(1)

	if data.Quality >= 2 then
		for _ = 1, 20 do
			local v3 = size[2] / duration
			local clone2 = FX:WaitForChild("Explosions").Orbs:Clone()
			clone2.Color = ColorSequence.new(color.Outer)
			clone2.Lifetime = NumberRange.new(duration * 0.8, duration * 1.45)
			clone2.Enabled = false
			clone2.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, (size[1] + size[2]) / 8 * (0.3 + math.random() * 0.7)),
				NumberSequenceKeypoint.new(1, 2)
			})
			clone2.Speed = NumberRange.new(v3 * 6, v3 * 10)
			clone2.Drag = v3 / 9
			clone2.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.35),
				NumberSequenceKeypoint.new(1, 1)
			})
			clone2.Parent = attachment
			clone2:Emit(3)
		end
	end

	spawn(function()
		wait(duration * 1.66 + 0.1)
		attachment:Destroy()
	end)
	return data
end

return BasicExplosion