local createVector = vector.create
local v = {
	"448310763",
	"448310787",
	"448310841",
	"448310864",
	"448310892",
	"448310914",
	"448310968",
	"448310934",
	"448311021"
}
local part = Instance.new("Part")
part.TopSurface = 0
part.BottomSurface = 0
part.Anchored = true
part.CanCollide = false
part.Size = createVector(1, 1, 1)
local specialMesh = Instance.new("SpecialMesh")
specialMesh.MeshType = Enum.MeshType.Brick
specialMesh.Parent = part
local FX = require(game.ReplicatedStorage.FX)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local mochiMochi = FX:WaitForChild("Mochi-Mochi")
local Tween = require(ReplicatedStorage.Util.Tween)
local Effect = require(ReplicatedStorage.Effect)
local currentCamera = workspace.CurrentCamera
return function(list)
	local v2, v3, v4, v5, _ = unpack(list)

	if not v2 or typeof(v2) ~= "Instance" then
		return
	end

	local clone = mochiMochi.Platform:Clone()
	clone.Mesh.Scale = Vector3.new()
	clone.CFrame = v3 * CFrame.Angles(-1.5707963267948966, 0, 0) + v3.LookVector * 0.1
	clone.Parent = _WorldOrigin

	if (v3.p - currentCamera.CFrame.p).Magnitude < 4 * v4 then
		local v6 = 1 - (v3.p - currentCamera.CFrame.p).Magnitude / (4 * v4)
		Effect.new("ShakeCam"):replicate({
			10 * v6,
			10 * v6,
			0,
			4 * v5,
			createVector(1, 1, 1),
			createVector(1, 0, 0)
		})
	end

	Effect.new("Mochi-Mochi.StrongHit"):replicate({ v3.p, 0.5 * v4, true })
	Effect.new("Mochi-Mochi.StrongHit"):replicate({ v3.p, 0.1 * v4 })
	Effect.new("Mochi-Mochi.Shockwave"):replicate({
		v3 * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, 1, 0),
		2 * v4,
		1.25 * v5
	})
	local v6 = {}

	for i = 1, 15 do
		local clone2 = part:Clone()
		clone2.Material = v2.Material
		clone2.Color = v2.Color
		clone2.CFrame = v3 * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
			0,
			6.283185307179586 * (i / 15),
			0
		)
		clone2.Mesh.Scale = Vector3.new()
		clone2.Parent = _WorldOrigin
		table.insert(v6, {
			Part = clone2,
			Mesh = clone2.Mesh,
			Scale = Vector3.new(1 - math.random() * 0.25, 1 - math.random() * 0.25, 1 - math.random() * 0.25) * v4 * 0.3,
			Origin = clone2.CFrame,
			Goal = clone2.CFrame * CFrame.new(0, -v4 * 0.1, -v4 * 0.4)
		})
	end

	local tweenInfo = TweenInfo.new(v5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	TweenService:Create(clone.Mesh, tweenInfo, {
		Scale = createVector(2.5, 0, 2.5) * v4
	}):Play()
	local lastTime = tick()

	while tick() - lastTime < v5 do
		local now = tick()
		local v7 = (now - lastTime) / v5
		local expo = Tween.ease.out.expo(now - lastTime, 0, 1, v5)

		for _, v8 in next, v6, nil do
			v8.Part.CFrame = v8.Origin:Lerp(v8.Goal, expo) * CFrame.Angles(
				math.rad(45 * math.random()),
				math.rad(45 * math.random()),
				(math.rad(45 * math.random()))
			)
			v8.Mesh.Scale = v8.Scale * expo
		end

		local v8 = v[math.max(1, (math.ceil(#v * v7)))]
		clone.Decal.Texture = "rbxassetid://" .. v8
		RunService.RenderStepped:Wait()
	end

	wait(2)
	local tweenInfo2 = TweenInfo.new(2 * v5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	for _, v7 in next, v6, nil do
		local tween = TweenService:Create(v7.Part, tweenInfo2, {
			Transparency = 1
		})
		local v8 = v7
		tween.Completed:Connect(function()
			v8.Part:Destroy()
		end)
		tween:Play()
	end

	wait(1)
	local tween = TweenService:Create(clone.Decal, tweenInfo2, {
		Transparency = 1
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
end