local createVector = vector.create
local util = game.ReplicatedStorage:WaitForChild("Util")
local Sound = require(util.Sound)
local Flare = require(util.Flare)
require(game.ReplicatedStorage.Effect)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local _ = game.ReplicatedStorage.Assets.Models.LightSword
local _WorldOrigin = workspace._WorldOrigin
local _ = workspace.Map

local function ScaleParticle(state, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, state.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	state.Drag *= p
	return NumberSequence.new(numberSequenceKeypoints)
end

local function func(data)
	local cFrame = data.CFrame
	local length = data.Length or 80
	local scale = data.Scale or 1
	local weak = data.Weak

	if (workspace.CurrentCamera.CFrame.p - cFrame.p).Magnitude > 600 then
		return
	end

	local part = Instance.new("Part")
	part.Size = createVector(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.Material = "Neon"
	part.Color = data.Fire and Color3.new(1, 0.5, 0) or Color3.new(1, 1, 1)

	if data.Color then
		part.Color = data.Color
	end

	part.Transparency = 0.1
	part.CFrame = cFrame
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.MeshType = "Sphere"
	specialMesh.Scale = createVector(25, 25, 25) * scale * (weak and 0.5 or 1)

	if data.Projectile then
		specialMesh.Scale = createVector(8.75, 8.75, 125) * scale * (weak and 0.5 or 1)
	end

	part.Parent = _WorldOrigin

	if data.Projectile then
		TweenService:Create(part, TweenInfo.new(0.11, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Transparency = 1
		}):Play()
		TweenService:Create(specialMesh, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
			Scale = specialMesh.Scale * 0.4,
			Offset = Vector3.new(0, 0, -length)
		}):Play()
	else
		TweenService:Create(part, TweenInfo.new(0.22), {
			Transparency = 1
		}):Play()
		TweenService:Create(specialMesh, TweenInfo.new(0.22, Enum.EasingStyle.Exponential), {
			Scale = Vector3.new(0, 0, length),
			Offset = Vector3.new(0, 0, -length / 2)
		}):Play()
	end

	if not weak then
		for i = 1, data.Projectile and 3 or 4 do
			local cFrame2 = cFrame * CFrame.new(0, 0, -length / 7 * i) * CFrame.Angles(1.5707963267948966, 0, 0)
			local clone = game.ReplicatedStorage.Assets.Models.ThinnerWind:Clone()
			clone.Size = createVector(4, 2, 4)
			clone.Transparency = 0.2

			if data.Fire then
				clone.Color = Color3.new(1, 0.2, 0)
				clone.Transparency = 0
			end

			clone.CFrame = cFrame2
			clone.Parent = _WorldOrigin
			local tween = TweenService:Create(clone, TweenInfo.new(0.55 - i * 0.08, Enum.EasingStyle.Circular), {
				Transparency = 1,
				Size = createVector(10, 0.15, 10) * scale * 7 * (1 - i / 6 * 0.9),
				CFrame = cFrame2 * CFrame.new(0, scale * 25, 0)
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
		end
	end

	if data.Flares then
		local cframe = CFrame.new(cFrame.p)
		local v = data.Flares == 1 and 16 or 33
		local v2 = data.Flares == 1 and 2 or 4

		for _ = 1, data.Flares == 1 and 7 or 14 do
			Flare.new({
				Size = math.random(1, 2) == 1 and createVector(1, 1, 1) * v2 or Vector3.new(1, 1, math.random(12, 16)) * v2,
				CFrame = cframe,
				Distance = v * (1 + math.random() * 0.5),
				DistanceOffset = 1,
				TweenInfo = TweenInfo.new(0.2 + math.random() * 0.1),
				Transparency = 0.2,
				Color = data.Color or data.Fire and Color3.new(1, 0.2, 0) or Color3.new(1, 1, 1)
			}):EmitRadial({
				Size = createVector(0.05, 0.05, 0.05),
				SpreadAngle = Vector2.new(360, 360)
			})
		end
	end

	if data.FinalFlares then
		wait(length / 1300)
		local cFrame2 = cFrame * CFrame.new(0, 0, -length)

		for _ = 1, 14 do
			Flare.new({
				Size = math.random(1, 2) == 1 and createVector(7, 7, 7) or Vector3.new(1, 1, math.random(12, 16)) * 7,
				CFrame = cFrame2,
				Distance = 50 * (1 + math.random() * 0.5),
				DistanceOffset = 1,
				TweenInfo = TweenInfo.new(0.2 + math.random() * 0.1),
				Transparency = 0.2,
				Color = data.Fire and Color3.new(1, 0.2, 0) or Color3.new(1, 1, 1)
			}):EmitRadial({
				Size = createVector(0.05, 0.05, 0.05),
				SpreadAngle = Vector2.new(360, 360)
			})
		end

		local part2 = Instance.new("Part")
		part2.Size = createVector(1, 1, 1)
		part2.Anchored = true
		part2.CanCollide = false
		part2.Material = "Neon"
		part2.Color = data.Fire and Color3.new(1, 0.5, 0) or Color3.new(1, 1, 1)
		part2.Transparency = 0.1
		part2.CFrame = cFrame2
		local specialMesh2 = Instance.new("SpecialMesh", part2)
		specialMesh2.MeshType = "Sphere"
		specialMesh2.Scale = Vector3.new()
		part2.Parent = _WorldOrigin
		TweenService:Create(part2, TweenInfo.new(0.16), {
			Transparency = 1
		}):Play()
		TweenService:Create(specialMesh2, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
			Scale = createVector(66, 66, 66)
		}):Play()

		for _ = 1, 4 do
			local clone = game.ReplicatedStorage.Assets.Models.CrescentSlash:Clone()
			clone.Size = createVector(30, 0.3, 30) * (0.75 + math.random() * 0.5)
			clone.Color = data.Fire and Color3.new(1, 0.2, 0) or Color3.new(1, 1, 1)
			clone.CFrame = cFrame2 * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
			clone.Parent = workspace._WorldOrigin
			local tween = TweenService:Create(clone, TweenInfo.new(0.3 + math.random() * 0.5, Enum.EasingStyle.Quint), {
				Size = clone.Size * 3.5,
				Transparency = 1
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
			local v3 = clone
			task.spawn(function()
				local v4 = (4 + math.random() * 4) * math.sign(math.random() - 0.5)
				local v5 = task.wait()

				while v3 and v3.Parent and v3:IsDescendantOf(workspace) do
					v3.CFrame *= CFrame.Angles(0, v5 * 3.141592653589793 * v4, 0)
					v5 = task.wait()
				end
			end)
		end

		local v2 = Sound:Play("NewDarkness2", cFrame2)
		wait(0.4)
		Sound:FadeOut(v2, 0.2)
	end

	wait(1)
	part:Destroy()
end

return func