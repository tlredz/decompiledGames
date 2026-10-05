local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))

local function applyColorShiftHSV(color: Color3, p: number, p2: number, p3: number)
	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local HSV, v5, v6 = Color3.fromRGB(v2, v3, v4):ToHSV()
	local v7 = (HSV + p) % 1
	local v8 = math.clamp(v5 * p2, 0, 1)
	local v9 = math.clamp(v6 * p3, 0, 1)
	return Color3.fromHSV(v7, v8, v9 * v)
end

local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local assets = FX:WaitForChild("Lightning2").X.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
Util.ResizeModel(assets.Phase2.SpinSlash, 0.6)
Util.ResizeModel(assets.Phase2.Impact, 0.5)
Util.ResizeModel(assets.Phase2.Spark, 0.5)
Util.ResizeModel(assets.Phase2.GroundCrack, 0.5)
Util.ResizeModel(assets.Phase2.Before, 0.55)
Util.ResizeModel(assets.Phase2.Thunder, 0.75)

local function multiplyNumberSequence(size, sizeMult)
	local numberSequenceKeypoints = {}

	for _, keypoint in size.Keypoints do
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * sizeMult))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local LightningBoltShafi = require(game.ReplicatedStorage.Util.LightningBoltShafi)

local function ShafiBolt(player, ...)
	local v = LightningBoltShafi.new(...)
	v.CurveSize0 = 0
	v.CurveSize1 = 0
	v.MinRadius = 0
	v.MaxRadius = 28
	v.Frequency = 3
	v.AnimationSpeed = 5
	local maxThicknessMultiplier = math.random(1, 5)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 8
	v.PulseLength = 1000000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = player and Util.WrapColor3Constructor(Color3.new(0.411765, 0.952941, 1), player, "LightningFruitVFXColor") or Color3.new(
		0.411765,
		0.952941,
		1
	)
	v.ColorOffsetSpeed = 3
	pcall(function()
		if player.Character and player.Character.PrimaryPart then
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart:GetAttribute("LightningSkin") and humanoidRootPart:GetAttribute("LightningSkin") == "Purple" and math.random(
				1,
				4
			) == 1 then
				v.Color = Color3.new(0, 0, 0)
			end
		end
	end)
	return v
end

local function ShafiBolt0(player, ...)
	local v = LightningBoltShafi.new(...)
	v.MinRadius = 0
	v.MaxRadius = 5
	v.Frequency = 0.35
	v.AnimationSpeed = 10
	local maxThicknessMultiplier = math.random(1, 2)
	v.MinThicknessMultiplier = 0.9
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = math.random(5, 7)
	v.PulseLength = 10000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = player and Util.WrapColor3Constructor(Color3.new(0.368627, 0.988235, 1), player, "LightningFruitVFXColor") or Color3.new(
		0.368627,
		0.988235,
		1
	)
	v.ColorOffsetSpeed = 5
	return v
end

