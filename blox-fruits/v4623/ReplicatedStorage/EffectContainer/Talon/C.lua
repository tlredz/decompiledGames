local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local _ = game.ReplicatedStorage.Util
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	if data.Mode == 1 then
		local root = data.Root

		if not (root and root.Parent) then
			return
		end

		local v = sound:Play("FireFistBeamSlow", root)

		for i = 1, 6 do
			local clone = script.FireBrush:Clone()
			clone.CFrame = CFrame.new(root.Position)
			clone.Parent = _WorldOrigin
			local v2 = i
			task.spawn(function()
				local cframe = CFrame.Angles(0, v2 / 6 * 3.141592653589793 * 2, 0)
				local v4 = 60 * (0.8 + math.random() * 0.4)
				local lastTime = tick()

				while tick() - lastTime < 0.66 do
					local v5 = (tick() - lastTime) / 0.66
					clone.CFrame = CFrame.new(root.Position) * cframe * CFrame.Angles(0, 6.283185307179586 * v5, 0) * CFrame.new(
						0,
						v4 * 0.5 * 1 * (1 - v5),
						v4 * (1 - v5)
					)
					task.wait()
				end

				clone.Fire.Enabled = false
				task.wait(1)
				clone:Destroy()
			end)
		end

		task.wait(0.5)
		sound:FadeOut(v, 0.4)
	elseif data.Mode == 2 then
		if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude < 170 then
			Effect.new("ShakeCam"):replicate({
				24,
				24,
				0.1,
				2.75,
				createVector(1, 1, 1),
				createVector(1, 1, 2)
			})
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Parent = game.Lighting
			local tween = TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.1), {
				Brightness = 0.5,
				Contrast = 0.5,
				Saturation = 0.5,
				TintColor = Color3.fromRGB(170, 85, 0)
			})
			tween.Completed:Connect(function()
				task.wait(0.6)
				local tween2 = TweenService:Create(colorCorrectionEffect, TweenInfo.new(1.2), {
					Brightness = 0,
					Contrast = 0,
					Saturation = 0,
					TintColor = Color3.new(1, 1, 1)
				})
				tween2.Completed:Connect(function()
					colorCorrectionEffect:Destroy()
				end)
				tween2:Play()
			end)
			tween:Play()
		end

		sound:Play("ShortExplosion3Slow", cFrame)
		local clone = script.FireBoom:Clone()
		clone.CFrame = cFrame
		clone.ParticleEmitter.Size = NumberSequence.new(4, 22)
		clone.Parent = _WorldOrigin
		clone.ParticleEmitter:Emit(33)
		local clone2 = script.FireBoom2:Clone()
		clone2.CFrame = cFrame
		clone2.ParticleEmitter.Size = NumberSequence.new(8, 28)
		clone2.Parent = _WorldOrigin
		clone2.ParticleEmitter:Emit(27)

		for i = 1, 8 do
			local clone3 = script.FireBrush2:Clone()
			clone3.CFrame = cFrame
			clone3.Parent = _WorldOrigin
			local v = i
			task.spawn(function()
				local cframe = CFrame.Angles(0, v / 6 * 3.141592653589793 * 2, 0)
				local v3 = 80 * (0.8 + math.random() * 0.4)
				local v4 = 0.4 + math.random() * 0.15
				local lastTime = tick()

				while tick() - lastTime < v4 do
					local v5 = (tick() - lastTime) / v4
					clone3.CFrame = cFrame * cframe * CFrame.Angles(0, 6.283185307179586 * v5, 0) * CFrame.new(
						0,
						v3 * 1 * v5,
						v3 * (0.4 + v5 * 0.6)
					)
					task.wait()
				end

				clone3.Fire.Enabled = false
				task.wait(1)
				clone3:Destroy()
			end)
		end

		local clone3 = script.FlashBoom:Clone()
		clone3:SetPrimaryPartCFrame(cFrame * CFrame.new(0, 15, 0))
		clone3.Parent = workspace._WorldOrigin

		for _, child in pairs(clone3:GetChildren()) do
			local tweenInfo = TweenInfo.new(
				0.3 + child.Size.Magnitude * 0.08,
				child.Name == "Color1" and Enum.EasingStyle.Quad or Enum.EasingStyle.Exponential
			)
			local v2 = {
				Size = child.Size * createVector(30, 0.6, 30) * 1.1,
				Transparency = 1,
				CFrame = child.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, -12, 0),
				Color = 0
			}
			local color

			if child.Name == "Color2" then
				color = child.Color:Lerp(Color3.new(1, 0, 0), 0.25 + math.random() * 0.25) or nil
			end

			v2.Color = color
			TweenService:Create(child, tweenInfo, v2):Play()
		end

		for _ = 1, 22 do
			local color = math.random() > 0.25 and Color3.fromRGB(218, 133, 65) or Color3.fromRGB(170, 85, 0)
			local v = math.random() < 0.2 and 1 or 0.125 + math.random() * 0.1
			local v2 = 20 + math.random() * 30 + (1 - v) * 15
			local part = Instance.new("Part")
			part.CastShadow = false
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
				(math.random() - 0.5) * 1.8,
				(math.random() - 0.5) * 1.8,
				(math.random() - 0.5) * 1.8
			)
			part.Size = createVector(1, 1, 1)
			part.Color = color
			part.Transparency = 0
			part.Material = "Neon"
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = "Sphere"
			specialMesh.Scale = Vector3.new(v, v, 1) * v2 * 0.75
			specialMesh.Parent = part
			part.Parent = _WorldOrigin
			local tweenInfo = TweenInfo.new(0.2 + math.random() * 0.4 + v / 5)
			TweenService:Create(part, tweenInfo, {
				Color = part.Color:Lerp(Color3.new(1, 0, 0), math.random() * 0.4)
			}):Play()
			local tween = TweenService:Create(specialMesh, tweenInfo, {
				Scale = Vector3.new(),
				Offset = Vector3.new(0, 0, v2 * (0.75 + math.random() * 1.75))
			})
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
		end

		task.wait(2)
		clone:Destroy()
		clone2:Destroy()
		clone3:Destroy()
	end
end