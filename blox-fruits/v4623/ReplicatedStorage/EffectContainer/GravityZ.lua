local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local direction = p.Direction

	if (direction.p - workspace.CurrentCamera.CFrame.p).magnitude > 600 then
		return
	end

	local unit = (direction.lookVector * createVector(1, 0, 1)).unit
	local v = {
		workspace._WorldOrigin,
		workspace.Characters,
		workspace.Enemies,
		workspace.Boats
	}
	spawn(function()
		for i = 1, 120, 10 do
			local v2 = i / 8 + 3

			for i2 = -1, 1, 2 do
				local ray, v3 = Util.Ray(
					direction * Vector3.new(i2 * 25 * (v2 / 25 + 0.8), 1, -(i / 120) * v2 / 1.8 * 12),
					createVector(0, -27, 0),
					v
				)

				if not (ray and ray.Anchored and ray.Transparency <= 0) then
					continue
				end

				local cFrame = CFrame.new(v3, v3 + unit) - createVector(0, 10, 0)
				local cFrame2 = (CFrame.new(v3, v3 + unit) - createVector(0, 1, 0)) * CFrame.Angles(
					0,
					0,
					i2 * math.rad(v2 * 1.5 + 45)
				)
				local part = Instance.new("Part")
				part.Color = ray.Color
				part.TopSurface = 0
				part.BottomSurface = 0
				part.Material = ray.Material
				part.Transparency = ray.Transparency
				part.Anchored = true
				part.CanCollide = false
				part.Size = createVector(1, 1, 1) * v2
				part.CFrame = cFrame
				part.Parent = _WorldOrigin
				local tween = TweenService:Create(part, TweenInfo.new(0.1), {
					CFrame = cFrame2
				})
				tween.Completed:Connect(function()
					wait(1)
					local tween2 = TweenService:Create(part, TweenInfo.new(0.2), {
						CFrame = cFrame
					})
					tween2.Completed:Connect(function()
						part:Destroy()
					end)
					tween2:Play()
				end)
				tween:Play()
			end

			if i % 3 == 0 then
				wait()
			end
		end
	end)
	local random = Random.new()

	for i = 1, 50 do
		local v2 = 0.15 + random:NextNumber(0, 0.1)
		local v3 = 100 + random:NextNumber(0, 25)
		local part = Instance.new("Part")
		part.Color = math.random(1, 2) == 1 and Color3.new() or Color3.fromRGB(155, 50, 255)
		part.Material = "Neon"
		part.Transparency = 0
		part.Anchored = true
		part.CanCollide = false
		part.Size = createVector(1, 1, 1)
		part.CFrame = direction * CFrame.new(random:NextNumber(-25, 25), random:NextNumber(-25, 25), 0)
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.Scale = createVector(1, 1, 20)
		specialMesh.MeshType = "Sphere"
		specialMesh.Parent = part
		part.Parent = _WorldOrigin
		local tween = TweenService:Create(specialMesh, TweenInfo.new(v2), {
			Scale = Vector3.new(0, 0, v3 / 3),
			Offset = Vector3.new(0, 0, -v3)
		})
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		tween:Play()

		if i % 5 == 0 then
			wait()
		end
	end
end