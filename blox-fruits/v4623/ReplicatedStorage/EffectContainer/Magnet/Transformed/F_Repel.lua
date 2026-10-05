local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local f_Repel = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("F_Repel")
FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local _WorldOrigin = workspace._WorldOrigin

local function RecolorMagnetColor(instance, p)
	if typeof(instance) == "Instance" and instance.Parent then
		return WrapColor3Constructor(p, instance, "MagnetFruitVFXColor")
	end

	return p
end

local TweenService = game:GetService("TweenService")
game:GetService("RunService")

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

local function QuadBezier(p, p2, p3, p4)
	return p:Lerp(p2, p4):Lerp(p2:Lerp(p3, p4), p4)
end

local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(...)
	local v = lightningBoltShafi.new(...)
	local curveSize = -math.random(5, 25)
	local curveSize2 = math.random(5, 25)
	v.CurveSize0 = curveSize
	v.CurveSize1 = curveSize2
	v.MinRadius = 3
	v.MaxRadius = 13
	v.Frequency = 0.5
	v.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(3, 4)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 10
	v.PulseLength = 1000000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Color3.new(1, 0.380392, 0.380392)
	v.ColorOffsetSpeed = 3
	return v
end

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(data.Position, unit2, v, unit3)
end

local function Explosion(cFrame, folder, raycastParams, player)
	local function Scale(instance, p)
		local position = cFrame.Position

		if instance.ClassName ~= "Model" then
			local model = Instance.new("Model")
			model.Parent = instance.Parent
			instance.Parent = model
			instance = model
		end

		instance:ScaleTo(p)
		local v = position + (instance:GetPivot().Position - position) * p
		instance:PivotTo(instance:GetPivot().Rotation + v)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function DestroyAfter(clone, duration)
		task.delay(duration, function()
			clone:Destroy()
		end)
	end

	local function cameraShakeAt(_, _, _, _, _, _) end

	local function RockCrater(p, parent, data)
		task.spawn(function()
			local rockType = data.RockType
			local radius = data.Radius
			local size = data.Size
			local duration = data.Duration
			local amount = data.Amount
			local v = AlignCFrame(CFrame.new(p.Position), p.Normal) + p.Normal * 0.01
			local v2 = {}

			for _ = 1, amount do
				local clone = rockType:Clone()
				rocks:ApplyCollision(clone, nil, true)
				clone.Parent = parent
				DestroyAfter(clone, 7) -- equivalent call inferred; original call site unknown
				table.insert(v2, clone)
			end

			task.spawn(function()
				task.wait(duration * 3)

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
				v4.CFrame = CFrame.new(v4.Position, p.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-150, 250) / 7
				)
				local ray = Ray.new(v4.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local part, v5 = workspace:FindPartOnRayWithIgnoreList(ray, raycastParams.FilterDescendantsInstances)

				if part then
					local v6 = (v4.Position - p.Position).Magnitude / 200
					local v7 = size * math.random(20, 40) / 10
					local v8 = size * math.random(10, 30) / 10
					local v9 = size * math.random(30, 50) / 10
					v4.Size = Vector3.new(v7 * v6, v8 * v6, v9 * v6)
					v4.Position = v5 + Vector3.new(0, -v4.Size.Y * math.random(5, 6) / 15, 0)
					v4.CFrame = CFrame.new(v4.Position, p.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 3,
						math.random(-25, 25) / 2
					)
					v4.CFrame = CFrame.new(
						v4.Position,
						v.Position + Vector3.new(0, math.random(-55, -45) / 100 + v4.Size.Y / 200, 0)
					) * CFrame.Angles(math.rad(-math.random(10, 15) / 1 - 60 * v6), 0, 0) * CFrame.Angles(
						0,
						0,
						(math.rad((math.random(-5, 5))))
					)
					v4.Material = part.Material
					v4.Color = part.Color
				else
					v4:Destroy()
					v2[v4] = nil
				end

				TweenService:Create(v4, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = v4.Position + Vector3.new(0, v4.Size.Y * math.random(3, 5) / 10, 0)
				}):Play()
				local v6 = v4
				local v7 = v4
				task.spawn(function()
					task.wait(duration + math.random(10, 35) / 100)
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
					v2[v6] = nil
				end)
			end
		end)
	end

	local function FlyRock(cFrame2, raycastResult, parent)
		local clone = f_Repel.Phase3.Rock:Clone()
		rocks:ApplyCollision(clone, nil, true)
		clone.CFrame = cFrame2
		clone.Size *= 2.25
		clone.Size += Vector3.new(0, math.random(0, 10) / 10, 0)
		clone.Size *= math.random(3, 5) / 3
		clone.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
		clone.Material = raycastResult.Instance.Material
		clone.Color = raycastResult.Instance.Color
		clone.CanCollide = false
		clone.Parent = parent
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(70000000000, 70000000000, 70000000000)
		bodyVelocity.P = 50000
		bodyVelocity.Parent = clone
		local vector2 = Vector3.new(math.random(-30, 30) * 20, 0, math.random(-30, 30) * 20)
		local vector3 = Vector3.new(0, math.random(700, 1000) * 1.5, 0)
		local v = math.random(70, 100) * 1.25
		bodyVelocity.Velocity = CFrame.new(clone.Position, clone.Position + vector2 + vector3).LookVector * v
		task.delay(1 * math.random() + 1.5, function()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				Size = createVector(0, 0, 0)
			}):Play()
		end)
		task.delay(0.015 * math.random() + 0.015, function()
			bodyVelocity:Destroy()
			task.wait(0.1)
			clone.CanCollide = true
		end)
	end

	task.spawn(function() end)
	local raycastResult = workspace:Raycast(
		cFrame.Position + createVector(0, 1, 0),
		createVector(-0, -75, -0),
		raycastParams
	)

	if not raycastResult then
		return
	end

	local cFrame3 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
	local v2 = {
		Radius = 93.75,
		Size = 15,
		Duration = 0.75,
		Amount = 35,
		RockType = f_Repel.Phase3.CraterRock
	}
	task.spawn(function()
		local rockType = v2.RockType
		local radius = v2.Radius
		local size = v2.Size
		local duration = v2.Duration
		local amount = v2.Amount
		local v3 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
		local v4 = {}

		for _ = 1, amount do
			local clone = rockType:Clone()
			rocks:ApplyCollision(clone, nil, true)
			clone.Parent = folder
			DestroyAfter(clone, 7) -- equivalent call inferred; original call site unknown
			table.insert(v4, clone)
		end

		task.spawn(function()
			task.wait(duration * 3)

			for _, v5 in pairs(v4) do
				v5:Destroy()
			end

			v4 = nil
		end)
		local v5 = 360 / #v4
		local total = 0

		for _, v6 in pairs(v4) do
			total += v5
			v6.CFrame = v3 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
			v6.CFrame = CFrame.new(v6.Position, raycastResult.Position) * CFrame.new(
				0,
				math.random(-5, 5) / 3,
				math.random(-150, 250) / 7
			)
			local ray = Ray.new(v6.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
			local part, v7 = workspace:FindPartOnRayWithIgnoreList(ray, raycastParams.FilterDescendantsInstances)

			if part then
				local v8 = (v6.Position - raycastResult.Position).Magnitude / 200
				local v9 = size * math.random(20, 40) / 10
				local v10 = size * math.random(10, 30) / 10
				local v11 = size * math.random(30, 50) / 10
				v6.Size = Vector3.new(v9 * v8, v10 * v8, v11 * v8)
				v6.Position = v7 + Vector3.new(0, -v6.Size.Y * math.random(5, 6) / 15, 0)
				v6.CFrame = CFrame.new(v6.Position, raycastResult.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-25, 25) / 2
				)
				v6.CFrame = CFrame.new(
					v6.Position,
					v3.Position + Vector3.new(0, math.random(-55, -45) / 100 + v6.Size.Y / 200, 0)
				) * CFrame.Angles(math.rad(-math.random(10, 15) / 1 - 60 * v8), 0, 0) * CFrame.Angles(
					0,
					0,
					(math.rad((math.random(-5, 5))))
				)
				v6.Material = part.Material
				v6.Color = part.Color
			else
				v6:Destroy()
				v4[v6] = nil
			end

			TweenService:Create(v6, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = v6.Position + Vector3.new(0, v6.Size.Y * math.random(3, 5) / 10, 0)
			}):Play()
			local v8 = v6
			local v9 = v6
			task.spawn(function()
				task.wait(duration + math.random(10, 35) / 100)
				local tween = TweenService:Create(
					v8,
					TweenInfo.new(
						0.5,
						Enum.EasingStyle.Back,
						Enum.EasingDirection.In,
						0,
						false,
						math.random(10, 35) / 100
					),
					{
						Position = v8.Position + Vector3.new(
							math.random(-1, 1),
							-v8.Size.Y * math.random(20, 25) / 10,
							math.random(-1, 1)
						)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v8:Destroy()
				v4[v8] = nil
			end)
		end
	end)
	task.spawn(function()
		for i = 1, 20 do
			task.spawn(function()
				FlyRock(
					cFrame3 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
						0,
						0,
						-math.random(125, 150) / 1.5
					),
					raycastResult,
					folder
				)
			end)

			if i % 2 == 0 then
				task.wait(0.001 * math.random())
			end
		end
	end)
	task.spawn(function()
		local clone = f_Repel.Phase2.GroundCrack:Clone()
		clone.CFrame = cFrame3
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end
	end)
	return raycastResult
