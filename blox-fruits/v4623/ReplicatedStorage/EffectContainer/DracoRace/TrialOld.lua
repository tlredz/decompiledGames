local createVector = vector.create
require(game.ReplicatedStorage.Util.CameraShaker.Main)
require(game.ReplicatedStorage.Util.CameraShaker)
local Util = require(game.ReplicatedStorage.Util)
local v = { Color3.fromRGB(221, 255, 0), Color3.fromRGB(255, 131, 249), Color3.fromRGB(0, 38, 255) }
local v2 = { Color3.fromRGB(221, 255, 0), Color3.fromRGB(255, 99, 102), Color3.fromRGB(0, 157, 255) }

local function colorifySequence(color, data)
	local R = data.R
	local G = data.G
	local B = data.B
	local colorSequenceKeypoints = {}

	for _, keypoint in ipairs(color.Keypoints) do
		local value = keypoint.Value
		local R2 = value.R
		local G2 = value.G
		local B2 = value.B
		local v3 = R2 * 0.3 + G2 * 0.59 + B2 * 0.11
		local color2 = Color3.new(R * v3, G * v3, B * v3)
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(keypoint.Time, color2))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

local maid = Util.Maid.new()
local v3 = {}
local v4 = false
return function(data)
	if data.Mode == "Explode" then
		local _ = data.Time
		local v5 = data.Time + 10 - workspace:GetServerTimeNow()
		local center = workspace.Map.DracoTrial.Center
		local meshescaveprops_Cylinder042 = workspace.Map.DracoTrial:FindFirstChild("TrialDoor", true).Door1["Meshes/caveprops_Cylinder.042"]
		local v6 = v3[8] or Instance.new("Part", workspace._WorldOrigin)
		v6.Anchored = true
		v6.Material = Enum.Material.Neon
		v6.CanCollide = false
		v6.CanQuery = false
		v6.Color = Color3.fromRGB(170, 79, 0)
		v6.CFrame = center.CFrame * CFrame.new(0, -10, 0)
		v6.Size = createVector(2000, 10, 2000)
		v3[8] = v6
		local TweenService = game:GetService("TweenService")
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
		local tween = TweenService:Create(colorCorrectionEffect, TweenInfo.new(2), {
			TintColor = Color3.fromRGB(255, 186, 146)
		})
		tween.Completed:Connect(function()
			local tween2 = TweenService:Create(colorCorrectionEffect, TweenInfo.new(12), {
				Contrast = 1
			})
			tween2.Completed:Connect(function()
				local tween3 = TweenService:Create(colorCorrectionEffect, TweenInfo.new(2), {
					TintColor = Color3.fromRGB(255, 255, 255),
					Contrast = 0
				})
				tween3.Completed:Connect(function()
					colorCorrectionEffect:Destroy()
				end)
				tween3:Play()
			end)
			tween2:Play()
		end)
		tween:Play()
		local bloomEffect = Instance.new("BloomEffect", game.Lighting)
		bloomEffect.Intensity = 0
		local tween2 = TweenService:Create(bloomEffect, TweenInfo.new(2), {
			Intensity = 1,
			Threshold = 0.2
		})
		tween2.Completed:Connect(function()
			task.wait(14)
			local tween3 = TweenService:Create(bloomEffect, TweenInfo.new(2), {
				Threshold = 2
			})
			tween3.Completed:Connect(function()
				bloomEffect:Destroy()
			end)
			tween3:Play()
		end)
		tween2:Play()
		local v7 = Util.Sound:Play("VolcanoAmbience", center.CFrame.Position, 300)
		task.delay(v5 - 1, function()
			local TweenService2 = game:GetService("TweenService")
			local tween3 = TweenService2:Create(v6, TweenInfo.new(3, Enum.EasingStyle.Sine), {
				CFrame = center.CFrame + createVector(0, 1, 0) * (meshescaveprops_Cylinder042.Position.Y - 13 - center.Position.Y - 5)
			})
			tween3:Play()
			tween3.Completed:Wait()
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(v6, TweenInfo.new(6, Enum.EasingStyle.Linear), {
				CFrame = center.CFrame * CFrame.new(0, -30, 0)
			}):Play()
		end)
		v6.Touched:Connect(function(otherPart)
			if otherPart.Parent == game.Players.LocalPlayer.Character and not v4 then
				game.Players.LocalPlayer.Character:BreakJoints()
			end
		end)
		local colorCorrectionEffect2 = Instance.new("ColorCorrectionEffect", game.Lighting)
		colorCorrectionEffect2.TintColor = Color3.fromRGB(255, 94, 0)
		colorCorrectionEffect2.Enabled = false
		local total = 0
		local total2 = 0.25

		while total < 18 and v3[8] do
			total += task.wait()

			if total2 < total then
				total2 += 0.25

				if total > 7 and total < 14 then
					Util.CameraShaker:ShakeOnce(6, 8, 0.05, 4)
				else
					if total > 12 then
						total2 += 0.15
					end

					Util.CameraShaker:ShakeOnce(3, 4, 0.1, 2)
				end
			end

			colorCorrectionEffect2.Enabled = workspace.CurrentCamera.CFrame.Position.Y < v6.CFrame.Position.Y
		end

		colorCorrectionEffect2.Enabled = false
		Util.Sound:FadeOut(v7, 0.6)
	elseif data.Mode == "CreateRelics" then
		local dracoTrial = workspace:WaitForChild("Map"):WaitForChild("DracoTrial")
		v4 = false

		for _, part in pairs(dracoTrial:GetDescendants()) do
			if not (part:IsA("BasePart") and part.Material == Enum.Material.Neon and part.Color == Color3.fromRGB(
				170,
				79,
				0
			)) then
				continue
			end

			maid:GiveTask(part.Touched:Connect(function(otherPart)
				local playerFromCharacter = game.Players:GetPlayerFromCharacter(otherPart.Parent)

				if not playerFromCharacter then
					return
				end

				local _ = playerFromCharacter == game.Players.LocalPlayer
			end))
		end

		for k, color in pairs(v) do
			local clone = script.Relic:Clone()

			for _, surfaceAppearance in pairs(clone:GetDescendants()) do
				if surfaceAppearance:IsA("SurfaceAppearance") then
					surfaceAppearance.Color = color
				end
			end

			local clone2 = script.BrazierFires:FindFirstChild("Relic" .. k):Clone()
			clone2.Parent = clone.PrimaryPart
			clone2.CFrame = CFrame.new(0, -0.7, 0)
			clone2.Name = "RelicFire"

			for _, emitter in pairs(clone2:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					Util.ScaleParticle2(emitter, 0.125, true)
				end
			end

			clone:ScaleTo(2)
			clone.Parent = workspace._WorldOrigin
			clone:PivotTo(data.CFrames[k] * CFrame.new(0, 2, 0))
			v3[k] = clone
		end
	elseif data.Mode == "CollectRelic" then
		local v5 = v3[data.Model]
		local primaryPart = v5.PrimaryPart
		local attachment = Instance.new("Attachment", primaryPart)

		for _, part in pairs(v5:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Anchored = false

			if part == primaryPart then
				continue
			end

			local weldConstraint = Instance.new("WeldConstraint", primaryPart)
			weldConstraint.Part0 = primaryPart
			weldConstraint.Part1 = part
		end

		local alignPosition = Instance.new("AlignPosition", primaryPart)
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPosition.Attachment0 = attachment
		alignPosition.MaxForce = 5000000000
		alignPosition.Responsiveness = 15
		local alignOrientation = Instance.new("AlignOrientation", primaryPart)
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOrientation.Attachment0 = attachment
		local humanoidRootPart = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

		if not v3[7] then
			v3[7] = script.BrazierFires.Forcefield:Clone()
			v3[7].Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
		end

		for _, child in pairs(v3[7]:GetChildren()) do
			child.Color = colorifySequence(script.BrazierFires.Forcefield[child.Name].Color, v2[data.Model])
		end

		local lastTime = os.clock()
		local position = humanoidRootPart.Position

		while v3[data.Model] do
			alignPosition.Position = (CFrame.new(humanoidRootPart.Position, primaryPart.Position) * CFrame.new(0, 0, -5)).Position
			alignOrientation.CFrame = CFrame.new(primaryPart.Position, humanoidRootPart.Position) * CFrame.Angles(
				math.min(primaryPart.AssemblyLinearVelocity.Magnitude / 30, 1) * -0.5235987755982988,
				0,
				0
			)

			if (position - humanoidRootPart.Position).Magnitude > 0.5 then
				lastTime = os.clock()
				position = humanoidRootPart.Position
			end

			local v6 = math.floor((os.clock() - lastTime) * 3 / 2)

			for _, child in pairs(v3[7]:GetChildren()) do
				child.Enabled = tonumber(child.Name:match("%d$")) <= v6
			end

			v4 = v6 >= 3
			task.wait()
		end

		if v3[7] then
			for _, child in pairs(v3[7]:GetChildren()) do
				child.Enabled = false
			end
		end
	elseif data.Mode == "DeliverRelic" then
		local folder = v3[data.Model]

		if not folder then
			return
		end

		v4 = false
		local cylinder032 = folder:WaitForChild("Cylinder.032")
		v3[data.Model] = false
		v3[data.Model + 3] = folder
		cylinder032.AlignPosition.Position = data.CFrame.Position
		cylinder032.AlignOrientation.CFrame = data.CFrame
		task.spawn(function()
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 2
			numberValue.Changed:Connect(function()
				folder:ScaleTo(numberValue.Value)
			end)
			local TweenService = game:GetService("TweenService")
			local tween = TweenService:Create(numberValue, TweenInfo.new(1), {
				Value = 0.5
			})
			tween.Completed:Once(function()
				numberValue:Destroy()
			end)
			tween:Play()
		end)

		while v3[data.Model + 3] and not (cylinder032.AssemblyLinearVelocity.Magnitude + cylinder032.AssemblyAngularVelocity.Magnitude <= 0.4 and (cylinder032.Position - data.CFrame.Position).Magnitude <= 0.2) do
			task.wait()
		end

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local clone = script.BrazierFires:FindFirstChild("Relic" .. data.Model):Clone()
		clone.Parent = cylinder032
		clone.WorldCFrame = data.BrazierCFrame

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.TimeScale = 0
			local TweenService = game:GetService("TweenService")
			TweenService:Create(emitter, TweenInfo.new(1), {
				TimeScale = 1
			}):Play()
		end
	elseif data.Mode == "ClearRelics" then
		maid:DoCleaning()

		for _, v5 in pairs(v3) do
			if v5 then
				v5:Destroy()
			end
		end

		v3 = {}
	end
end