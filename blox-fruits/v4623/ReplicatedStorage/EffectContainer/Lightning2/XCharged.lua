local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local assets = FX:WaitForChild("Lightning2").XCharged.Assets
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

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyAfter(clone, duration)
	task.delay(duration, function()
		clone:Destroy()
	end)
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
			DestroyAfter(clone, 7) -- equivalent call inferred; original call site unknown
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
			local ray = Ray.new(v4.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
			local part, v5 = workspace:FindPartOnRayWithIgnoreList(ray, p2.FilterDescendantsInstances)

			if part then
				local v6 = (v4.Position - p.Position).Magnitude / 150
				local v7 = size * math.random(15, 30) / 10
				local v8 = size * math.random(5, 20) / 10
				local v9 = size * math.random(30, 50) / 10
				v4.Size = Vector3.new(v7 * v6, v8 * v6, v9 * v6)
				v4.Position = v5 + Vector3.new(0, -v4.Size.Y * math.random(5, 6) / 15, 0)
				v4.CFrame = CFrame.new(v4.Position, p.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-offset / 2, offset / 2)
				)
				v4.CFrame = CFrame.new(
					v4.Position,
					v.Position + Vector3.new(0, math.random(-55, -45) / 100 + v4.Size.Y / 200, 0)
				) * CFrame.Angles(math.rad(-math.random(10, 15) / 2 - 45 * v6), 0, 0) * CFrame.Angles(
					0,
					0,
					(math.rad((math.random(-5, 5))))
				)
				v4.Material = part.Material
				v4.Color = part.Color
			else
				v4:Destroy()

				if v2 then
					v2[v4] = nil
				end
			end

			TweenService:Create(v4, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {
				Position = v4.Position + Vector3.new(0, v4.Size.Y * math.random(3, 5) / 10, 0)
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

local LightningBoltShafi = require(game.ReplicatedStorage.Util.LightningBoltShafi)

local function ShafiBolt1(player, ...)
	local v = LightningBoltShafi.new(...)
	v.CurveSize0 = 0
	v.CurveSize1 = 0
	v.MinRadius = 1
	v.MaxRadius = 15
	v.Frequency = 10
	v.AnimationSpeed = 10
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = 1
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 10
	v.PulseLength = 1000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Util.WrapColor3Constructor(Color3.new(0.298039, 1, 1), player, "LightningFruitVFXColor")
	v.ColorOffsetSpeed = 3
	return v
end

local function ShafiBolt2(player, ...)
	local v = LightningBoltShafi.new(...)
	local curveSize = math.random(-150, 150) / 3
	local curveSize2 = math.random(-150, 150) / 3
	v.CurveSize0 = curveSize
	v.CurveSize1 = curveSize2
	v.MinRadius = 1
	v.MaxRadius = 20
	v.Frequency = 8
	v.AnimationSpeed = 5
	local maxThicknessMultiplier = math.random(8, 15) / 10
	v.MinThicknessMultiplier = 0.25
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 5
	v.PulseLength = 1000
	v.FadeLength = 0.2
	v.ContractFrom = 0.25
	v.Color = Util.WrapColor3Constructor(Color3.new(0.341176, 0.988235, 1), player, "LightningFruitVFXColor")
	v.ColorOffsetSpeed = 3
	return v
end

return function(data)
	local SIZE_AND_HITBOX_MULTIPLIER = data.SIZE_AND_HITBOX_MULTIPLIER or 1
	local player = data.player

	if (currentCamera.CFrame.p - data.Origin).Magnitude > 1000 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		return
	end

	if stage == 2 then
		local targetPosition = data.TargetPosition
		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		Util.Debris:AddItem(folder, 15)
		local height = data.Height
		local cFrame = CFrame.new(targetPosition) * CFrame.new(0, height, 0)
		local ray = Ray.new(cFrame.Position, CFrame.new(cFrame.Position).UpVector * -height)
		local _, v2, _ = workspace:FindPartOnRayWithIgnoreList(
			ray,
			{ workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		)
		Util.Sound:Play("BF_Thunder_X_CloudsAppear_01", cFrame.Position)
		local clone = assets.Phase3:Clone()
		local model = Instance.new("Model")
		clone.Parent = model
		model:ScaleTo(SIZE_AND_HITBOX_MULTIPLIER)
		task.spawn(function()
			for i = 1, 2 do
				local v3 = i
				task.spawn(function()
					local clone2 = clone.CloudSpin:Clone()
					clone2:ScaleTo(35)
					local primaryPart = clone2.PrimaryPart
					local v5 = cFrame * CFrame.new(0, -60, 0) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)

					if v3 == 2 then
						v5 *= CFrame.new(0, -50, 0)
						clone2:ScaleTo(30)
					end

					local angularVelocity = primaryPart.AngularVelocity
					primaryPart.Anchored = false
					primaryPart.AlignPosition.Position = v5.Position + Vector3.new(
						math.random(-10, 10) / 10,
						0,
						math.random(-10, 10) / 10
					)
					angularVelocity.AngularVelocity = Vector3.new(0, math.random(5, 10), 0)
					clone2:PivotTo(v5)
					Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
					clone2:GetScale()
					task.spawn(function()
						task.spawn(function()
							local Y = clone2.Slash.Position.Y
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

						for i2, effect in pairs(clone2:GetDescendants()) do
							if effect:IsA("Beam") then
								local v6 = effect
								task.spawn(function()
									local tween = TweenService:Create(v6, TweenInfo.new(0.1 + math.random() * 0.1), {
										Width0 = v6.Width0,
										Width1 = v6.Width1
									})
									v6.Width0 = 0
									v6.Width1 = 0
									task.wait(0.67)
									tween:Play()
								end)
							elseif effect:IsA("ParticleEmitter") then
								local v6 = effect
								task.spawn(function()
									local v7 = v6.Lifetime.Min * 0.5
									task.wait(0.25)
									v6.Lifetime = NumberRange.new(v7, v7)
									task.wait(0.25)
									v6.Enabled = false
								end)
							end
						end

						task.wait(0.67)
						task.wait(0.25 * math.random() + 0.1)

						for i2, effect in pairs(clone2:GetDescendants()) do
							if effect:IsA("Beam") then
								TweenService:Create(effect, TweenInfo.new(0.25 + math.random() * 0.15), {
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
				end)
			end
		end)
		local clone2 = assets.Phase2:Clone()
		local model2 = Instance.new("Model")
		clone2.Parent = model2
		model2:ScaleTo(SIZE_AND_HITBOX_MULTIPLIER)
		task.spawn(function()
			task.spawn(function()
				local v3 = {}

				for _ = 1, 5 do
					task.spawn(function()
						local clone3 = clone2.SpinTrail:Clone()
						clone3.CFrame = CFrame.new(v2) * CFrame.new(0, 15, 0) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							0
						)
						Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")

						for _, effect in pairs(clone3:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = true
							end
						end

						clone3.SpinTrail2.Motor6D.C1 = CFrame.new(
							math.random(-10, 10) / 2,
							math.random(-10, 10) / 2,
							-(100 + math.random(-25, 50))
						)
						TweenService:Create(
							clone3.SpinTrail2.Motor6D,
							TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0.6),
							{
								C1 = CFrame.new(0, 0, 0)
							}
						):Play()
						local v4 = math.random(1, 3)

						if v4 == 1 then
							clone3.Trail.Color = ColorSequence.new(
								Util.WrapColor3Constructor(
									Color3.fromRGB(114, 248, 248),
									player,
									"LightningFruitVFXColor"
								),
								Util.WrapColor3Constructor(
									Color3.fromRGB(61, 252, 255),
									player,
									"LightningFruitVFXColor"
								)
							)
						elseif v4 == 2 then
							clone3.Trail.Color = ColorSequence.new(
								Util.WrapColor3Constructor(
									Color3.fromRGB(57, 218, 221),
									player,
									"LightningFruitVFXColor"
								),
								Util.WrapColor3Constructor(
									Color3.fromRGB(96, 252, 255),
									player,
									"LightningFruitVFXColor"
								)
							)
						elseif v4 == 3 then
							clone3.Trail.Color = ColorSequence.new(
								Util.WrapColor3Constructor(
									Color3.fromRGB(64, 239, 255),
									player,
									"LightningFruitVFXColor"
								),
								Util.WrapColor3Constructor(
									Color3.fromRGB(128, 255, 251),
									player,
									"LightningFruitVFXColor"
								)
							)
						end

						local v5 = math.random(5, 12) * 10
						clone3.SpinTrail2.Attach0.Position = Vector3.new(v5, 0, 0)
						clone3.SpinTrail2.Attach1.Position = Vector3.new(-v5, 0, 0)
						clone3.Trail.Lifetime = math.random(15, 25) / 150
						v3[clone3] = math.random(14, 17)
						local v6 = math.random(80, 120)

						for _ = 1, 10 do
							local tween = TweenService:Create(
								clone3,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone3.CFrame * CFrame.new(0, math.random(1, 5), 0) * CFrame.Angles(
										0,
										math.rad(v6),
										0
									)
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end
					end)
				end

				task.wait(1)

				for k, _ in pairs(v3) do
					k.Weld.Enabled = false
					k.Anchored = true
					k.Trail.Enabled = false
				end
			end)
			local clone3 = clone2.Before:Clone()
			clone3.CFrame = CFrame.new(v2) * CFrame.Angles(0, 0, -1.5707963267948966)
			Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")

			for _, emitter in pairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v3 = emitter
				task.spawn(function()
					v3.Enabled = true
					task.wait(0.5)
					v3.Enabled = false
				end)
			end

			task.wait(0.4)
			local clone4 = clone2.ExplosionStart:Clone()
			clone4:PivotTo(CFrame.new(v2) * CFrame.new(0, 15, 0))
			Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")

			for _, emitter in pairs(clone4:GetDescendants()) do
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

			DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown
			task.wait(0.15)
			local clone5 = clone2.Explosion:Clone()
			clone5.CFrame = clone4.CFrame
			Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")

			for _, emitter in pairs(clone5:GetDescendants()) do
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
		Util.Sound:Play("BF_Thunder_X_Lightning_SuperBeam_V2_04", targetPosition)
		local clone3 = assets.Phase1.Explosion:Clone()
		local model3 = Instance.new("Model")
		clone3.Parent = model3
		model3:ScaleTo(SIZE_AND_HITBOX_MULTIPLIER)
		clone3.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")

		for _, emitter in pairs(clone3:GetDescendants()) do
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

		task.wait(0.15)
		task.spawn(function()
			for _ = 1, 5 do
				task.spawn(function()
					local v3 = math.random(10, 50) / 100
					task.wait(v3)
					local clone4 = clone2.TrailModel:Clone()
					clone4:PivotTo(cFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
						0,
						25 + math.random(-25, 50),
						0
					))
					Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
					clone4:ScaleTo(math.random(20, 25))
					local start = clone4.Start
					local trail = clone4.Trail
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

					for _, effect in pairs(clone4:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
							continue
						end

						local v4 = effect
						task.spawn(function()
							v4.Enabled = false
							task.wait(math.random(5, 15) / 100)
							v4.Enabled = true
						end)
						local v5 = effect
						task.delay(2 - v3, function()
							v5.Enabled = false
						end)
					end

					task.wait(2 - v3)
					angularVelocity.Enabled = false
					task.wait(2)
					clone4:Destroy()
				end)
			end
		end)
		task.spawn(function()
			local clone4 = clone2.SpinSlash:Clone()
			clone4:PivotTo(cFrame * CFrame.new(0, 30 + math.random(-15, 15), 0))
			Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
			local model4 = clone4.Model

			for i = 1, 10 do
				local v3 = i * 2 + 15
				local clone5 = model4:Clone()
				clone5:ScaleTo(v3)
				local primaryPart = clone5.PrimaryPart
				local v4 = clone4.PrimaryPart.CFrame * CFrame.new(0, v3, 0) * CFrame.Angles(
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
				clone5:PivotTo(v4)
				Util.SetParentOverrideWithColor(clone5, clone4, player, "LightningFruitVFXColor")
				clone5:GetScale()
				local folder2 = clone5
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
					task.wait(0.25 * math.random() + 2)

					for i2, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.25 + math.random() * 0.15), {
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

			model4:Destroy()
			task.spawn(function()
				local scale = clone4:GetScale()
				local v3 = scale * 1.5

				for i = scale * 100, v3 * 100, 5 do
					clone4:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)
		local v3 = tick() + 2
		local clone4 = assets.Phase1.CloudModel:Clone()
		clone4:PivotTo(CFrame.new(targetPosition) * CFrame.new(0, 225, 0))
		Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
		clone4:ScaleTo(1 * SIZE_AND_HITBOX_MULTIPLIER)

		for _, descendant in pairs(clone4:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				local v4 = descendant
				task.spawn(function()
					v4:Emit(1)
					v4.Enabled = true
					local v5 = v4.Lifetime.Min * 0.75
					task.wait(2 - v5)
					v4.Enabled = false
				end)
			elseif descendant:IsA("MeshPart") then
				local v4 = TweenService:Create(
					descendant,
					TweenInfo.new(
						0.25 + math.random() * 0.5,
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
				local v5 = descendant
				task.spawn(function()
					task.wait(2)
					v4 = TweenService:Create(
						v5,
						TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
				end)
			end
		end

		task.wait(0.5)
		task.spawn(function()
			local clone5 = clone.ProjectileStartImpact:Clone()
			clone5.CFrame = cFrame * CFrame.new(0, -25, 0)
			Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")

			for _, emitter in pairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone6 = clone.Projectile:Clone()
			clone6.CFrame = clone5.CFrame
			Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
			TweenService:Create(clone6, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				CFrame = CFrame.new(v2)
			}):Play()

			for _, emitter in pairs(clone6:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.wait(0.1275)

			for _, emitter in pairs(clone6:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		task.spawn(function()
			local clone5 = clone.Beam:Clone()
			clone5.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone5, workspace, player, "LightningFruitVFXColor")
			clone5.PartB.Motor6D.C0 = CFrame.new(0, 0, 0)
			local magnitude = (v2 - cFrame.Position).Magnitude
			TweenService:Create(
				clone5.PartB.Motor6D,
				TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					C0 = CFrame.new(0, magnitude, 0)
				}
			):Play()

			for _, emitter in pairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.wait(0.1275)
			clone5.PartB.Attachment.Particle_1.Enabled = false
			clone5.PartB.Attachment.Particle_2.Enabled = false
			clone5.PartB.Attachment.Particle_4.Enabled = false
			task.spawn(function()
				local clone6 = clone.GroundCrack:Clone()
				clone6.CFrame = CFrame.new(v2)
				Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")

				for _, emitter in pairs(clone6:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v4 = emitter
					task.spawn(function()
						if v4:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v4:GetAttribute("EmitDelay"))
						end

						v4:Emit(v4:GetAttribute("EmitCount"))
					end)
				end

				DeleteImpactAfterDuration(clone6) -- equivalent call inferred; original call site unknown
			end)
			local clone6 = clone.BeamPillarPart:Clone()
			clone6:PivotTo(CFrame.new(v2))
			Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")

			for _, descendant in pairs(clone6:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = true
				elseif descendant:IsA("Beam") then
					descendant.Enabled = true
				elseif descendant:IsA("BasePart") and descendant.Transparency ~= 1 then
					local tween = TweenService:Create(
						descendant,
						TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Size = descendant.Size
						}
					)
					descendant.Size = Vector3.new(descendant.Size.X, 0, 0)
					tween:Play()
				end
			end

			task.wait(1)

			for _, effect in pairs(clone5:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				elseif effect:IsA("Beam") then
					TweenService:Create(effect, TweenInfo.new(0.25), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end
			end

			for _, descendant in pairs(clone6:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				elseif descendant:IsA("Beam") then
					TweenService:Create(descendant, TweenInfo.new(0.25), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				elseif descendant:IsA("BasePart") and descendant.Transparency ~= 1 then
					TweenService:Create(
						descendant,
						TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(descendant.Size.X, 0, 0)
						}
					):Play()
					local v4 = descendant
					task.delay(0.5, function()
						v4:Destroy()
					end)
				end
			end
		end)
		task.spawn(function()
			local raycastResult = workspace:Raycast(
				v2 + createVector(0, 1, 0),
				createVector(-0, -10, -0),
				raycastParams
			)

			if raycastResult then
				task.wait(0.15)
				local v4 = CFrame.new(raycastResult.Position) * CFrame.new(0, 50, 0)

				for _ = 1, 10 do
					task.spawn(function()
						local clone5 = clone.Rock:Clone()
						clone5.CFrame = v4 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
						Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")
						clone5.CFrame = clone5.CFrame * CFrame.new(0, 0, -100) * CFrame.Angles(
							math.rad(90 + math.random(-5, 5)),
							0,
							0
						)
						clone5.Size = Vector3.new(math.random(2, 7) * 3, math.random(1, 3) * 3, math.random(2, 7) * 3)
						clone5.Anchored = false
						clone5.Material = raycastResult.Instance.Material
						clone5.Color = raycastResult.Instance.Color
						clone5.AngularVelocity.AngularVelocity = Vector3.new(
							math.random(-15, 15),
							math.random(-15, 15),
							math.random(-15, 15)
						)
						clone5.AngularVelocity.Enabled = true
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(7000000, 7000000, 7000000)
						bodyVelocity.P = 5000
						Util.SetParentOverrideWithColor(bodyVelocity, clone5, player, "LightningFruitVFXColor")
						local v5 = math.random(100, 200)
						task.delay(math.random(5, 20) / 50, function()
							bodyVelocity:Destroy()
						end)
						bodyVelocity.Velocity = clone5.CFrame.LookVector * v5
						task.delay(0.25, function()
							clone5.CanCollide = true
						end)
						task.wait(math.random() * 0.5)
						clone5.AngularVelocity.Enabled = false
						task.wait(math.random() * 0.5)
						TweenService:Create(clone5, TweenInfo.new(0.5 + math.random() * 0.25), {
							Size = createVector(0, 0, 0)
						}):Play()
					end)
				end

				local _ = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
				local v5 = {
					Radius = 75,
					Size = 18,
					Duration = 1.5,
					Amount = 30,
					RockType = assets.CraterRock,
					Offset = 25
				}
				task.spawn(function()
					RockCrater(raycastResult, folder, v5, raycastParams) -- equivalent call inferred; original call site unknown
				end)
				local clone5 = clone.ThunderImpact:Clone()
				clone5.CFrame = CFrame.new(v2) * CFrame.new(0, 300, 0)
				Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")
				local v6 = 150 * SIZE_AND_HITBOX_MULTIPLIER
				local now = tick()
				local now2 = tick()
				local now3 = tick()

				repeat
					for _ = 1, math.random(1, 2) do
						task.spawn(function()
							local clone6 = assets.Phase3.Rock:Clone()
							clone6.CFrame = v4 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
							Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
							clone6.CFrame = clone6.CFrame * CFrame.new(
								0,
								math.random(0, 40) * SIZE_AND_HITBOX_MULTIPLIER,
								-100
							) * CFrame.Angles(math.rad(90 + math.random(-5, 5)), 0, 0)
							clone6.Size = Vector3.new(
								math.random(2, 7) * 2,
								math.random(1, 3) * 2,
								math.random(2, 7) * 2
							)
							clone6.Anchored = false
							clone6.Material = raycastResult.Instance.Material
							clone6.Color = raycastResult.Instance.Color
							rocks:ApplyCollision(clone6, nil, true)
							clone6.AngularVelocity.AngularVelocity = Vector3.new(
								math.random(-15, 15),
								math.random(-15, 15),
								math.random(-15, 15)
							)
							clone6.AngularVelocity.Enabled = true
							local bodyVelocity = Instance.new("BodyVelocity")
							bodyVelocity.MaxForce = createVector(70000000, 70000000, 70000000)
							bodyVelocity.P = 10000
							Util.SetParentOverrideWithColor(bodyVelocity, clone6, player, "LightningFruitVFXColor")
							local v7 = math.random(80, 200)
							local v8 = v3 - tick()
							task.delay(v8 / 50, function()
								bodyVelocity:Destroy()
							end)
							bodyVelocity.Velocity = clone6.CFrame.LookVector * v7
							task.delay(0.25, function()
								clone6.CanCollide = true
							end)
							task.wait(math.random() * v8 / 2)
							clone6.AngularVelocity.Enabled = false
							task.wait(math.random() * v8 / 2)
							TweenService:Create(clone6, TweenInfo.new(0.5 + math.random() * 0.25), {
								Size = createVector(0, 0, 0)
							}):Play()
						end)
					end

					if now - tick() <= 0 then
						now = tick() + 0.065

						for _ = 1, math.random(1, 4) do
							task.spawn(function()
								local clone6 = FX:WaitForChild("Lightning2").XCharged.Part:Clone()
								clone6.CFrame = cFrame * CFrame.new(
									math.random(-150, 150) * SIZE_AND_HITBOX_MULTIPLIER,
									0,
									math.random(-150, 150) * SIZE_AND_HITBOX_MULTIPLIER
								)
								Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
								clone6.Attach1.Position = createVector(0, -300, 0)
								clone6.Size *= SIZE_AND_HITBOX_MULTIPLIER
								local shafiBolt1 = ShafiBolt1(
									player,
									clone6.Attach0,
									clone6.Attach1,
									math.random(15, 30),
									math.random(3, 5),
									folder
								)
								task.wait(0.15 * math.random() + 0.1)
								shafiBolt1:Destroy()
							end)
						end
					end

					if now2 - tick() <= 0 then
						now2 = tick() + 0.05
						task.spawn(function()
							for _ = 1, math.random(1, 2) do
								task.wait(0.025 * math.random())
								local v7 = math.random(-v6, v6)
								local v8 = math.random(-v6, v6)
								local v9 = v2 + Vector3.new(v7, 0, v8)
								math.random(1, 6)
								local clone6 = clone.Thunder:Clone()
								clone6.CFrame = CFrame.new(v9)
								Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
								DeleteImpactAfterDuration(clone6) -- equivalent call inferred; original call site unknown
								local v10 = clone6.Attachment["Particle_" .. math.random(
									1,
									#clone6.Attachment:GetChildren()
								)]
								v10:Emit(v10:GetAttribute("EmitCount"))
								task.spawn(function()
									clone5.CFrame = CFrame.new(v9) * CFrame.new(0, 300, 0)

									for i, emitter in pairs(clone5:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter:Emit(emitter:GetAttribute("EmitCount"))
										end
									end
								end)
							end
						end)
					end

					if now3 - tick() <= 0 then
						now3 = tick() + 0.15
						local v7 = math.random(8, 10)
						local v8 = 360 / v7

						for i = 1, v7 do
							local v9 = v8
							local v10 = i
							task.spawn(function()
								local clone6 = FX:WaitForChild("Lightning2").XCharged.Part:Clone()
								clone6.CFrame = CFrame.new(v2) * CFrame.new(0, 5, 0) * CFrame.Angles(
									0,
									math.rad(v9 * v10),
									0
								)
								Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
								clone6.Attach1.Position = createVector(0, 0, -200)
								clone6.Size *= SIZE_AND_HITBOX_MULTIPLIER
								local shafiBolt2 = ShafiBolt2(
									player,
									clone6.Attach0,
									clone6.Attach1,
									math.random(10, 15),
									math.random(2, 5),
									folder
								)
								task.wait(0.15 * math.random() + 0.25)
								shafiBolt2:Destroy()
							end)
						end
					end

					task.wait(0.015 + math.random() * 0.015)
				until v3 - tick() <= 0.25
			end
		end)
		task.spawn(function()
			task.wait(0.15)

			for _ = 1, 8 do
				local clone5 = clone.Spike:Clone()
				local _ = clone5.PrimaryPart
				Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")
				clone5:PivotTo(CFrame.new(v2) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
					0,
					0,
					-175 + math.random(35, 50)
				) * CFrame.Angles(-0.4363323129985824, 0, 0))
				clone5:ScaleTo(math.random(25, 50) / 10)

				for _, emitter in pairs(clone5:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end
		end)
		task.spawn(function()
			task.wait(0.12)
			local clone5 = clone.SpinSlash:Clone()
			clone5:PivotTo(CFrame.new(v2) * CFrame.new(0, 10, 0))
			Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")
			local model4 = clone5.Model

			for i = 1, 3 do
				local v4 = i * 1.1 + 3.85
				local clone6 = model4:Clone()
				clone6:ScaleTo(v4)
				local primaryPart = clone6.PrimaryPart
				local v5 = clone5.PrimaryPart.CFrame * CFrame.new(0, v4, 0) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				)
				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.Position + Vector3.new(
					math.random(-10, 10) / 10,
					i * 65,
					math.random(-10, 10) / 10
				)
				angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15) * 2, 0)
				clone6:PivotTo(v5)
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
							TweenService:Create(effect, TweenInfo.new(0.25 + math.random() * 0.15), {
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

			model4:Destroy()
			task.spawn(function()
				local scale = clone5:GetScale()
				local v4 = scale * 1.5

				for i = scale * 100, v4 * 100, 5 do
					clone5:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)
	end
end