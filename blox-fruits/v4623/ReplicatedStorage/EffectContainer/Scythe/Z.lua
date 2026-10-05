local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local _ = game.ReplicatedStorage.Util
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local root = data.Root

	if (root.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
		return
	end

	if data.Mode == 1 then
		local v = root.CFrame * CFrame.new(0, 0, -5)
		local clone = script.ScytheRings:Clone()
		clone:SetPrimaryPartCFrame(v * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
			0,
			3.141592653589793 * math.random() * 2,
			0
		))
		clone.Parent = _WorldOrigin

		for _, child in pairs(clone:GetChildren()) do
			if math.random() < 0.5 then
				child:Destroy()
			else
				local v2 = math.random() < 0.5 and -1 or 1
				child.Color = child.Color:Lerp(Color3.new(1, 0, 0), math.random() * 0.1)
				child.Size = child.Size.unit * 5
				local tween = TweenService:Create(child, TweenInfo.new(0.06 + math.random() * 0.05), {
					Size = child.Size * 4 * createVector(1, 0.75, 1),
					CFrame = child.CFrame * CFrame.Angles(0, 3.141592653589793 * v2, 0)
				})
				local v3 = child
				tween.Completed:Connect(function()
					local size = v3.Size
					local lastTime = tick()

					while tick() - lastTime < 0.15 do
						local v5 = task.wait()
						local v6 = tick() - lastTime
						local v7 = math.cos(v6 * 10) * 0.2 + 1
						local v8 = math.sin(v6 * 30) * 0.3 + 1.2
						v3.Size = size * Vector3.new(v8, v7, v8)
						v3.CFrame *= CFrame.Angles(0, -v5 * 15 * v2, 0)
					end

					local tween2 = TweenService:Create(
						v3,
						TweenInfo.new(0.06 + math.random() * 0.12, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
						{
							Size = v3.Size * createVector(0, 0, 0),
							Color = v3.Color:Lerp(Color3.new(1, 0, 0), 0.2),
							CFrame = v3.CFrame * CFrame.new(0, math.random(1, 5), 0) * CFrame.Angles(
								0,
								3.141592653589793 * v2,
								0
							)
						}
					)
					tween2.Completed:Connect(function()
						v3:Destroy()
					end)
					tween2:Play()
				end)
				tween:Play()
			end
		end

		task.delay(2, function()
			clone:Destroy()
		end)
	elseif data.Mode == 2 then
		local cFrame = data.CFrame * CFrame.Angles(0, 0, -0.7853981633974483)
		Util.Sound:Play("TechFieldManip3", cFrame)
		Util.Sound:Play("PawCannonShoot2", cFrame)
		Util.Sound:Play("Ope.RadioKnife.Sheath", cFrame)
		local clone = script.HallowSlash:Clone()
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		clone.Attachment.Mid.Size = NumberSequence.new(33, 0)
		clone.Attachment.Mid:Emit(4)
		clone.Attachment.MidDark.Size = NumberSequence.new(43, 0)
		clone.Attachment.MidDark:Emit(3)
		task.wait(0.3)
		clone.Attachment.Mid2:Emit(3)
		task.wait(0.15)
		Util.Sound:Play("NewDarkness2", cFrame)
		Util.Sound:Play("NewDarkness3", cFrame)
		Util.Sound:Play("Ope.Levitate.Slice", cFrame)

		if data.Victims[game.Players.LocalPlayer.Character] or (workspace.CurrentCamera.CFrame.p - cFrame.p).Magnitude < 80 then
			Effect.new("ShakeCam"):replicate({
				12,
				22,
				0.1,
				2,
				createVector(1, 1, 1),
				createVector(1, 1, 1)
			})
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Parent = game.Lighting
			local tween = TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.1), {
				Brightness = 0.25,
				Contrast = 0.25,
				Saturation = 0.25,
				TintColor = Color3.fromRGB(170, 85, 0)
			})
			tween.Completed:Connect(function()
				task.wait(0.1)
				local tween2 = TweenService:Create(colorCorrectionEffect, TweenInfo.new(1.5), {
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

		clone.Attachment.Left.Size = NumberSequence.new(10, 0)
		clone.Attachment.Left:Emit(10)
		clone.Attachment.Right.Size = NumberSequence.new(10, 0)
		clone.Attachment.Right:Emit(10)
		clone.Attachment.Sparks:Emit(20)
		clone.Attachment.SparksDark:Emit(20)
		clone.Attachment.BackgroundDark.Size = NumberSequence.new(0, 30)
		clone.Attachment.BackgroundDark:Emit(20)
		clone.Attachment.Background.Size = NumberSequence.new(10, 20)
		clone.Attachment.Background:Emit(20)
		clone.Attachment.Slashes.Size = NumberSequence.new(1, 30)

		for _ = 1, 6 do
			clone.Attachment.Slashes:Emit(1)
			task.wait()
		end

		task.wait(3)
		clone:Destroy()
	elseif data.Mode == 999 then
		local cFrame = data.CFrame
		local reference = data.Reference
		local clone = script.ScytheRings2:Clone()
		clone:SetPrimaryPartCFrame(cFrame)
		clone.Parent = _WorldOrigin

		for i, child in pairs(clone:GetChildren()) do
			child.Color = child.Color:Lerp(Color3.new(1, 0, 0), math.random() * 0.1)
			child.Size = child.Size.unit * 5 * 2
			local tween = TweenService:Create(child, TweenInfo.new(0.06 + math.random() * 0.05), {
				Size = child.Size * 4 * createVector(1, 0.75, 1),
				CFrame = child.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			})
			local v = child
			local v2 = i
			tween.Completed:Connect(function()
				local size = v.Size
				local size2 = v.Size
				tick()

				local function boom()
					for i2 = 1, 3 do
						local color = math.random() > 0.75 and Color3.fromRGB() or Color3.fromRGB(213, 115, 61)
						local v3 = math.random() < 0.4 and 1.25 or 0.125 + math.random() * 0.075
						local v4 = 1 + math.random() * 5 * 0.2 + (1 - v3) * 15
						local part = Instance.new("Part")
						part.CastShadow = false
						part.Anchored = true
						part.CanCollide = false
						part.CFrame = cFrame * CFrame.new(0, 0, -size2.Z * 0.66) * CFrame.Angles(
							-1.5707963267948966,
							0.7853981633974483,
							0
						) * CFrame.Angles(
							(math.random() - 0.5) * 0.2,
							(math.random() - 0.5) * 0.2,
							(math.random() - 0.5) * 0.2
						) * CFrame.Angles(0, 3.141592653589793 * (math.random() < 0.5 and 0 or 1), 0)
						part.Size = createVector(1, 1, 1)
						part.Color = color
						part.Transparency = 0
						part.Material = "Neon"
						local specialMesh = Instance.new("SpecialMesh")
						specialMesh.MeshType = "Sphere"
						specialMesh.Scale = Vector3.new(v3, v3, 1) * v4 * 0.8
						specialMesh.Parent = part
						part.Parent = _WorldOrigin
						local tweenInfo = TweenInfo.new(0.1 + math.random() * 0.1 + v3 / 5)
						TweenService:Create(part, tweenInfo, {
							Color = part.Color:Lerp(Color3.new(1, 0, 0), 0.2)
						}):Play()
						local tween2 = TweenService:Create(specialMesh, tweenInfo, {
							Scale = Vector3.new(),
							Offset = Vector3.new(0, 0, v4 * 2.5 * math.random())
						})
						tween2.Completed:Connect(function()
							part:Destroy()
						end)
						tween2:Play()
					end
				end

				local lastTime = tick()
				local v3 = nil
				local v4 = nil

				while tick() - lastTime < 0.1 and reference:IsDescendantOf(workspace) do
					local v5 = task.wait()
					local v6 = size * 2
					local v7 = 1 * (tick() - lastTime) / 0.1
					size2 = size2:Lerp(v6, v7)
					local v8 = tick() - lastTime
					v4 = math.cos(v8 * 20) * 0.1 + 1
					v3 = math.sin(v8 * 60) * 0.15 + 1.2
					v.Size = size2 * Vector3.new(v3, v4, v3)
					v.CFrame *= CFrame.Angles(0, -v5 * 30 * 1, 0)
				end

				v.Size = size * 2 * Vector3.new(v3, v4, v3)

				if v2 == 1 then
					for i2 = 1, 25 do
						local color = math.random() > 0.75 and Color3.fromRGB() or Color3.fromRGB(213, 115, 61)
						local v5 = math.random() < 0.3 and 1 or 0.125 + math.random() * 0.075
						local v6 = 7.5 + math.random() * 5 * 1.5 + (1 - v5) * 15
						local part = Instance.new("Part")
						part.CastShadow = false
						part.Anchored = true
						part.CanCollide = false
						part.CFrame = cFrame * CFrame.new(0, 0, -size.Z * 0.55 * 2) * CFrame.Angles(
							-1.5707963267948966,
							0.7853981633974483,
							0
						) * CFrame.Angles(
							(math.random() - 0.5) * 0.125,
							(math.random() - 0.5) * 0.125,
							(math.random() - 0.5) * 0.125
						) * CFrame.Angles(0, 3.141592653589793 * (math.random() < 0.5 and 0 or 1), 0)
						part.Size = createVector(1, 1, 1)
						part.Color = color
						part.Transparency = 0
						part.Material = "Neon"
						local specialMesh = Instance.new("SpecialMesh")
						specialMesh.MeshType = "Sphere"
						specialMesh.Scale = Vector3.new(v5, v5, 1) * v6
						specialMesh.Parent = part
						part.Parent = _WorldOrigin
						local tweenInfo = TweenInfo.new(0.15 + math.random() * 0.4 + v5 / 5)
						TweenService:Create(part, tweenInfo, {
							Color = part.Color:Lerp(Color3.new(1, 0, 0), 0.2)
						}):Play()
						local tween2 = TweenService:Create(specialMesh, tweenInfo, {
							Scale = Vector3.new(),
							Offset = Vector3.new(0, 0, v6 * math.random() * 4)
						})
						tween2.Completed:Connect(function()
							part:Destroy()
						end)
						tween2:Play()
					end
				end

				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(0.07 + math.random() * 0.09, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
					{
						Size = v.Size * createVector(0, 0, 0),
						Color = v.Color:Lerp(Color3.new(1, 0, 0), 0.2),
						CFrame = v.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					}
				)
				tween2.Completed:Connect(function()
					v:Destroy()
				end)
				tween2:Play()
			end)
			tween:Play()
		end

		task.delay(2, function()
			clone:Destroy()
		end)
	end
end