end

return function(data)
	assert(
		data.Origin or data.Root and data.Root.Position or data.Player and data.Player.Character.PrimaryPart.Position,
		"Origin Vector3 missing in: ",
		script:GetFullName()
	)
	local player = data.Player

	if data.Stage ~= 2 then
		return
	end

	local root = data.Root
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 5)
	local startCFrame = data.StartCFrame
	root.CFrame = startCFrame
	root.Anchored = true
	local raycastParams = RaycastParams.new()
	raycastParams.IgnoreWater = false
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
	local clone = f_Repel.Phase1.StartImpact:Clone()
	clone.CFrame = startCFrame * CFrame.new(0, 0, 25)
	Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
	task.spawn(function()
		local clone2 = f_Repel.Phase1.SpinSlash:Clone()
		clone2:PivotTo(startCFrame)
		Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
		local model2 = clone2.Model2
		local v = -35

		for i = 1, 5 do
			local clone3 = model2:Clone()
			local v3

			if i == 1 then
				v3 = 1.15
			else
				v3 = 1.15

				if i == 2 then
					v3 = 0.85
					v = -50
				elseif i == 3 then
					v3 = 1.35
					v = -75
				elseif i == 4 then
					v3 = 1.45
					v = -65
				elseif i == 5 then
					v3 = 1.1
					v = -35
				end
			end

			clone3:ScaleTo((i * 1.05 + 15) / v3)

			for _, beam in pairs(clone3:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Enabled = true
				end
			end

			local primaryPart = clone3.PrimaryPart
			local v4 = clone2.PrimaryPart.CFrame * CFrame.new(0, 0, v * 0.6 * i) * CFrame.Angles(
				math.rad(math.random(-180, 180) / 100),
				math.rad(math.random(-180, 180) / 100),
				(math.rad((math.random(-180, 180))))
			)
			local angularVelocity = primaryPart.AngularVelocity
			primaryPart.Anchored = false
			primaryPart.AlignPosition.Position = primaryPart.Position
			angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
			clone3:PivotTo(v4)
			local v5 = i
			task.spawn(function()
				task.wait(v5 * 0.025)
				Util.SetParentOverrideWithColor(clone3, clone2, player, "MagnetFruitVFXColor")
			end)
			clone3:GetScale()
			task.spawn(function()
				TweenService:Create(
					angularVelocity,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
							math.random(-5, 5) / 5,
							math.random(-5, 5) / 5,
							math.random(5, 10)
						)
					}
				):Play()
				task.wait(0.15 * math.random() + 0.17 / v3)

				for i2, effect in pairs(clone3:GetDescendants()) do
					if effect:IsA("Beam") then
						TweenService:Create(effect, TweenInfo.new(0.15 / v3 + math.random() * 0.15 / v3), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						local v7 = effect
						task.delay(1, function()
							v7:Destroy()
						end)
					elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				task.wait(1)
				angularVelocity.Enabled = false
			end)
		end

		task.spawn(function()
			local v2 = clone2:GetScale() * 0.5
			local v3 = v2 * 1.15

			for i = v2 * 100, v3 * 100, 10 do
				clone2:ScaleTo(i / 100)
				task.wait(0.005)
			end
		end)
	end)
	task.spawn(function()
		local clone2 = f_Repel.Phase1.SpinSlash2:Clone()
		clone2:PivotTo(startCFrame * CFrame.new(0, 0, -10))
		Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
		local model = clone2.Model
		local v = -35

		for i = 1, 5 do
			local clone3 = model:Clone()
			local v3

			if i == 1 then
				v3 = 1.15
			else
				v3 = 1.15

				if i == 2 then
					v3 = 1
					v = -50
				elseif i == 3 then
					v3 = 1.35
					v = -75
				elseif i == 4 then
					v3 = 1.45
					v = -65
				elseif i == 5 then
					v3 = 1.1
					v = -35
				end
			end

			clone3:ScaleTo((i * 1.05 + 9) / v3)

			for _, beam in pairs(clone3:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = true
				beam.Width0 *= 1.5
				beam.Width1 *= 1.5
			end

			local primaryPart = clone3.PrimaryPart
			local v4 = clone2.PrimaryPart.CFrame * CFrame.new(0, 0, v * 0.6 * i) * CFrame.Angles(
				math.rad(math.random(-180, 180) / 100),
				math.rad(math.random(-180, 180) / 100),
				(math.rad((math.random(-180, 180))))
			)
			local angularVelocity = primaryPart.AngularVelocity
			primaryPart.Anchored = false
			primaryPart.AlignPosition.Position = primaryPart.Position
			angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
			clone3:PivotTo(v4)
			local v5 = i
			task.spawn(function()
				task.wait(v5 * 0.025)
				Util.SetParentOverrideWithColor(clone3, clone2, player, "MagnetFruitVFXColor")
			end)
			clone3:GetScale()
			task.spawn(function()
				TweenService:Create(
					angularVelocity,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
							math.random(-5, 5) / 5,
							math.random(-5, 5) / 5,
							math.random(5, 10)
						)
					}
				):Play()
				task.wait(0.15 * math.random() + 0.17 / v3)

				for i2, effect in pairs(clone3:GetDescendants()) do
					if effect:IsA("Beam") then
						TweenService:Create(effect, TweenInfo.new(0.15 / v3 + math.random() * 0.15 / v3), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						local v7 = effect
						task.delay(1, function()
							v7:Destroy()
						end)
					elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				task.wait(1)
				angularVelocity.Enabled = false
			end)
		end

		task.spawn(function()
			local v2 = clone2:GetScale() * 0.5
			local v3 = v2 * 1.25

			for i = v2 * 100, v3 * 100, 10 do
				clone2:ScaleTo(i / 100)
				task.wait(0.005)
			end
		end)
	end)
	local clone2 = f_Repel.Phase1.DashAura:Clone()
	clone2.CFrame = root.CFrame
	Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
	clone2.Anchored = false
	clone2.Weld.Part1 = root
	Util.Sound:Play("Magnet_Transformed_F_Tap_Release_Dash_01", root)

	for _, effect in pairs(clone2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	local dashSpeed = data.DashSpeed
	local dashDist = data.DashDist
	TweenService:Create(root, TweenInfo.new(dashSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		CFrame = root.CFrame * CFrame.new(0, 0, -dashDist)
	}):Play()
	task.wait(dashSpeed)

	for _, effect in pairs(clone2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	if data.Rig then
		local v = data.Rig:GetAttribute("Arcsteel") and "Arcsteel " or ""
		local v2 = Util.Anims:Get(data.Rig, v .. "Transformed Magnet Mech F Hold Explode")
		v2.Priority = Enum.AnimationPriority.Action3
		v2.Looped = false
		v2:Play()
	end

	local endPos = data.EndPos
	local cFrame = root.CFrame
	root.Anchored = false
	local clone3 = f_Repel.Phase2.ExStartImpact:Clone()
	clone3.CFrame = cFrame * CFrame.new(0, 0, -5)
	Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 0.75, lifetime.Max * 0.75)
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
	local ray = Util.Ray
	local position = root.Position
	local v = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

	if ray(position, createVector(-0, -75, -0), v) then
		Util.Sound:Play("Magnet_Transformed_F_Tap_ChargeExplode_Ground_01", cFrame.Position)
	else
		Util.Sound:Play("Magnet_Transformed_F_Tap_ChargeExplode_Air_01", cFrame.Position)
	end

	task.wait(0.1)
	task.spawn(function()
		local clone4 = f_Repel.Phase1.SpinSlash:Clone()
		clone4:PivotTo(CFrame.new(endPos))
		Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
		local model2 = clone4.Model2

		for i = 1, 5 do
			local v2 = math.random(70, 100) / 200
			local v3 = i * 0.35 + 7 + math.random(-10, 10) / 10
			local clone5 = model2:Clone()
			clone5:ScaleTo(v3)
			local primaryPart = clone5.PrimaryPart
			local v4 = clone4.PrimaryPart.CFrame * CFrame.Angles(
				math.rad(math.random(-180, 180) / 1),
				math.rad((math.random(-180, 180))),
				(math.rad(math.random(-180, 180) / 1))
			)
			local angularVelocity = primaryPart.AngularVelocity
			primaryPart.Anchored = false
			primaryPart.AlignPosition.Position = primaryPart.Position + createVector(0, 5, 0)
			angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15) * 2, 0)
			clone5:PivotTo(v4)
			Util.SetParentOverrideWithColor(clone5, clone4, player, "MagnetFruitVFXColor")
			primaryPart.AlignPosition.Enabled = true
			angularVelocity.Enabled = true
			clone5:GetScale()

			for _, beam in pairs(clone5:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Enabled = true
				end
			end

			local folder2 = clone5
			task.spawn(function()
				task.spawn(function()
					TweenService:Create(
						angularVelocity,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
								math.random(-15, 15) / 10,
								math.random(5, 15),
								math.random(-15, 15) / 10
							)
						}
					):Play()
					task.wait(v2 / 2)
					primaryPart.AlignPosition.Position = endPos + createVector(0, 5, 0)
				end)
				task.wait(0.035 * math.random() + 0.1)

				for i2, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("Beam") then
						TweenService:Create(effect, TweenInfo.new(0.35 + math.random() * 0.125), {
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
				task.wait(3)
				angularVelocity:Destroy()
			end)
		end

		model2:Destroy()
		task.spawn(function()
			local scale = clone4:GetScale()
			local v2 = scale * 0.01

			for i = scale * 100, v2 * 100, -25 do
				clone4:ScaleTo(i / 100)
				task.wait(0.005)
			end
		end)
	end)
	task.spawn(function()
		for _ = 1, 10 do
			task.spawn(function()
				local v2 = math.random(45, 50) / 100
				local clone4 = f_Repel.Phase1.TrailModel:Clone()
				clone4.Start.CFrame = CFrame.new(endPos) * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				)
				Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
				clone4:ScaleTo(math.random(20, 25) / 7)
				local start = clone4.Start
				local trail = clone4.Trail
				local cframe = CFrame.new(0, 0, -math.random(100, 150) * 1)
				TweenService:Create(trail.Weld, TweenInfo.new(v2 / 5), {
					C1 = cframe
				}):Play()
				TweenService:Create(start, TweenInfo.new(v2), {
					CFrame = CFrame.new(endPos) * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
				}):Play()
				trail.Weld.C1 = CFrame.new(0, 0, 0)
				task.delay(v2 / 5, function()
					TweenService:Create(trail.Weld, TweenInfo.new(v2 / 2), {
						C1 = CFrame.new(0, 0, 0)
					}):Play()
					start.AlignPosition.Position = endPos
				end)
				trail.Trail1.Lifetime = math.random(50, 200) / 1500
				local angularVelocity = start.AngularVelocity
				start.Anchored = false
				start.AlignPosition.Position = start.Position
				TweenService:Create(angularVelocity, TweenInfo.new(0.125), {
					AngularVelocity = Vector3.new(
						math.random(-10, 15) * 2,
						math.random(-10, 15) * 2,
						math.random(-10, 15) * 2
					)
				}):Play()

				for _, effect in pairs(clone4:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = true
					local v3 = effect
					task.delay(v2 + v2 / 5, function()
						v3.Enabled = false
					end)
				end

				task.wait(v2)
				angularVelocity.Enabled = false
				task.wait(v2)
				clone4:Destroy()
			end)
		end
	end)
	task.spawn(function()
		local v2 = tick() + 0.5 + 0.15

		for i = 1, 5 do
			local v3 = i
			task.spawn(function()
				task.wait(math.random() * 0.25)
				local clone4 = f_Repel.Phase2.RaySmall:Clone()
				clone4:ScaleTo(math.random(70, 100) / 14)
				local crackBeam = clone4.CrackBeam
				local v4 = 1 - v3 / 4 * 2
				local v5 = math.sqrt(1 - v4 * v4)
				local v6 = 2.399963229728653 * v3
				local v7 = endPos + Vector3.new(math.cos(v6) * v5, v4, math.sin(v6) * v5).Unit * 15
				crackBeam.CFrame = CFrame.lookAt(v7, endPos) * CFrame.new(0, 0, -math.random(15, 25))
				Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
				local v8 = math.random(45, 75) * 1.15
				local attach1 = crackBeam.Attach1
				local v9 = math.random(10, 25) / 125
				attach1.Position = createVector(0, 0, 0)
				TweenService:Create(attach1, TweenInfo.new(v9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = Vector3.new(0, 0, -v8)
				}):Play()
				task.delay(v2 - tick(), function()
					clone4:Destroy()
				end)
			end)
		end
	end)
	task.spawn(function()
		local v2 = tick() + 0.5 + 0.15

		for i = 1, 5 do
			local v3 = i
			task.spawn(function()
				task.wait(math.random() * 0.25)
				local clone4 = f_Repel.Phase2.Ray:Clone()
				clone4:ScaleTo(math.random(70, 100) / 14)
				local crackBeam = clone4.CrackBeam
				local v4 = 1 - v3 / 4 * 2
				local v5 = math.sqrt(1 - v4 * v4)
				local v6 = 2.399963229728653 * v3
				local v7 = endPos + Vector3.new(math.cos(v6) * v5, v4, math.sin(v6) * v5).Unit * 15
				crackBeam.CFrame = CFrame.lookAt(v7, endPos) * CFrame.new(0, 0, -math.random(15, 25))
				Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
				local v8 = math.random(45, 75) * 1.15
				local attach1 = crackBeam.Attach1
				local v9 = math.random(30, 50) / 125
				attach1.Position = createVector(0, 0, 0)
				TweenService:Create(attach1, TweenInfo.new(v9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Position = Vector3.new(0, 0, -v8)
				}):Play()
				task.delay(v2 - tick(), function()
					clone4:Destroy()
				end)
			end)
		end
	end)
	local clone4 = f_Repel.Phase2.SphereAura:Clone()
	clone4.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")

	for _, emitter in pairs(clone4:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			v2:Emit(1)
			v2.Enabled = true
			task.wait(0.65)
			v2.Enabled = false
		end)
	end

	task.spawn(function()
		local v2 = tick() + 0.5
		local now = tick()
		local now2 = tick()

		repeat
			if now - tick() <= 0 then
				now = tick() + 0.015

				for i = 1, math.random(1, 2) do
					local v3 = i
					task.spawn(function()
						local clone5 = script.Part:Clone()
						local cFrame2 = CFrame.new(cFrame.Position) * CFrame.Angles(
							math.random(-180, 180),
							math.rad((math.random(-180, 180))),
							math.random(-180, 180)
						) * CFrame.new(0, 0, 50)
						clone5.CFrame = cFrame2
						Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
						clone5.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, -100).Position
						local shafiBolt = ShafiBolt(clone5.Attach0, clone5.Attach1, math.random(8, 12), 0.75, folder)
						shafiBolt.CurveSize0 = -33.333333333333336
						shafiBolt.CurveSize1 = 33.333333333333336
						shafiBolt.Frequency = math.random(5, 10)
						shafiBolt.MaxRadius = 5
						shafiBolt.AnimationSpeed = math.random(20, 50) / 10
						local v6 = player
						local color = Color3.fromRGB(28, 39, 255)

						if typeof(v6) == "Instance" and v6.Parent then
							color = WrapColor3Constructor(color, v6, "MagnetFruitVFXColor")
						end

						shafiBolt.Color = color

						if v3 % 2 == 0 then
							local v7 = player
							local color2 = Color3.fromRGB(53, 73, 255)

							if typeof(v7) == "Instance" and v7.Parent then
								color2 = WrapColor3Constructor(color2, v7, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color2
						end

						task.spawn(function()
							task.wait(0.07 + math.random() * 0.1)
							shafiBolt:Destroy()
						end)
					end)
				end
			end

			if now2 - tick() <= 0 then
				now2 = tick() + 0.075
				task.spawn(function()
					local clone5 = f_Repel.Phase1.SpinSlash:Clone()
					clone5:PivotTo(CFrame.new(endPos))
					Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
					local model2 = clone5.Model2

					for i = 1, 2 do
						local v3 = math.random(70, 100) / 150
						local v4 = i * 0.35 + 17 + math.random(-10, 10) / 10
						local clone6 = model2:Clone()
						clone6:ScaleTo(v4)
						local primaryPart = clone6.PrimaryPart
						local v5 = clone5.PrimaryPart.CFrame * CFrame.Angles(
							math.rad(math.random(-180, 180) / 1),
							math.rad((math.random(-180, 180))),
							(math.rad(math.random(-180, 180) / 1))
						)
						local angularVelocity = primaryPart.AngularVelocity
						primaryPart.Anchored = false
						primaryPart.AlignPosition.Position = primaryPart.Position + createVector(0, 5, 0)
						angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15) * 3, 0)
						clone6:PivotTo(v5)
						Util.SetParentOverrideWithColor(clone6, clone5, player, "MagnetFruitVFXColor")
						primaryPart.AlignPosition.Enabled = true
						angularVelocity.Enabled = true

						for _, beam in pairs(clone6:GetDescendants()) do
							if not beam:IsA("Beam") then
								continue
							end

							beam.Enabled = true
							beam.Width0 *= 0.7
							beam.Width1 *= 0.7
							beam.Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.9),
								NumberSequenceKeypoint.new(1, 0.9)
							})
						end

						clone6:GetScale()
						local folder2 = clone6
						task.spawn(function()
							task.spawn(function()
								TweenService:Create(
									angularVelocity,
									TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
											math.random(-15, 15) / 10,
											math.random(5, 15) * 3,
											math.random(-15, 15) / 10
										)
									}
								):Play()
								task.wait(v3 / 2)
								primaryPart.AlignPosition.Position = endPos + createVector(0, 5, 0)
							end)
							task.wait(0.035 * math.random() + 0.1)

							for i2, effect in pairs(folder2:GetDescendants()) do
								if effect:IsA("Beam") then
									TweenService:Create(effect, TweenInfo.new(0.35 + math.random() * 0.125), {
										Width0 = 0,
										Width1 = 0
									}):Play()
									local v9 = effect
									task.delay(1, function()
										v9:Destroy()
									end)
								elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end

							task.wait(1)
							angularVelocity.Enabled = false
							task.wait(3)
							angularVelocity:Destroy()
						end)
					end

					model2:Destroy()
					task.spawn(function()
						local scale = clone5:GetScale()
						local v3 = scale * 0.01

						for i = scale * 100, v3 * 100, -10 do
							clone5:ScaleTo(i / 100)
							task.wait(0.005)
						end
					end)
				end)
			end

			task.wait(0.01)
		until v2 - tick() <= 0
	end)
	task.wait(0.5)
	task.spawn(function()
		local clone5 = f_Repel.Phase1.SpinSlash2:Clone()
		clone5:PivotTo(CFrame.new(endPos))
		Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
		local model = clone5.Model

		for i = 1, 5 do
			task.wait(math.random(5, 35) / 1000)
			local v2 = math.random(70, 100) / 200
			local v3 = i * 1.5 + 17 + math.random(-30, 30) / 10
			local clone6 = model:Clone()
			clone6:ScaleTo(v3)
			local primaryPart = clone6.PrimaryPart
			local v4 = clone5.PrimaryPart.CFrame * CFrame.Angles(
				math.rad(math.random(-180, 180) / 1),
				math.rad((math.random(-180, 180))),
				(math.rad(math.random(-180, 180) / 1))
			)
			local angularVelocity = primaryPart.AngularVelocity
			primaryPart.Anchored = false
			primaryPart.AlignPosition.Position = primaryPart.Position + createVector(0, 5, 0)
			angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 15) * 2)
			clone6:PivotTo(v4)
			Util.SetParentOverrideWithColor(clone6, clone5, player, "MagnetFruitVFXColor")
			primaryPart.AlignPosition.Enabled = true
			angularVelocity.Enabled = true
			clone6:GetScale()

			for _, beam in pairs(clone6:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = true
				beam.Width0 *= 0.7
				beam.Width1 *= 0.7
			end

			local folder2 = clone6
			task.spawn(function()
				task.spawn(function()
					TweenService:Create(
						angularVelocity,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
								math.random(-15, 15) / 10,
								math.random(-15, 15) / 10,
								math.random(10, 15) * 3
							)
						}
					):Play()
					task.wait(v2 / 2)
					primaryPart.AlignPosition.Position = endPos + createVector(0, 5, 0)
				end)
				task.wait(0.05 * math.random() + 0.1)

				for i2, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("Beam") then
						TweenService:Create(effect, TweenInfo.new(0.125 + math.random() * 0.125), {
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
				task.wait(3)
				angularVelocity:Destroy()
			end)
		end

		model:Destroy()
		task.spawn(function()
			local scale = clone5:GetScale()
			local v2 = scale * 0.01

			for i = scale * 100, v2 * 100, -20 do
				clone5:ScaleTo(i / 100)
				task.wait(0.0025)
			end
		end)
	end)
	task.wait(0.15)
	local clone5 = f_Repel.Phase2.ExStartImpact2:Clone()
	clone5.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")

	for _, emitter in pairs(clone5:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 0.75, lifetime.Max * 0.75)
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown
	task.wait(0.075)
	task.spawn(function()
		local v2 = cFrame
		local clone6 = f_Repel.Phase2.Sphere:Clone()
		clone6.Size = createVector(50, 50, 50)
		clone6.CFrame = CFrame.new(v2.Position + createVector(0, 15, 0), workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
			math.random(-180, 180),
			math.random(-180, 180),
			math.random(-180, 180)
		)
		Util.SetParentOverrideWithColor(clone6, folder, player, "MagnetFruitVFXColor")
		task.spawn(function()
			TweenService:Create(clone6, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = clone6.Size * 3.7
			}):Play()

			for _, decal in pairs(clone6:GetDescendants()) do
				if not decal:IsA("Decal") then
					continue
				end

				decal.Transparency = 0.5
				TweenService:Create(decal, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
					Transparency = 1
				}):Play()
			end
		end)
		task.spawn(function()
			local clone7 = f_Repel.Phase2.Sphere1:Clone()
			clone7.Size = createVector(62.5, 62.5, 62.5)
			clone7.CFrame = CFrame.new(v2.Position + createVector(0, 15, 0), workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
				math.random(-180, 180),
				math.random(-180, 180),
				math.random(-180, 180)
			)
			Util.SetParentOverrideWithColor(clone7, folder, player, "MagnetFruitVFXColor")
			task.spawn(function()
				TweenService:Create(clone7, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = clone7.Size * 3.7
				}):Play()

				for _, decal in pairs(clone7:GetDescendants()) do
					if not decal:IsA("Decal") then
						continue
					end

					decal.Transparency = 0.5
					TweenService:Create(decal, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
						Transparency = 1,
						StudsPerTileU = math.random(15, 20) * 2,
						StudsPerTileV = math.random(15, 20) * 2
					}):Play()
				end
			end)
		end)
	end)
	local clone6 = f_Repel.Phase3.ExplosionFinal:Clone()
	clone6.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone6, folder, player, "MagnetFruitVFXColor")

	if (workspace.CurrentCamera.CFrame.p - cFrame.Position).Magnitude < 210 then
		Util.CameraShaker:ShakeOnce(12, 8, 0.2, 0.6)
	end

	for _, emitter in pairs(clone6:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 1.85, lifetime.Max * 1.85)
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	DeleteImpactAfterDuration(clone6) -- equivalent call inferred; original call site unknown
	task.spawn(function()
		local clone7 = f_Repel.Phase3.SpinSlash:Clone()
		clone7:PivotTo(cFrame)
		Util.SetParentOverrideWithColor(clone7, folder, player, "MagnetFruitVFXColor")
		local model2 = clone7.Model2

		for i = 1, 5 do
			local v3 = 1
			local clone8 = model2:Clone()

			if i ~= 1 then
				if i == 2 then
					v3 = 0.95
				elseif i == 3 then
					v3 = 0.9
				elseif i == 4 then
					v3 = 0.85
				elseif i == 5 then
					v3 = 0.8
				else
					v3 = v3
				end
			end

			clone8:ScaleTo((i * 1.075 + 22.5) / v3)

			for _, beam in pairs(clone8:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Enabled = true
				end
			end

			local primaryPart = clone8.PrimaryPart
			local v4 = clone7.PrimaryPart.CFrame * CFrame.Angles(
				math.rad((math.random(-180, 180))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-180, 180))))
			)
			local angularVelocity = primaryPart.AngularVelocity
			primaryPart.Anchored = false
			primaryPart.AlignPosition.Position = primaryPart.Position
			angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20) / 3)
			clone8:PivotTo(v4)
			Util.SetParentOverrideWithColor(clone8, clone7, player, "MagnetFruitVFXColor")
			clone8:GetScale()
			task.spawn(function()
				TweenService:Create(
					angularVelocity,
					TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
							math.random(-5, 5) / 5,
							math.random(-5, 5) / 5,
							math.random(5, 10)
						)
					}
				):Play()
				task.wait(0.05 * math.random() + 0.15 / v3)

				for i2, effect in pairs(clone8:GetDescendants()) do
					if effect:IsA("Beam") then
						TweenService:Create(effect, TweenInfo.new(0.15 / v3 + math.random() * 0.15 / v3), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						local v6 = effect
						task.delay(1, function()
							v6:Destroy()
						end)
					elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				task.wait(1)
				angularVelocity.Enabled = false
			end)
		end

		task.spawn(function()
			local v2 = clone7:GetScale() * 0.75
			local v3 = v2 * 1.15

			for i = v2 * 100, v3 * 100, 10 do
				clone7:ScaleTo(i / 100)
				task.wait(0.005)
			end
		end)
	end)
	task.spawn(function()
		local clone7 = f_Repel.Phase3.SpinSlash2:Clone()
		clone7:PivotTo(cFrame)
		Util.SetParentOverrideWithColor(clone7, folder, player, "MagnetFruitVFXColor")
		local model = clone7.Model

		for i = 3, 5 do
			local v3 = 1
			local clone8 = model:Clone()

			if i ~= 1 then
				if i == 2 then
					v3 = 0.95
				elseif i == 3 then
					v3 = 0.9
				elseif i == 4 then
					v3 = 0.85
				elseif i == 5 then
					v3 = 0.8
				else
					v3 = v3
				end
			end

			clone8:ScaleTo((i * 1.075 + 18) / v3)

			for _, beam in pairs(clone8:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Enabled = true
				end
			end

			local primaryPart = clone8.PrimaryPart
			local v4 = clone7.PrimaryPart.CFrame * CFrame.Angles(
				math.rad((math.random(-180, 180))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-180, 180))))
			)
			local angularVelocity = primaryPart.AngularVelocity
			primaryPart.Anchored = false
			primaryPart.AlignPosition.Position = primaryPart.Position
			angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
			clone8:PivotTo(v4)
			Util.SetParentOverrideWithColor(clone8, clone7, player, "MagnetFruitVFXColor")
			clone8:GetScale()
			task.spawn(function()
				TweenService:Create(
					angularVelocity,
					TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
							math.random(-5, 5) / 5,
							math.random(-5, 5) / 5,
							math.random(5, 10)
						)
					}
				):Play()
				task.wait(0.05 * math.random() + 0.135 / v3)

				for i2, effect in pairs(clone8:GetDescendants()) do
					if effect:IsA("Beam") then
						TweenService:Create(effect, TweenInfo.new(0.15 / v3 + math.random() * 0.15 / v3), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						local v6 = effect
						task.delay(1, function()
							v6:Destroy()
						end)
					elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				task.wait(1)
				angularVelocity.Enabled = false
			end)
		end

		task.spawn(function()
			local v2 = clone7:GetScale() * 0.75
			local v3 = v2 * 1.15

			for i = v2 * 100, v3 * 100, 10 do
				clone7:ScaleTo(i / 100)
				task.wait(0.005)
			end
		end)
	end)
	Explosion(cFrame, folder, raycastParams, player)
end