local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
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
		for i = 110, 1, -10 do
			local v2 = i / 8 + 3

			for i2 = -1, 1, 2 do
				local ray, v3 = Util.Ray(
					direction * Vector3.new(i2 * 15 * (v2 / 25 + 0.8), 1, -(i / 120) * v2 / 1.8 * 12),
					createVector(0, -17, 0),
					v
				)

				if not (ray and ray.Anchored and ray.Transparency <= 0) then
					continue
				end

				local cFrame = (CFrame.new(v3, v3 + unit) - createVector(0, 10, 0)) * CFrame.Angles(
					0,
					0,
					3.141592653589793 * math.random() * 2
				)
				local cFrame2 = cFrame + createVector(0, 7, 0)
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
					wait(2)
					local tween2 = TweenService:Create(part, TweenInfo.new(0.4 + math.random() * 0.6), {
						CFrame = cFrame - Vector3.new(0, part.Size.Y * 1.25, 0)
					})
					tween2.Completed:Connect(function()
						part:Destroy()
					end)
					tween2:Play()
				end)
				tween:Play()
			end

			if i % 20 == 0 then
				Effect.new("Wind"):replicate({
					CFrame = direction * CFrame.new(0, 0, -(i / 120) * v2 / 1.8 * 12) * CFrame.Angles(
						0,
						3.141592653589793,
						0
					),
					Color = Color3.new(1, 1, 1),
					Size = v2 * 2,
					Duration = 0.5
				})
			end

			if i % 3 == 0 then
				wait()
			end
		end
	end)
	local random = Random.new()

	for i = 1, 50 do
		local v2 = 0.15 + random:NextNumber(0, 0.1)
		local v3 = 95 + random:NextNumber(0, 15)
		local part = Instance.new("Part")
		part.Color = math.random(1, 2) == 1 and Color3.new(1, 1, 1) or Color3.fromRGB(110, 153, 202)
		part.Material = "Neon"
		part.Transparency = 0.5
		part.Anchored = true
		part.CanCollide = false
		part.Size = createVector(1, 1, 1)
		part.CFrame = direction * CFrame.new(random:NextNumber(-15, 15), random:NextNumber(-15, 15), 0)
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.Scale = Vector3.new(1, 1, v3)
		specialMesh.Offset = Vector3.new(0, 0, -v3)
		specialMesh.MeshType = "Sphere"
		specialMesh.Parent = part
		part.Parent = _WorldOrigin
		local tween = TweenService:Create(specialMesh, TweenInfo.new(v2), {
			Scale = createVector(1, 1, 0),
			Offset = createVector(0, 0, 0)
		})
		local tween2 = TweenService:Create(part, TweenInfo.new(v2), {
			Transparency = 1
		})
		tween2.Completed:Connect(function()
			part:Destroy()
		end)
		tween:Play()
		tween2:Play()

		if i % 5 == 0 then
			wait()
		end
	end
end