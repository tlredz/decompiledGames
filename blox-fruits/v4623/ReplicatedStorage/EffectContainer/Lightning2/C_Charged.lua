local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local assets = FX:WaitForChild("Lightning2").C_Charged.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

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

local function ShafiBolt1(player, ...)
	local v = LightningBoltShafi.new(...)
	v.MinRadius = 0
	v.MaxRadius = 15
	v.Frequency = 0.5
	v.AnimationSpeed = 6
	local maxThicknessMultiplier = math.random(1, 2)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = math.random(5, 7)
	v.PulseLength = 10000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Util.WrapColor3Constructor(Color3.new(0.529412, 0.960784, 1), player, "LightningFruitVFXColor")
	v.ColorOffsetSpeed = 5
	return v
end

local function ShafiBolt2(player, ...)
	local v = LightningBoltShafi.new(...)
	v.MinRadius = 0
	v.MaxRadius = 25
	v.Frequency = 3
	v.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(1, 2)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = math.random(5, 7) * 2
	v.PulseLength = 10000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Util.WrapColor3Constructor(Color3.new(0.454902, 0.992157, 1), player, "LightningFruitVFXColor")
	v.ColorOffsetSpeed = 5
	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RockCrater(p, parent, data, p2, _)
	task.spawn(function()
		local rockType = data.RockType
		local radius = data.Radius
		local size = data.Size
		local duration = data.Duration
		local amount = data.Amount
		local offset = data.Offset
		local v = AlignCFrame(CFrame.new(p.Position), p.Normal) + p.Normal * 0.01
		local v2 = {}

		for _ = 1, amount do
			local clone = rockType:Clone()
			clone.Parent = parent
			task.delay(7, function()
				clone:Destroy()
			end)
			table.insert(v2, clone)
		end

		task.spawn(function()
			task.wait(duration * 2)

			for _, v3 in pairs(v2) do
				v3:Destroy()
			end

			v2 = nil
		end)
		local v3 = 360 / #v2
		local total = 0

		for _, v4 in pairs(v2) do
			total += v3
			v4.CFrame = v * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)

			if math.random(1, 7) < 2 then
				v4.CFrame = CFrame.new(v4.Position, p.Position) * CFrame.new(0, 0, offset)
			end

			v4.CFrame = CFrame.new(v4.Position, p.Position) * CFrame.new(
				0,
				math.random(-5, 5) / 3,
				math.random(-offset, offset * 2)
			)
			local ray = Ray.new(v4.Position + createVector(0, 1, 0), createVector(-0, -100, -0))
			local part, v5 = workspace:FindPartOnRayWithIgnoreList(ray, p2.FilterDescendantsInstances)

			if part then
				local v6 = (v4.Position - p.Position).Magnitude / 175
				local v7 = size * math.random(20, 40) / 10
				local v8 = size * math.random(15, 30) / 10
				local v9 = size * math.random(30, 50) / 10
				v4.Size = Vector3.new(v7 * v6, v8 * v6, v9 * v6)
				v4.Position = v5 + Vector3.new(0, -v4.Size.Y * 0.5, 0)
				v4.CFrame = CFrame.new(v4.Position, p.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 10,
					math.random(-offset / 2, offset / 2)
				)
				v4.CFrame = CFrame.new(
					v4.Position,
					v.Position + Vector3.new(0, math.random(-55, -45) / 100 + v4.Size.Y / 250, 0)
				) * CFrame.Angles(math.rad(-(75 * v6 / 1.25)), 0, 0) * CFrame.Angles(
					0,
					0,
					(math.rad((math.random(-5, 5))))
				)
				v4.Material = part.Material
				v4.Color = part.Color
			else
				v2[v4] = nil
				v4:Destroy()
			end

			TweenService:Create(v4, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {
				Position = v4.Position + Vector3.new(0, v4.Size.Y * math.random(3, 5) / 8, 0)
			}):Play()
			local v6 = v4
			local v7 = v4
			task.spawn(function()
				wait(duration + math.random(10, 50) / 100)
				local tween = TweenService:Create(
					v6,
					TweenInfo.new(
						0.5,
						Enum.EasingStyle.Back,
						Enum.EasingDirection.In,
						0,
						false,
						math.random(10, 35) / 100
					),
					{
						Position = v6.Position + Vector3.new(
							math.random(-1, 1),
							-v6.Size.Y * math.random(20, 25) / 10,
							math.random(-1, 1)
						)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v6:Destroy()

				if v2 then
					v2[v6] = nil
				end
			end)
		end
	end)
end

return function(data)
	local player = data.Player

	if (currentCamera.CFrame.p - data.Origin).Magnitude > 1000 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local holding = data.Holding

		if not (holding:IsDescendantOf(workspace) and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "LightningC_" .. data.Player.Name
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		local root = data.Root
		local clone = assets.Phase0.HoldAura:Clone()
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
		clone.Anchored = false
		clone.Weld.Part1 = root

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local clone2 = assets.Phase0.Dragon:Clone()
		clone2:PivotTo(root.CFrame * CFrame.Angles(0, 3.141592653589793, 0))
		Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		clone.Weld.Enabled = false
		clone.Anchored = true
		Util.Debris:AddItem(folder, 15)
	elseif stage == 2 then
		local startCFrame = data.StartCFrame
		local root = data.Root
		local proxy = data.Proxy

		if not proxy then
			return
		end

		local v = root:GetAttribute("LightningSkin") and root:GetAttribute("LightningSkin") == "Purple"
		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		Util.Debris:AddItem(folder, 20)
		local clone = assets.Phase0.StartImpact:Clone()
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local cframe = CFrame.new(startCFrame.Position)
		local duration = data.Duration
		task.spawn(function()
			for _ = 1, 5 do
				task.spawn(function()
					local v2 = math.random(10, 50) / 100
					task.wait(v2)
					local clone2 = assets.Phase1.TrailModel:Clone()
					clone2:PivotTo(cframe * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0))
					Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
					clone2:ScaleTo(math.random(20, 25) / 2.25)
					local start = clone2.Start
					local trail = clone2.Trail
					local cframe2 = CFrame.new(0, 0, -math.random(70, 100))
					TweenService:Create(trail.Weld, TweenInfo.new(0.5), {
						C1 = cframe2
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
						task.delay(duration - v2, function()
							v4.Enabled = false
						end)
					end

					task.wait(duration / 2 - v2)
					angularVelocity.Enabled = false
					task.wait(duration)
					clone2:Destroy()
				end)
			end
		end)
		task.spawn(function()
			local clone2 = assets.Phase1.SpinSlash:Clone()
			clone2:PivotTo(cframe * CFrame.new(0, 0, 0))
			Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
			local model = clone2.Model

			for i = 1, 10 do
				local clone3 = model:Clone()
				clone3:ScaleTo(i * 1.2 + 6.666666666666667)
				local primaryPart = clone3.PrimaryPart
				local v3 = clone2.PrimaryPart.CFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.Position
				angularVelocity.AngularVelocity = Vector3.new(0, math.random(5, 10), 0)
				clone3:PivotTo(v3)
				Util.SetParentOverrideWithColor(clone3, clone2, player, "LightningFruitVFXColor")
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
					task.wait(duration)

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
		clone2:PivotTo(CFrame.new(cframe.Position) * CFrame.new(0, 0, 0))
		Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
		clone2:ScaleTo(0.8)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				v2:Emit(1)
				v2.Enabled = true
				local v3 = v2.Lifetime.Min * 0.25
				task.wait(duration / 1.25 - v3)
				v2.Enabled = false
			end)
		end

		task.wait(duration / 2 - 0.5)
		local clone3 = assets.Phase2.BeamStart:Clone()
		clone3.CFrame = cframe * CFrame.new(0, -50, 0)
		Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")

		if v then
			clone3.Attachment.Particle_3.Color = ColorSequence.new(Color3.fromRGB(127, 50, 195))
		end

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.wait(0.3)
		local cFrame2 = cframe * CFrame.new(0, -35, 0)
		local clone4 = assets.Phase3.Beam:Clone()
		clone4.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")

		if v then
			clone4.PartB.Attach_1.Beam1.Color = ColorSequence.new(Color3.fromRGB(127, 50, 195))
			clone4.PartB.Attach_1["Beam1.2"].Color = ColorSequence.new(Color3.fromRGB(127, 50, 195))
		end

		clone4.PartB.Anchored = true
		clone4.PartB.CFrame = cFrame2
		clone4.Attach_1.Beam.Enabled = false
		TweenService:Create(clone4.PartB, TweenInfo.new(0.25), {
			CFrame = clone4.PartB.CFrame * CFrame.new(0, -15, 0)
		}):Play()
		local cFrame = clone4.PartB.CFrame
		local partB = clone4.PartB
		partB.CFrame = proxy.Value
		local mousePos = data.MousePos
		local v3 = true
		local clonesByClone = {}
		local v4 = nil

		while true do
			local position = partB.Position
			local value = mousePos.Value
			local vector2 = Vector3.new(value.X, position.Y, value.Z)
			local v5 = vector2 - position
			local magnitude = v5.Magnitude
			local unit = v5.Unit
			local v6 = -50 + math.random(-25, 0)
			local v7 = 100 + math.random(-25, 100)
			local v8 = unit * 100
			local vector3 = Vector3.new(0, v6, 0)
			local unit2 = Vector3.new(v5.X, 0, v5.Z).Unit

			if unit2.Magnitude < 0.01 then
				break
			end

			local lookVector = (CFrame.lookAt(createVector(0, 0, 0), unit2) * CFrame.Angles(
				0,
				math.rad(v3 and -90 or 90),
				0
			)).LookVector
			local v9 = lookVector * v7

			if magnitude <= 250 then
				v9 = lookVector * v7 / 2

				if magnitude < 150 then
					v9 = lookVector * v7 / 4
				end
			end

			local v10 = position + v8 + v9 + vector3
			local cframe2 = CFrame.new(v10, v10 + unit)
			partB.CFrame = CFrame.new(partB.Position, partB.Position + cframe2.LookVector) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			local clone5 = clone4.Attach_0:Clone()
			clone5.Position = createVector(0, 0, 0)
			Util.SetParentOverrideWithColor(clone5, clone4, player, "LightningFruitVFXColor")
			clone5.WorldCFrame = cFrame
			local clone6 = clone4.Attach_1:Clone()
			Util.SetParentOverrideWithColor(clone6, clone4, player, "LightningFruitVFXColor")
			clone6.Beam.Attachment0 = clone5
			clone6.WorldCFrame = cFrame
			clone6.Beam.Enabled = true
			TweenService:Create(clone6, TweenInfo.new(0.075, Enum.EasingStyle.Linear), {
				WorldCFrame = cframe2
			}):Play()
			local clone7 = assets.Phase3.BeamSpark:Clone()
			clone7.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone7, folder, player, "LightningFruitVFXColor")
			v3 = not v3

			for _, emitter in pairs(clone7:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount") or 10)
				emitter.Enabled = true
			end

			Util.Sound:Play("BF_Thunder_C_Skybeam_ZigZag_0" .. tostring(math.random(1, 2)), clone7.Position)
			clonesByClone[clone7] = clone7
			local tween = TweenService:Create(partB, TweenInfo.new(0.075, Enum.EasingStyle.Linear), {
				CFrame = cframe2 * CFrame.Angles(1.5707963267948966, 0, 0)
			})
			tween:Play()
			tween.Completed:Wait()
			local cframe3 = CFrame.new(partB.Position, vector2)
			local raycastResult = workspace:Raycast(cframe3.Position, cframe3.LookVector * 101, raycastParams)

			if raycastResult then
				print(raycastResult.Instance.Parent)
				v4 = raycastResult
			end

			local raycastResult2 = workspace:Raycast(
				partB.Position + createVector(0, 1, 0),
				createVector(-0, -75, -0),
				raycastParams
			)

			if raycastResult2 then
				print(raycastResult2.Instance.Parent)
				v4 = raycastResult2
			end

			if not (proxy and proxy:IsDescendantOf(workspace)) then
				break
			end

			if proxy:GetAttribute("Exploding") then
				partB.CFrame = CFrame.new(proxy:GetAttribute("Exploding"))
				break
			else
				cFrame = cframe2
			end
		end

		local exploding = proxy and proxy:GetAttribute("Exploding") or partB.Position
		task.spawn(function()
			task.spawn(function()
				task.wait(0.05)
				local screenColorLC2 = assets.Phase2.ScreenColorLC2
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Name = "ScreenColorLC2"
				Util.SetParentOverrideWithColor(colorCorrectionEffect, game.Lighting, player, "LightningFruitVFXColor")
				TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.05), {
					Brightness = screenColorLC2.Brightness,
					Contrast = screenColorLC2.Contrast,
					Saturation = screenColorLC2.Saturation,
					TintColor = screenColorLC2.TintColor
				}):Play()
				task.wait(0.1)
				TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.1), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LightningFruitVFXColor"
					),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				}):Play()
				task.delay(1, function()
					colorCorrectionEffect:Destroy()
				end)
			end)
			task.wait(0.05)
			TweenService:Create(clone4.PartB.Attach_0, TweenInfo.new(0.1), {
				Position = createVector(0, 0, 0)
			}):Play()

			for _, effect in pairs(clone4:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				elseif effect:IsA("Beam") then
					TweenService:Create(effect, TweenInfo.new(0.1), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end
			end

			for _, folder2 in pairs(clonesByClone) do
				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end

			clonesByClone = nil
		end)
		task.spawn(function()
			local clone5 = assets.Phase3.SpinSlash:Clone()
			clone5:PivotTo(CFrame.new(exploding) * CFrame.new(0, 5, 0))
			Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")
			local model = clone5.Model

			for i = 3, 5 do
				local v5 = i * 0.5 + 4.444444444444445
				local clone6 = model:Clone()
				clone6:ScaleTo(v5)
				local primaryPart = clone6.PrimaryPart
				local v6 = clone5.PrimaryPart.CFrame * CFrame.new(0, v5 / 2, 0) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				)
				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Responsiveness = 10
				primaryPart.AlignPosition.Position = primaryPart.Position + Vector3.new(
					math.random(-10, 10) / 10,
					i * i / 2 * 15,
					math.random(-10, 10) / 10
				)
				angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15) * 2, 0)
				clone6:PivotTo(v6)
				Util.SetParentOverrideWithColor(clone6, clone5, player, "LightningFruitVFXColor")
				primaryPart.AlignPosition.Enabled = true
				angularVelocity.Enabled = true
				clone6:GetScale()
				local folder2 = clone6
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

					for i2, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.5 / (i2 / 2.5)), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v8 = effect
							task.delay(1, function()
								v8:Destroy()
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
				local scale = clone5:GetScale()
				local v5 = scale * 1.5

				for i = scale * 100, v5 * 100, 5 do
					clone5:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)
		local screenColorLC = assets.Phase2.ScreenColorLC
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "ScreenColorLC"
		Util.SetParentOverrideWithColor(colorCorrectionEffect, game.Lighting, player, "LightningFruitVFXColor")
		TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.35), {
			Brightness = screenColorLC.Brightness,
			Contrast = screenColorLC.Contrast,
			Saturation = screenColorLC.Saturation,
			TintColor = screenColorLC.TintColor
		}):Play()
		task.spawn(function()
			local clone5 = assets.Phase3.DragonAura:Clone()
			clone5.CFrame = CFrame.new(exploding) * CFrame.new(0, 25, 0)
			Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")

			for _, emitter in pairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				emitter.Enabled = true
			end

			task.wait(0.7)

			for _, emitter in pairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		task.spawn(function()
			local clone5 = assets.Phase2.Aura:Clone()
			clone5.PrimaryPart.CFrame = CFrame.new(exploding)
			Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")

			for _, emitter in pairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				emitter.Enabled = true
			end

			local scale = clone5:GetScale()
			local v5 = scale * 3.25

			for i = scale * 100, v5 * 100, 5 do
				clone5:ScaleTo(i / 100)
				task.wait(0.005)
			end

			task.wait(0.25)

			for _, emitter in pairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		task.spawn(function()
			local bloomEffect = Instance.new("BloomEffect")
			Util.SetParentOverrideWithColor(bloomEffect, game.Lighting, player, "LightningFruitVFXColor")
			bloomEffect.Size += 10
			TweenService:Create(bloomEffect, TweenInfo.new(0.05), {
				Size = 54,
				Intensity = 0
			}):Play()
			task.delay(0.05, function()
				bloomEffect:Destroy()
			end)
		end)
		TweenService:Create(colorCorrectionEffect, TweenInfo.new(1), {
			TintColor = Util.WrapColor3ConstructorForTintColor(
				Color3.fromRGB(255, 255, 255),
				player,
				"LightningFruitVFXColor"
			),
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		}):Play()
		task.delay(1, function()
			colorCorrectionEffect:Destroy()
		end)
		local clone5 = assets.Phase3.BeamExplosion:Clone()
		clone5.CFrame = CFrame.new(exploding) * CFrame.new(0, 25, 0)
		Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")

		if v then
			clone5.Attachment4.Particle_3.Color = ColorSequence.new(Color3.fromRGB(127, 50, 195))
		end

		if (workspace.CurrentCamera.CFrame.p - exploding).Magnitude < 275 then
			Util.CameraShaker:ShakeOnce(12, 8, 0.4, 0.9)
			local Effect = require(game.ReplicatedStorage.Effect)
			Effect.new("ColorCorrection"):replicate({
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(134, 162, 255),
					player,
					"LightningFruitVFXColor"
				),
				Brightness = 0.4,
				Saturation = 0.1,
				Contrast = 0.15,
				FadeIn = 0,
				FadeOut = 0.2,
				Lifetime = 0.15
			})
		end

		if v4 and v4.Instance then
			print("dude i hit the ground me thinkies")
			Util.Sound:Play("BF_Thunder_C_Skybeam_Explosion_WithDebris_01", exploding)
		else
			Util.Sound:Play("BF_Thunder_C_Skybeam_Explosion_NoDebris_01", exploding)
		end

		for _, emitter in pairs(clone5:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v5 = emitter
			task.spawn(function()
				if v5:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v5:GetAttribute("EmitDelay"))
				end

				v5:Emit(v5:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown

		if v4 then
			task.spawn(function()
				task.wait(0.15)
				local clone6 = assets.Phase3.GroundCrack:Clone()
				clone6.CFrame = CFrame.new(exploding)
				Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")

				for _, emitter in pairs(clone6:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v5 = emitter
					task.spawn(function()
						if v5:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v5:GetAttribute("EmitDelay"))
						end

						v5:Emit(v5:GetAttribute("EmitCount"))
					end)
				end

				DeleteImpactAfterDuration(clone6) -- equivalent call inferred; original call site unknown
			end)
			local v5 = {
				Radius = 90,
				Size = 15,
				Duration = 1.5,
				Amount = 20,
				RockType = assets.CraterRock,
				Offset = 15
			}
			task.spawn(function()
				RockCrater({
					Position = exploding,
					Normal = v4.Normal,
					Instance = v4.Instance
				}, folder, v5, raycastParams) -- equivalent call inferred; original call site unknown
			end)
			task.spawn(function()
				for _ = 1, 15 do
					task.spawn(function()
						local clone6 = assets.Rock:Clone()
						clone6.CFrame = CFrame.new(exploding) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
						Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
						clone6.CFrame = clone6.CFrame * CFrame.new(0, 0, -50) * CFrame.Angles(
							math.rad(90 + math.random(-50, -0)),
							0,
							0
						)
						clone6.Size = Vector3.new(
							math.random(2, 5) * 3.5,
							math.random(1, 2) * 3.5,
							math.random(2, 5) * 3.5
						)
						clone6.Anchored = false
						clone6.Material = v4.Instance.Material
						clone6.Color = v4.Instance.Color
						rocks:ApplyCollision(clone6, nil, true)
						clone6.AngularVelocity.AngularVelocity = Vector3.new(
							math.random(-10, 10),
							math.random(-10, 10),
							math.random(-10, 10)
						)
						clone6.AngularVelocity.Enabled = true
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(7000000, 7000000, 7000000)
						bodyVelocity.P = 5000
						Util.SetParentOverrideWithColor(bodyVelocity, clone6, player, "LightningFruitVFXColor")
						local v6 = math.random(50, 150) * 1.25
						task.delay(math.random(5, 20) / 50, function()
							bodyVelocity:Destroy()
						end)
						bodyVelocity.Velocity = clone6.CFrame.LookVector * v6
						task.delay(0.25, function()
							clone6.CanCollide = true
						end)
						task.wait(math.random() * 0.5)
						clone6.AngularVelocity.Enabled = false
						task.wait(math.random() * 0.5 + 1.5)
						TweenService:Create(clone6, TweenInfo.new(0.5 + math.random() * 0.25), {
							Size = createVector(0, 0, 0)
						}):Play()
					end)
					task.wait(math.random() * 0.0015)
				end
			end)
		end

		task.spawn(function()
			task.wait(0.1)
			local v5 = tick() + 0.35

			repeat
				for _ = 1, math.random(2, 5) do
					task.spawn(function()
						local clone6 = FX:WaitForChild("Lightning2").C_Charged.Part:Clone()
						clone6.CFrame = CFrame.new(exploding)
						Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
						clone6.Attach1.WorldPosition = cFrame2.Position + createVector(0, 25, 0)
						local shafiBolt2 = ShafiBolt2(
							player,
							clone6.Attach0,
							clone6.Attach1,
							math.random(15, 20),
							math.random(2, 12) * 1.5,
							folder
						)
						local curveSize = math.random(-15, 5) * 0
						local curveSize2 = math.random(-5, 15) * 0
						shafiBolt2.CurveSize0 = curveSize
						shafiBolt2.CurveSize1 = curveSize2
						task.wait(0.2 * math.random() + 0.15)
						shafiBolt2:Destroy()
					end)
				end

				for _ = 1, math.random(2, 8) do
					task.spawn(function()
						task.wait(0.1 * math.random())
						local v6 = exploding + Vector3.new(
							math.random(-25, 25),
							math.random(25, 50),
							math.random(-25, 25)
						)
						local clone6 = FX:WaitForChild("Lightning2").C_Charged.Part:Clone()
						clone6.CFrame = CFrame.new(exploding) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
							math.random(-5, 5),
							math.random(-5, 5),
							math.random(-100, -80)
						) * CFrame.Angles(0, 0, -1.5707963267948966)
						Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
						clone6.Attach1.WorldPosition = v6 + Vector3.new(0, math.random(25, 50), 0)
						clone6.Attach0.Orientation = Vector3.new(
							math.random(-180, 180),
							math.random(-180, 180),
							math.random(-180, 180)
						)
						local shafiBolt1 = ShafiBolt1(
							player,
							clone6.Attach0,
							clone6.Attach1,
							math.random(10, 15),
							5 + math.random() * 0.5,
							folder
						)
						local curveSize = math.random(-15, 5) * 5
						local curveSize2 = math.random(-5, 15) * 5
						shafiBolt1.CurveSize0 = curveSize
						shafiBolt1.CurveSize1 = curveSize2
						task.wait(0.1 * math.random() + 0.165)
						shafiBolt1:Destroy()
					end)
				end

				task.wait(0.065)
			until v5 - tick() <= 0
		end)
	end
end