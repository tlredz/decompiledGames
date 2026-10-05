local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame
	local targetCFrame = data.TargetCFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	local color = Color3.fromRGB(0, 130, 255)
	local v = math.min(250, (cFrame.p - targetCFrame.p).magnitude)
	local cframe = CFrame.new(cFrame.p, targetCFrame.p)
	local v2 = cframe * CFrame.new(0, 0, -v)

	local function lerp(object, p, p2)
		return object:lerp(p, p2)
	end

	local length = data.Length
	local width = data.Width
	local v3 = math.max(0.6666 - (masterClock:GetTime() - data.Timestamp), 0)
	spawn(function()
		local clone = game.ReplicatedStorage.Assets.Models.DragonHeadBig:Clone()
		clone.Size *= 4

		for _, trail in pairs(clone:GetChildren()) do
			if not trail:IsA("Trail") then
				continue
			end

			trail.Color = ColorSequence.new(color)
			trail.Lifetime *= 1.25
			trail.Texture = ""
			trail.Transparency = NumberSequence.new(0.6, 1)
		end

		clone.Color = color
		clone.CFrame = cframe
		clone.Parent = workspace._WorldOrigin
		local lastTime = tick()

		while tick() - lastTime < v3 do
			local v4 = math.min(1, (tick() - lastTime) / v3)
			tick()
			local lerped = cframe:Lerp(v2, v4)
			clone.CFrame = CFrame.new(lerped.p, lerped.p - (clone.CFrame.p - lerped.p).unit)
			RunService.RenderStepped:Wait()
		end

		local tween = TweenService:Create(clone, TweenInfo.new(0.4), {
			Size = createVector(0.05, 0.05, 0.05),
			Transparency = 1
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
	end)

	for i = 0, 3.141592653589793, 1.0471975511965976 do
		local v4 = i
		spawn(function()
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.Color = Color3.new(0, 0.5, 1)
			part.Size = createVector(1, 1, 1)
			part.Material = "Neon"
			part.CFrame = cframe * CFrame.Angles(0, -1.5707963267948966, 0)
			part.Transparency = 0.5
			local specialMesh = Instance.new("SpecialMesh", part)
			specialMesh.MeshType = Enum.MeshType.Cylinder
			specialMesh.Scale = Vector3.new(0, width + 3, width + 3)
			part.Parent = workspace._WorldOrigin
			local tweenInfo = TweenInfo.new(v3, Enum.EasingStyle.Linear)
			TweenService:Create(specialMesh, tweenInfo, {
				Scale = Vector3.new(length, 0, 0),
				Offset = Vector3.new(-length / 2, 0, 0)
			}):Play()
			TweenService:Create(part, tweenInfo, {
				Transparency = 1
			}):Play()
			local clone = game.ReplicatedStorage.Assets.Models.DragonHeadBig:Clone()

			for i2, trail in pairs(clone:GetChildren()) do
				if not trail:IsA("Trail") then
					continue
				end

				trail.Color = ColorSequence.new(color)
				trail.Lifetime *= 1.25
				trail.Texture = ""
				trail.WidthScale = NumberSequence.new(0.4, 0)
				trail.Transparency = NumberSequence.new(0.6, 1)
			end

			clone.Color = color
			clone.CFrame = cframe
			clone.Parent = workspace._WorldOrigin
			local lastTime = tick()

			while tick() - lastTime < v3 do
				local v5 = math.min(1, (tick() - lastTime) / v3)
				local now = tick()
				local v6 = cframe:Lerp(v2, v5) * CFrame.new(
					math.sin(v4 + now * 5 * 5) * width / 1.6,
					math.cos(v4 + now * 5 * 5) * width / 1.6,
					0
				)
				clone.CFrame = CFrame.new(v6.p, v6.p - (clone.CFrame.p - v6.p).unit)
				RunService.RenderStepped:Wait()
			end

			local tween = TweenService:Create(clone, TweenInfo.new(0.4), {
				Size = createVector(0.05, 0.05, 0.05),
				Transparency = 1
			})
			tween.Completed:Connect(function()
				clone:Destroy()
				part:Destroy()
			end)
			tween:Play()
		end)
		wait(0.06)
	end
end