return function(data)
	local player = data.player

	if (currentCamera.CFrame.p - data.Origin).Magnitude > 1500 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")

		if data.isForPainStrikes == true then
			Util.AdjustObjectDescendantsColors(folder, function(_, p)
				return applyColorShiftHSV(p, 0.5, 1, 1)
			end)
		end

		local root = data.Root
		local parent = root.Parent
		local cFrame = root.CFrame
		local clone = assets.Phase0A.HoldAura:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")

		if data.isForPainStrikes == true then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				return applyColorShiftHSV(p, 0.5, 1, 1)
			end)
		end

		local v = Util.Sound:Play("BF_Thunder_X_Held_01", root)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local now = tick()

		while true do
			if now - tick() <= 0 then
				now = tick() + 0.25
				task.spawn(function()
					local position = parent.RightHand.Position
					local clone2 = FX:WaitForChild("Lightning2").X.Part:Clone()
					clone2.CFrame = CFrame.new(position)
					Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")

					if data.isForPainStrikes == true then
						Util.AdjustObjectDescendantsColors(clone2, function(_, p)
							return applyColorShiftHSV(p, 0.5, 1, 1)
						end)
					end

					clone2.Attach1.WorldPosition = position + Vector3.new(
						math.random(-5, 5) / 2,
						math.random(-5, 5),
						math.random(-5, 5) / 3
					)
					local shafiBolt0 = ShafiBolt0(player, clone2.Attach0, clone2.Attach1, 10, 0.15, folder)
					shafiBolt0.CurveSize0 = 0
					shafiBolt0.CurveSize1 = 0
					task.wait(0.25 + math.random() * 0.25)
					shafiBolt0:Destroy()
				end)
				local clone2 = assets.Phase0A.SpinSlash:Clone()
				clone2:PivotTo(CFrame.new(cFrame.Position) * CFrame.new(0, -1, 0))
				Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")

				if data.isForPainStrikes == true then
					Util.AdjustObjectDescendantsColors(clone2, function(_, p)
						return applyColorShiftHSV(p, 0.5, 1, 1)
					end)
				end

				clone2:ScaleTo(1)
				local primaryPart = clone2.PrimaryPart
				local v2 = clone2.PrimaryPart.CFrame * CFrame.new(0, 0.5, 0) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				)
				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Responsiveness = 10
				primaryPart.AlignPosition.Position = primaryPart.Position + createVector(0, 0, 0)
				angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15) * 2, 0)
				clone2:PivotTo(v2)
				primaryPart.AlignPosition.Enabled = true
				angularVelocity.Enabled = true
				clone2:GetScale()
				local folder2 = clone2
				task.spawn(function()
					task.spawn(function()
						TweenService:Create(
							angularVelocity,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
									math.random(-5, 5) / 2,
									math.random(5, 15),
									math.random(-5, 5) / 2
								)
							}
						):Play()
					end)
					task.wait(0.035 * math.random() + 0.05)

					for i, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.5 / (i / 2.5)), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v4 = effect
							task.delay(1, function()
								v4:Destroy()
							end)
						elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					task.wait(1)
					angularVelocity.Enabled = false
				end)
				task.spawn(function()
					local scale = clone2:GetScale()
					local v5 = scale * 1.5

					for i = scale * 100, v5 * 100, 5 do
						clone2:ScaleTo(i / 100)
						task.wait(0.005)
					end
				end)
			end

			clone.CFrame = parent.RightHand.CFrame
			task.wait()

			if holding:IsDescendantOf(workspace) and holding.Value then
				continue
			end

			if v then
				Util.Sound:FadeOut(v, 0.2)
			end

			Util.Debris:AddItem(folder, 10)
			clone:Destroy()
			return
		end
	elseif stage == 2 then
		local startCFrame = data.StartCFrame
		local cloudProxy = data.CloudProxy
		local folder = Instance.new("Folder")
		folder.Name = data.CloudId
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")

		if data.isForPainStrikes == true then
			Util.AdjustObjectDescendantsColors(folder, function(_, p)
				return applyColorShiftHSV(p, 0.5, 1, 1)
			end)
		end

		local cFrame = CFrame.new(startCFrame.Position) * CFrame.new(0, data.Height, 0)
		local clone = assets.Phase1.Explosion:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")

		if data.isForPainStrikes == true then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				return applyColorShiftHSV(p, 0.5, 1, 1)
			end)
		end

		local flag = false
		task.spawn(function()
			repeat
				task.wait()
			until not cloudProxy:IsDescendantOf(workspace)

			flag = true
		end)

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		end

		task.wait(0.15)
		task.spawn(function()
			for _ = 1, 5 do
				task.spawn(function()
					local v2 = math.random(10, 50) / 100
					task.wait(v2)
					local clone2 = assets.Phase2.TrailModel:Clone()
					clone2:PivotTo(cFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
						0,
						25 + math.random(-25, 50),
						0
					))
					Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")

					if data.isForPainStrikes == true then
						Util.AdjustObjectDescendantsColors(clone2, function(_, p)
							return applyColorShiftHSV(p, 0.5, 1, 1)
						end)
					end

					clone2:ScaleTo(math.random(20, 25))
					local start = clone2.Start
					local trail = clone2.Trail
					local cframe = CFrame.new(0, 0, -math.random(175, 215))
					TweenService:Create(trail.Weld, TweenInfo.new(0.5), {
						C1 = cframe
					}):Play()
					trail.Trail1.Lifetime = math.random(150, 200) / 1000
					local angularVelocity = start.AngularVelocity
					start.Anchored = false
					start.AlignPosition.Position = start.Position
					angularVelocity.AngularVelocity = Vector3.new(math.random(-1, 1) / 5, 50, math.random(-1, 1) / 5)
					TweenService:Create(angularVelocity, TweenInfo.new(0.5), {
						AngularVelocity = Vector3.new(
							math.random(-1, 1) / 5,
							math.random(5, 15),
							math.random(-1, 1) / 5
						)
					}):Play()

					for _, effect in pairs(clone2:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
							continue
						end

						local v3 = effect
						task.spawn(function()
							v3.Enabled = false
							task.wait(math.random(5, 15) / 100)
							v3.Enabled = true
						end)
						local v4 = effect
						task.spawn(function()
							repeat
								task.wait()
							until flag == true

							v4.Enabled = false
						end)
					end

					repeat
						task.wait()
					until flag == true

					angularVelocity.Enabled = false
					task.wait(1)
					clone2:Destroy()
				end)
			end
		end)
		task.spawn(function()
			local clone2 = assets.Phase2.SpinSlash:Clone()
			clone2:PivotTo(cFrame * CFrame.new(0, 30 + math.random(-15, 15), 0))
			Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")

			if data.isForPainStrikes == true then
				Util.AdjustObjectDescendantsColors(clone2, function(_, p)
					return applyColorShiftHSV(p, 0.5, 1, 1)
				end)
			end

			local model = clone2.Model

			for i = 1, 10 do
				local v2 = i * 2 + 15
				local clone3 = model:Clone()
				clone3:ScaleTo(v2)
				local primaryPart = clone3.PrimaryPart
				local v3 = clone2.PrimaryPart.CFrame * CFrame.new(0, v2, 0) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				)
				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.Position + Vector3.new(
					math.random(-10, 10) / 10,
					0,
					math.random(-10, 10) / 10
				)
				angularVelocity.AngularVelocity = Vector3.new(0, math.random(5, 10), 0)
				clone3:PivotTo(v3)
				Util.SetParentOverrideWithColor(clone3, clone2, player, "LightningFruitVFXColor")

				if data.isForPainStrikes == true then
					Util.AdjustObjectDescendantsColors(clone3, function(_, p)
						return applyColorShiftHSV(p, 0.5, 1, 1)
					end)
				end

				clone3:GetScale()
				local folder2 = clone3
				task.spawn(function()
					task.spawn(function()
						local Y = folder2.Slash.Position.Y
						TweenService:Create(
							angularVelocity,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
									math.random(-5, 5) / 10,
									math.random(3, 5) / 5,
									math.random(-5, 5) / 10
								)
							}
						):Play()
					end)

					repeat
						task.wait()
					until flag == true

					task.wait(0.25 * math.random())

					for i2, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.25 + math.random() * 0.15), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v5 = effect
							task.delay(1, function()
								v5:Destroy()
							end)
						elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					task.wait(1)
					angularVelocity.Enabled = false
				end)
			end

			model:Destroy()
			task.spawn(function()
				local scale = clone2:GetScale()
				local v2 = scale * 1.5

				for i = scale * 100, v2 * 100, 5 do
					clone2:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)
		local clone2 = assets.Phase1.CloudModel:Clone()
		clone2:PivotTo(CFrame.new(startCFrame.Position) * CFrame.new(0, data.Height, 0))
		Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")

		if data.isForPainStrikes == true then
			Util.AdjustObjectDescendantsColors(clone2, function(_, p)
				return applyColorShiftHSV(p, 0.5, 1, 1)
			end)
		end

		Util.Sound:Play("BF_Thunder_X_CloudsAppear_01", clone2.PrimaryPart.Position)
		clone2:ScaleTo(data.CloudScale or 0.55)

		if data.Glide then
			task.spawn(function()
				while cloudProxy:IsDescendantOf(workspace) and clone2.Parent do
					local position = cloudProxy:GetAttribute("Position")

					if typeof(position) == "Vector3" then
						clone2:PivotTo(CFrame.new(position))
					end

					task.wait()
				end
			end)
		end

		for _, descendant in pairs(clone2:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				local v2 = descendant
				task.spawn(function()
					v2:Emit(1)
					v2.Enabled = true
					local v3 = v2.Lifetime.Min * 0.75

					repeat
						task.wait()
					until flag == true

					v2.Enabled = false
				end)
			elseif descendant:IsA("MeshPart") then
				local v2 = TweenService:Create(
					descendant,
					TweenInfo.new(
						0.5 + math.random() * 0.5,
						Enum.EasingStyle.Linear,
						Enum.EasingDirection.Out,
						5,
						true,
						0
					),
					{
						Size = Vector3.new(descendant.Size.X * 1.5, descendant.Size.Y * 1.5, descendant.Size.Z * 1.5)
					}
				):Play()
				local v3 = descendant
				task.spawn(function()
					task.wait(5)
					v2 = TweenService:Create(
						v3,
						TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
				end)
			end
		end
	elseif stage == 3 then
		local startCFrame = data.StartCFrame

		if not _WorldOrigin:FindFirstChild(data.CloudId) then
			print("did not find", data.CloudId)
			return
		end

		local folder = Instance.new("Folder")

		if player then
			Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		else
			folder.Parent = _WorldOrigin

			if data.isForPainStrikes == true then
				Util.AdjustObjectDescendantsColors(_WorldOrigin, function(_, p)
					return applyColorShiftHSV(p, 0.5, 1, 1)
				end)
			end
		end

		Util.Debris:AddItem(folder, 5)
		local flag = false

		if player and player.Character and player.Character:IsDescendantOf(workspace) then
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				flag = humanoidRootPart:GetAttribute("LightningSkin") and humanoidRootPart:GetAttribute("LightningSkin") == "Purple"
			end
		end

		task.spawn(function()
			local position = startCFrame.Position
			local result = data.Result
			local v = math.random(1, 2)
			local _ = result.Position

			if v == 1 and result then
				task.spawn(function()
					local clone = assets.Phase2.Before:Clone()
					clone.CFrame = CFrame.new(result.Position) * CFrame.Angles(0, 0, -1.5707963267948966)

					if player then
						Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
					else
						clone.Parent = folder
					end

					if data.isForPainStrikes == true then
						Util.AdjustObjectDescendantsColors(clone, function(_, p)
							return applyColorShiftHSV(p, 0.5, 1, 1)
						end)
					end

					for _, emitter in pairs(clone:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v2 = emitter
						task.spawn(function()
							for i = 1, 3 do
								if data.SizeMult then
									v2.Size = multiplyNumberSequence(v2.Size, data.SizeMult)
								end

								v2:Emit(v2:GetAttribute("EmitCount"))
								task.wait(0.15)
							end
						end)
					end

					task.wait(0.2)
					local clone2 = FX:WaitForChild("Lightning2").X.Part:Clone()
					clone2.CFrame = CFrame.new(position) * CFrame.new(0, 300, 0)

					if player then
						Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
					else
						clone2.Parent = folder
					end

					if data.isForPainStrikes == true then
						Util.AdjustObjectDescendantsColors(clone2, function(_, p)
							return applyColorShiftHSV(p, 0.5, 1, 1)
						end)
					end

					clone2.Attach1.WorldPosition = result.Position
					local shafiBolt = ShafiBolt(player, clone2.Attach0, clone2.Attach1, 25, 3, folder)
					task.spawn(function()
						local clone3 = assets.Phase2.Impact:Clone()
						clone3.CFrame = CFrame.new(position) * CFrame.new(0, 300, 0)

						if player then
							Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")
						else
							clone3.Parent = folder
						end

						if data.isForPainStrikes == true then
							Util.AdjustObjectDescendantsColors(clone3, function(_, p)
								return applyColorShiftHSV(p, 0.5, 1, 1)
							end)
						end

						DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

						for _, emitter in pairs(clone3:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if data.SizeMult then
								emitter.Size = multiplyNumberSequence(emitter.Size, data.SizeMult)
							end

							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end

						task.wait(0.1)
						local clone4 = assets.Phase2.Spark:Clone()
						clone4.CFrame = CFrame.new(position)

						if player then
							Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
						else
							clone4.Parent = folder
						end

						if data.isForPainStrikes == true then
							Util.AdjustObjectDescendantsColors(clone4, function(_, p)
								return applyColorShiftHSV(p, 0.5, 1, 1)
							end)
						end

						Util.Sound:Play("BF_Thunder_X_SkyThunder_LightningStrike_0" .. math.random(1, 3), position)
						DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown

						for _, emitter in pairs(clone4:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if data.SizeMult then
								emitter.Size = multiplyNumberSequence(emitter.Size, data.SizeMult)
							end

							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end

						local clone5 = assets.Phase2.GroundCrack:Clone()
						clone5.CFrame = AlignCFrame(CFrame.new(result.Position), result.Normal) + result.Normal * 0.01

						if player then
							Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")
						else
							clone5.Parent = folder
						end

						if data.isForPainStrikes == true then
							Util.AdjustObjectDescendantsColors(clone5, function(_, p)
								return applyColorShiftHSV(p, 0.5, 1, 1)
							end)
						end

						DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown

						for _, emitter in pairs(clone5:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if data.SizeMult then
								emitter.Size = multiplyNumberSequence(emitter.Size, data.SizeMult)
							end

							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end)
					task.wait(0.1 * math.random() + 0.15)
					shafiBolt:Destroy()
				end)
				return
			end

			local v2 = #assets.Phase2.ThunderBolts:GetChildren()
			math.random(1, v2)
			local clone = assets.Phase2.Before:Clone()
			clone.CFrame = CFrame.new(result.Position) * CFrame.Angles(0, 0, -1.5707963267948966)

			if player then
				Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
			else
				clone.Parent = folder
			end

			if data.isForPainStrikes == true then
				Util.AdjustObjectDescendantsColors(clone, function(_, p)
					return applyColorShiftHSV(p, 0.5, 1, 1)
				end)
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v3 = emitter
				task.spawn(function()
					if data.SizeMult then
						v3.Size = multiplyNumberSequence(v3.Size, data.SizeMult)
					end

					for i = 1, 3 do
						v3:Emit(v3:GetAttribute("EmitCount"))
						task.wait(0.15)
					end
				end)
			end

			task.wait(0.2)
			local clone2 = assets.Phase2.Thunder:Clone()
			clone2.CFrame = CFrame.new(result.Position)

			if player then
				Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
			else
				clone2.Parent = folder
			end

			if data.isForPainStrikes == true then
				Util.AdjustObjectDescendantsColors(clone2, function(_, p)
					return applyColorShiftHSV(p, 0.5, 1, 1)
				end)
			end

			if flag and math.random(1, 3) == 1 then
				for _, emitter in pairs(clone2.Attachment:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Color = ColorSequence.new(Color3.new(0, 0, 0))
					end
				end
			end

			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
			local v3 = clone2.Attachment["Particle_" .. math.random(1, #clone2.Attachment:GetChildren())]
			v3:Emit(v3:GetAttribute("EmitCount"))
			task.spawn(function()
				local clone3 = assets.Phase2.Impact:Clone()
				clone3.CFrame = CFrame.new(position) * CFrame.new(0, 300, 0)

				if player then
					Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")
				else
					clone3.Parent = folder
				end

				if data.isForPainStrikes == true then
					Util.AdjustObjectDescendantsColors(clone3, function(_, p)
						return applyColorShiftHSV(p, 0.5, 1, 1)
					end)
				end

				DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone3:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					if data.SizeMult then
						emitter.Size = multiplyNumberSequence(emitter.Size, data.SizeMult)
					end

					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end

				task.wait(0.1)
				local clone4 = assets.Phase2.Spark:Clone()
				clone4.CFrame = CFrame.new(position)

				if player then
					Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
				else
					clone4.Parent = folder
				end

				if data.isForPainStrikes == true then
					Util.AdjustObjectDescendantsColors(clone4, function(_, p)
						return applyColorShiftHSV(p, 0.5, 1, 1)
					end)
				end

				DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone4:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					if data.SizeMult then
						emitter.Size = multiplyNumberSequence(emitter.Size, data.SizeMult)
					end

					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end

				local clone5 = assets.Phase2.GroundCrack:Clone()
				clone5.CFrame = AlignCFrame(CFrame.new(result.Position), result.Normal) + result.Normal * 0.01

				if player then
					Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")
				else
					clone5.Parent = folder
				end

				if data.isForPainStrikes == true then
					Util.AdjustObjectDescendantsColors(clone5, function(_, p)
						return applyColorShiftHSV(p, 0.5, 1, 1)
					end)
				end

				DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone5:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					if data.SizeMult then
						emitter.Size = multiplyNumberSequence(emitter.Size, data.SizeMult)
					end

					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end)
		end)
	elseif stage == 4 then
		if not _WorldOrigin:FindFirstChild(data.CloudId) then
			return
		end

		local cloudProxy = data.CloudProxy

		if not (cloudProxy and cloudProxy:IsDescendantOf(workspace)) then
			return
		end

		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")

		if data.isForPainStrikes == true then
			Util.AdjustObjectDescendantsColors(folder, function(_, p)
				return applyColorShiftHSV(p, 0.5, 1, 1)
			end)
		end

		Util.Debris:AddItem(folder, 5)
		local clone = assets.Phase1.Explosion:Clone()
		Util.ResizeModel(clone, 0.5)
		clone.CFrame = CFrame.new(cloudProxy:GetAttribute("Position")) * CFrame.new(0, 30, 0)
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")

		if data.isForPainStrikes == true then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				return applyColorShiftHSV(p, 0.5, 1, 1)
			end)
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end
	end
end