local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local TweenService = game:GetService("TweenService")
local TokenKit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)

function BlurEffect(value)
	local blurEffect = Instance.new("BlurEffect")
	local lighting = game.Lighting
	blurEffect.Size = 5
	blurEffect.Parent = lighting
	DebrisModule:AddItem(blurEffect, value or 0.08333333333333333)
end

return function(instance, p: string, instance2)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or vector.magnitude(humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position) > 200 and p ~= "Cancel" then
		return
	end

	local spiral = humanoidRootPart:FindFirstChild("Spiral")

	if spiral ~= nil then
		vfxUtility.EnableAll(spiral, false)
		spiral.Name = "--"
		DebrisModule:AddItem(spiral, 1.5)
	end

	if p == "Start" then
		local formatted = `{script.Name}-{"Start"}`
		local child = game.Workspace.Debree:FindFirstChild(formatted)

		if child ~= nil then
			child:Destroy()
		end

		local configuration = Instance.new("Configuration")
		configuration.Name = formatted
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 5)
		local clone = script.PS2stoneULTspinswing:Clone()
		clone.Parent = humanoidRootPart
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
		local clone2 = script.SpinSlash:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame)
		clone2.Parent = configuration
		local color = nil
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			color = raycastResult.Instance.Color
			vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(color)))
		else
			vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
		end

		TweenService:Create(clone2.Slash1, TweenInfo.new(0.2), {
			CFrame = clone2.Slash1.CFrame * CFrame.Angles(-3.3161255787892263, 0, 0)
		}):Play()
		TweenService:Create(clone2.Slash2, TweenInfo.new(0.2), {
			CFrame = clone2.Slash2.CFrame * CFrame.Angles(-3.3161255787892263, 0, 0)
		}):Play()
		TweenService:Create(clone2.Slash3, TweenInfo.new(0.2), {
			CFrame = clone2.Slash3.CFrame * CFrame.Angles(-3.3161255787892263, 0, 0)
		}):Play()
		task.delay(0.15, function()
			for _, beam in clone2:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				TweenService:Create(beam, TweenInfo.new(0.1), {
					TextureLength = 0
				}):Play()
				local v = beam
				task.delay(0.05, function()
					TweenService:Create(v, TweenInfo.new(0.05), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			end
		end)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.3,
			SustainTime = 0.2,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local clone3 = script.Attachments.Spiral:Clone()
		clone3.Parent = humanoidRootPart
		vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone3, 12)
		local clone4 = nil
		local clone5 = nil
		local isAxeAndMaceWeapon = instance:FindFirstChild("IsAxeAndMaceWeapon", true)

		if isAxeAndMaceWeapon ~= nil then
			local ball = isAxeAndMaceWeapon.Parent.RootPart.Ball
			local axe = isAxeAndMaceWeapon.Parent.RootPart.Axe

			if ball ~= nil and axe ~= nil then
				clone4 = script.Attachments.SpikeSpin:Clone()
				clone4.Parent = ball
				vfxUtility.EnableAll(clone4, true, vfxUtility.Owned(instance))
				clone5 = script.Attachments.AxeTrail:Clone()
				clone5.Parent = axe
				vfxUtility.EnableAll(clone5, true, vfxUtility.Owned(instance))
				task.delay(0.15, function()
					for _, beam in clone4:GetDescendants() do
						if not beam:IsA("Beam") then
							continue
						end

						TweenService:Create(beam, TweenInfo.new(0.3), {
							TextureLength = 0
						}):Play()
						local v = beam
						task.delay(0.05, function()
							TweenService:Create(v, TweenInfo.new(0.3), {
								Width0 = 0,
								Width1 = 0
							}):Play()
						end)
					end
				end)
			end
		end

		local clone6 = script.Attachments.Roootate:Clone()
		clone6.Parent = humanoidRootPart
		DebrisModule:AddItem(clone6, 12)
		vfxUtility.EnableAll(clone6, true, vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(color)))
		task.spawn(function()
			local cam_Shaker = Cam_Shaker(clone3, {
				FadeInTime = 0.2,
				Frequency = 0.25,
				Amplitude = 0.3,
				SustainTime = 4,
				FadeOutTime = 0.1,
				RotationInfluence = createVector(0.15, 0.15, 0.15),
				PositionInfluence = createVector(0.5, 0.5, 0.5)
			})
			local clone7 = script.PS2stoneULTspinloop:Clone()
			clone7.Parent = clone3
			clone7:Play()

			while clone3 ~= nil and clone3.Parent ~= nil and clone3.Name ~= "--" do
				TweenService:Create(clone6, TweenInfo.new(0.2), {
					CFrame = clone6.CFrame * CFrame.Angles(0, -3.839724354387525, 0)
				}):Play()
				task.wait(0.2)
			end

			TweenService:Create(clone7, TweenInfo.new(1), {
				Volume = 0
			}):Play()
			DebrisModule:AddItem(clone7, 1)
			cam_Shaker:Destroy()
			configuration.Name = "--"
			DebrisModule:AddItem(clone6, 2)
			vfxUtility.EnableAll(clone6, false)
			TweenService:Create(clone6, TweenInfo.new(1), {
				CFrame = clone6.CFrame * CFrame.Angles(0, -3.839724354387525, 0)
			}):Play()

			if clone5 ~= nil then
				vfxUtility.EnableAll(clone5, false)
				DebrisModule:AddItem(clone5, 0.5)
			end

			if clone4 ~= nil then
				vfxUtility.EnableAll(clone4, false)
				DebrisModule:AddItem(clone4, 1)
			end
		end)
	elseif p == "Cutscene" then
		local configuration = Instance.new("Configuration")
		configuration.Name = `{script.Name}-{"Cutscene"}`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 8)
		local clone = script.PS2stoneULTcinematic:Clone()
		clone.Parent = humanoidRootPart
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local color

		if raycastResult and raycastResult.Instance ~= nil then
			color = raycastResult.Instance.Color
		else
			color = nil
		end

		task.spawn(function()
			local clone2 = script.SpinSlash:Clone()
			clone2:PivotTo(humanoidRootPart.CFrame)
			clone2.Parent = configuration
			vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(color)))
			DebrisModule:AddItem(clone2, 3)
			TweenService:Create(clone2.Slash1, TweenInfo.new(0.2), {
				CFrame = clone2.Slash1.CFrame * CFrame.Angles(-2.443460952792061, 0, 0)
			}):Play()
			TweenService:Create(clone2.Slash2, TweenInfo.new(0.2), {
				CFrame = clone2.Slash2.CFrame * CFrame.Angles(-2.443460952792061, 0, 0)
			}):Play()
			TweenService:Create(clone2.Slash3, TweenInfo.new(0.2), {
				CFrame = clone2.Slash3.CFrame * CFrame.Angles(-2.443460952792061, 0, 0)
			}):Play()
			task.delay(0.15, function()
				if clone2 == nil or clone2.Parent == nil then
					return
				end

				for _, v in ipairs(clone2:QueryDescendants("Beam")) do
					TweenService:Create(v, TweenInfo.new(0.1), {
						TextureLength = 0
					}):Play()
					local v2 = v
					task.delay(0.05, function()
						TweenService:Create(v2, TweenInfo.new(0.05), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				end
			end)
			local clone3 = script.Attachments.vicupertors:Clone()
			clone3.Parent = instance2:WaitForChild("UpperTorso")
			DebrisModule:AddItem(clone3, 2)
			vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance))
			vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(color)))
			local isAxeAndMaceWeapon = instance:FindFirstChild("IsAxeAndMaceWeapon", true)

			if isAxeAndMaceWeapon ~= nil then
				local ball = isAxeAndMaceWeapon.Parent.RootPart.Ball
				local axe = isAxeAndMaceWeapon.Parent.RootPart.Axe

				if ball ~= nil and axe ~= nil then
					local clone4 = script.Attachments.SpikeSpin:Clone()
					clone4.Parent = ball
					vfxUtility.EnableAll(clone4, true, vfxUtility.Owned(instance))
					task.wait(0.5)

					if clone4 ~= nil and clone4.Parent ~= nil then
						DebrisModule:AddItem(clone4, 0.5)
						vfxUtility.EnableAll(clone4, false)
					end

					if clone3 ~= nil and clone3.Parent ~= nil then
						DebrisModule:AddItem(clone3, 0.5)
					end
				end
			end

			if clone3 ~= nil and clone3.Parent ~= nil then
				vfxUtility.EnableAll(clone3, false)
			end
		end)
		task.delay(1.05, function()
			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				return
			end

			task.spawn(function()
				local clone2 = script.ColorCorrection1:Clone()
				clone2.Parent = workspace.Camera
				clone2.Enabled = true
				task.wait(0.03333333333333333)
				local clone3 = script.ColorCorrection2:Clone()
				clone3.Parent = workspace.Camera
				clone3.Enabled = true
				clone2.Enabled = false
				task.wait(0.03333333333333333)
				clone2:Destroy()
				clone3:Destroy()
			end)
			BlurEffect(0.3)
			local v = humanoidRootPart.CFrame * CFrame.new(-0.6263427734375, -2.2080020904541016, -15.1466064453125) * CFrame.fromEulerAnglesYXZ(
				2.842170943040401e-14,
				1.514524826729387e-28,
				-1.4210028011045484e-14
			)
			local clone2 = script.MaceHit:Clone()
			clone2.CFrame = v
			clone2.Parent = configuration
			DebrisModule:AddItem(clone2, 4.5)
			OuwCraters.Scales({
				Center = v,
				ScaleMult = 1.45,
				Count = 5,
				Radius = 6.25
			})
			vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(color)))
		end)
		task.delay(2, function()
			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				return
			end

			task.spawn(function()
				local clone2 = script.ColorCorrection1:Clone()
				clone2.Parent = workspace.Camera
				clone2.Enabled = true
				task.wait(0.03333333333333333)
				local clone3 = script.ColorCorrection2:Clone()
				clone3.Parent = workspace.Camera
				clone3.Enabled = true
				clone2.Enabled = false
				task.wait(0.03333333333333333)
				clone2:Destroy()
				clone3:Destroy()
			end)
			local clone2 = script.Slash1:Clone()
			clone2:PivotTo(humanoidRootPart.CFrame)
			clone2.Parent = configuration
			vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone2, 3)
			TweenService:Create(clone2.Slash, TweenInfo.new(0.2), {
				CFrame = clone2.Slash.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			}):Play()
			task.delay(0.1, function()
				if instance2 == nil or instance2.Parent == nil then
					return
				end

				local upperTorso = instance2:WaitForChild("UpperTorso")

				if upperTorso == nil then
					return
				end

				local clone3 = script.HitFx:Clone()
				clone3.CFrame = upperTorso.CFrame
				clone3.Parent = configuration
				vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
				DebrisModule:AddItem(clone3, 2)
			end)
			task.delay(0.15, function()
				if clone2 == nil or clone2.Parent == nil then
					return
				end

				for _, v in ipairs(clone2.Slash:QueryDescendants("Beam")) do
					TweenService:Create(v, TweenInfo.new(0.1), {
						TextureLength = 0
					}):Play()
					local v2 = v
					task.delay(0.05, function()
						TweenService:Create(v2, TweenInfo.new(0.05), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				end
			end)
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.3,
				Amplitude = 0.3,
				SustainTime = 0.2,
				FadeOutTime = 0.1,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
		end)
		task.delay(2.35, function()
			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				return
			end

			task.spawn(function()
				local clone2 = script.ColorCorrection1:Clone()
				clone2.Parent = workspace.Camera
				clone2.Enabled = true
				task.wait(0.03333333333333333)
				local clone3 = script.ColorCorrection2:Clone()
				clone3.Parent = workspace.Camera
				clone3.Enabled = true
				clone2.Enabled = false
				task.wait(0.03333333333333333)
				clone2:Destroy()
				clone3:Destroy()
			end)
			BlurEffect(0.3)
			local clone2 = script.Slash2:Clone()
			clone2:PivotTo(humanoidRootPart.CFrame)
			clone2.Parent = configuration
			vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone2, 3)
			TweenService:Create(clone2.Slash, TweenInfo.new(0.2), {
				CFrame = clone2.Slash.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			}):Play()
			task.delay(0.1, function()
				if instance2 == nil or instance2.Parent == nil then
					return
				end

				local upperTorso = instance2:WaitForChild("UpperTorso")

				if upperTorso == nil or upperTorso.Parent == nil then
					return
				end

				local clone3 = script.HitFx:Clone()
				clone3.CFrame = upperTorso.CFrame
				clone3.Parent = configuration
				vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
				DebrisModule:AddItem(clone3, 2)
			end)
			task.delay(0.15, function()
				if clone2 == nil or clone2.Parent == nil then
					return
				end

				for _, beam in clone2.Slash:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					TweenService:Create(beam, TweenInfo.new(0.1), {
						TextureLength = 0
					}):Play()
					local v = beam
					task.delay(0.05, function()
						TweenService:Create(v, TweenInfo.new(0.05), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				end
			end)
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.3,
				Amplitude = 0.3,
				SustainTime = 0.2,
				FadeOutTime = 0.1,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
		end)
		task.delay(3.25, function()
			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				return
			end

			local clone2 = script.Slash3:Clone()
			clone2:PivotTo(humanoidRootPart.CFrame)
			clone2.Parent = configuration
			vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone2, 3)
			TweenService:Create(clone2.Slash, TweenInfo.new(0.2), {
				CFrame = clone2.Slash.CFrame * CFrame.Angles(-2.443460952792061, 0, 0)
			}):Play()
			task.delay(0.1, function()
				if instance2 == nil or instance2.Parent == nil then
					return
				end

				local upperTorso = instance2:WaitForChild("UpperTorso")

				if upperTorso == nil then
					return
				end

				local clone3 = script.HitFx:Clone()
				clone3.CFrame = upperTorso.CFrame
				clone3.Parent = configuration
				vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
				DebrisModule:AddItem(clone3, 2)
			end)
			task.delay(0.15, function()
				if clone2 == nil or clone2.Parent == nil then
					return
				end

				for _, beam in clone2.Slash:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					TweenService:Create(beam, TweenInfo.new(0.1), {
						TextureLength = 0
					}):Play()
					local v = beam
					task.delay(0.05, function()
						TweenService:Create(v, TweenInfo.new(0.05), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				end
			end)
			local clone3 = script.Attachments.Ballfireattach:Clone()
			clone3.Parent = instance2:WaitForChild("UpperTorso")
			DebrisModule:AddItem(clone3, 1.5)
			vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance))
			task.wait(0.5)
			vfxUtility.EnableAll(clone3, false)
		end)
		task.delay(3.5, function()
			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				return
			end

			task.spawn(function()
				local clone2 = script.ColorCorrection1:Clone()
				clone2.Parent = workspace.Camera
				clone2.Enabled = true
				task.wait(0.03333333333333333)
				local clone3 = script.ColorCorrection2:Clone()
				clone3.Parent = workspace.Camera
				clone3.Enabled = true
				clone2.Enabled = false
				task.wait(0.03333333333333333)
				clone2:Destroy()
				clone3:Destroy()
			end)
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.2,
				SustainTime = 0.3,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})

			if instance2 == nil or instance2.Parent == nil then
				return
			end

			local upperTorso = instance2:WaitForChild("UpperTorso")

			if upperTorso == nil or upperTorso.Parent == nil then
				return
			end

			local clone2 = script.ExtraInduce:Clone()
			clone2.CFrame = upperTorso.CFrame
			clone2.Parent = configuration
			vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone2, 2)
		end)
		task.delay(3.8, function()
			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				return
			end

			local clone2 = script.Smash2:Clone()
			clone2.Parent = configuration
			clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(-0.681, -3.5, -15.077) * CFrame.Angles(-0, 0, -0))
			vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone2, 3)
			task.wait(0.15)

			if humanoidRootPart == nil or humanoidRootPart.Parent == nil then
				return
			end

			task.spawn(function()
				local clone3 = script.ColorCorrection1:Clone()
				clone3.Parent = workspace.Camera
				clone3.Enabled = true
				task.wait(0.03333333333333333)
				local clone4 = script.ColorCorrection2:Clone()
				clone4.Parent = workspace.Camera
				clone4.Enabled = true
				clone3.Enabled = false
				task.wait(0.03333333333333333)
				clone3:Destroy()
				clone4:Destroy()
			end)
			BlurEffect(0.3)
			local clone3 = script.MainImpact:Clone()
			clone3.Parent = configuration
			clone3:PivotTo(humanoidRootPart.CFrame * CFrame.new(-1.18, -3.752, -17.467))
			vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone3, 5)
			TweenService:Create(clone3.RootPart.Light.PointLight, TweenInfo.new(1), {
				Brightness = 20
			}):Play()
			task.delay(1, function()
				TweenService:Create(clone3.RootPart.Light.PointLight, TweenInfo.new(0.4), {
					Brightness = 0
				}):Play()
			end)
			task.delay(0.2, function()
				for _, descendant in ipairs(clone3:GetDescendants()) do
					if descendant.ClassName == "ParticleEmitter" then
						local _ = descendant.TimeScale / 20
					end
				end

				task.wait(0.6)
				vfxUtility.EnableAll(clone3, false)

				for _, descendant in ipairs(clone3:GetDescendants()) do
					if descendant.ClassName == "ParticleEmitter" then
						local _ = descendant.TimeScale * 20
					end
				end
			end)
			task.spawn(function()
				task.wait(0.1)

				for _ = 1, 20 do
					clone3:ScaleTo(clone3:GetScale() + 0.05)
					local raycastResult2 = workspace:Raycast(
						clone2.Position + createVector(0, 2, 0),
						createVector(-0, -7, -0),
						RaycastHelper.Crater
					)

					if raycastResult2 then
						clone3.PrimaryPart.CFrame = CFrame.new(
							raycastResult2.Position,
							raycastResult2.Position - raycastResult2.Normal
						) * CFrame.Angles(1.5707963267948966, 0, 0)
					end

					task.wait(0.06666666666666667)
				end

				task.wait(0.1)
			end)
			local clone4 = script.GroundImpacts:Clone()
			clone4.Parent = configuration
			clone4:PivotTo(clone2.CFrame)
			local raycastResult2 = workspace:Raycast(
				clone4.PrimaryPart.Position + createVector(0, 5, 0),
				createVector(-0, -20, -0),
				RaycastHelper.Crater
			)
			local color2

			if raycastResult2 and raycastResult2.Instance ~= nil then
				clone4.PrimaryPart.CFrame = CFrame.new(
					raycastResult2.Position,
					raycastResult2.Position - raycastResult2.Normal
				) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone4.PrimaryPart.CFrame = clone4.PrimaryPart.CFrame * CFrame.new(0, 3, 0)
				color2 = raycastResult2.Instance.Color
			end

			vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(color2)))
			DebrisModule:AddItem(clone4, 3)
			OuwCraters.Scales({
				Center = clone2.CFrame,
				ScaleMult = 1.25,
				Count = 5,
				Radius = 15,
				OffsetMargin = 7
			})
			task.spawn(function()
				TokenKit.GroundRocks({
					CF = clone2.CFrame,
					InnerRadius = 5,
					OuterRadius = 10,
					Velocity = {
						Min = 5,
						Max = 20
					},
					Amount = 20,
					Size = {
						Min = 0.5,
						Max = 2
					}
				})
			end)
			Cam_Shaker(clone2.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.2,
				SustainTime = 0.3,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
			task.wait(0.3)
			OuwCraters.Scales({
				Center = clone2.CFrame,
				ScaleMult = 1.5,
				Count = 5,
				Radius = 20,
				OffsetMargin = 7
			})
			task.spawn(function()
				TokenKit.GroundRocks({
					CF = clone2.CFrame,
					InnerRadius = 10,
					OuterRadius = 20,
					Velocity = {
						Min = 20,
						Max = 40
					},
					Amount = 20,
					Size = {
						Min = 4,
						Max = 6
					}
				})
			end)
			Cam_Shaker(clone2.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.2,
				SustainTime = 0.3,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
			task.wait(0.3)
			OuwCraters.Scales({
				Center = clone2.CFrame,
				ScaleMult = 2,
				Count = 5,
				Radius = 25,
				OffsetMargin = 7
			})
			task.spawn(function()
				TokenKit.GroundRocks({
					CF = clone2.CFrame,
					InnerRadius = 10,
					OuterRadius = 20,
					Velocity = {
						Min = 20,
						Max = 50
					},
					Amount = 20,
					Size = {
						Min = 1,
						Max = 2
					}
				})
			end)
			Cam_Shaker(clone2.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.2,
				SustainTime = 0.3,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
		end)
	end
end