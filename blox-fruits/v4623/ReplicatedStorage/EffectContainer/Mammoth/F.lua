local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local RocksModule2 = require(game.ReplicatedStorage.Util.RocksModule2)
local FX = require(ReplicatedStorage.FX)

local function debrisPart(hit, position, normal)
	local v = math.random(75, 108) / 10
	local v2 = math.random(43, 76) / 10
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 5)
	part.Material = hit.Material
	part.Transparency = hit.Transparency
	part.Reflectance = hit.Reflectance
	part.Color = hit.Color
	part.Size = Vector3.new(v, v2, v)
	part.CFrame = CFrame.new(position, position + normal) * CFrame.Angles(
		math.rad((math.random(-35, 35))),
		math.rad((math.random(-35, 35))),
		(math.rad((math.random(-35, 35))))
	)
	part.CanCollide = false
	part.Parent = _WorldOrigin
	part.Velocity = part.CFrame.lookVector.Unit * Vector3.new(
		math.random(250, 370),
		math.random(70, 100),
		math.random(250, 370)
	)
	part.RotVelocity = Vector3.new(math.random(-7, 7), math.random(-7, 7), math.random(-7, 7))
	part.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	return part
end

local function TimeScaleParticle(instance, p)
	instance.Drag *= p
	instance.Speed = NumberRange.new(instance.Speed.Min * p, instance.Speed.Max * p)
	instance.Lifetime = NumberRange.new(instance.Lifetime.Min / p, instance.Lifetime.Max / p)
	instance.Rate *= p
	instance.RotSpeed = NumberRange.new(instance.RotSpeed.Min * p, instance.RotSpeed.Max * p)
	instance.Acceleration *= p ^ 2

	if instance:GetAttribute("EmitDelay") then
		instance:SetAttribute("EmitDelay", instance:GetAttribute("EmitDelay") / p)
	end
end

local mammoth = FX:WaitForChild("Mammoth")

local function LEAP(plr, hrp, stage, holdValue, cf, id, groundData)
	local clone, clone2

	if cf then
		clone = _WorldOrigin:FindFirstChild("FormEmit" .. id)
		clone2 = _WorldOrigin:FindFirstChild("FloorCharge" .. id)

		if not (clone and clone2) then
			clone = mammoth.FormEmit:Clone()
			clone.Name ..= id
			clone2 = mammoth.FloorCharge:Clone()
			clone2.Name ..= id
			clone2.CFrame = cf
			clone.CFrame = cf
			clone2.Parent = _WorldOrigin
			clone.Parent = _WorldOrigin
			Util.Debris:AddItem(clone, 15)
			Util.Debris:AddItem(clone2, 15)
		end
	else
		clone2 = nil
	end

	local lookVector = hrp.CFrame.LookVector
	local v = hrp.Position + lookVector * 1
	local rayMap, v2, v3 = Util.RayMap(v, createVector(0, -80, 0))

	if rayMap and clone then
		clone.CFrame = CFrame.new(v2, v2 + v3) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone.Parent = _WorldOrigin
		local descendants = clone:GetDescendants()
		local v4 = {}

		for k, emitter in pairs(descendants) do
			if emitter:IsA("ParticleEmitter") then
				v4[k] = {
					count = emitter:GetAttribute("EmitCount") or 0,
					delay = emitter:GetAttribute("EmitDelay") or 0
				}
			end
		end

		for k, descendant in pairs(descendants) do
			local v5 = k
			local v6 = descendant
			task.spawn(function()
				if v4[v5] then
					task.wait(v4[v5].delay)
					v6:Emit(v4[v5].count)
				end
			end)
		end
	end

	local mammothAccessoryJUMP = plr.Character:FindFirstChild("MammothAccessoryJUMP")
	local mammothSilhouette, body

	if mammothAccessoryJUMP then
		mammothSilhouette = mammothAccessoryJUMP:FindFirstChild("MammothSilhouette")

		if not mammothSilhouette then
			return
		end

		body = mammothSilhouette:FindFirstChild("body")

		if not body then
			return
		end
	else
		local mammoth2 = FX:WaitForChild("Mammoth")
		local accessory = Instance.new("Accessory")
		accessory.Name = "MammothAccessoryJUMP"
		mammothSilhouette = mammoth2.MammothSilhouette:Clone()
		local primaryPart = mammothSilhouette.PrimaryPart
		body = mammothSilhouette.body
		local _ = mammothSilhouette.AnimationController
		primaryPart.CFrame = hrp.CFrame
		mammothSilhouette.Parent = accessory
		local motor6D = Instance.new("Motor6D")
		motor6D.Part0 = primaryPart
		motor6D.Part1 = hrp
		motor6D.C0 = motor6D.Part1.CFrame:inverse()
		motor6D.C1 = motor6D.Part1.CFrame:inverse() * CFrame.new(0, -8, 0)
		motor6D.Name = "RigWeld"
		motor6D.Parent = primaryPart
		accessory.Parent = hrp.Parent
	end

	if stage == 1 then
		for _, part in pairs(mammothSilhouette:GetChildren()) do
			if part:IsA("MeshPart") and part.Name ~= "eye" then
				TweenService:Create(
					part,
					TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, false, 0),
					{
						Transparency = 0
					}
				):Play()
			end
		end

		for _, v4 in pairs({
			mammothSilhouette.eyeL.EyeL.Eye,
			mammothSilhouette.eyeL.EyeL.EYEGLOW,
			mammothSilhouette.eyeR.EyeR.Eye,
			mammothSilhouette.eyeR.EyeR.EYEGLOW
		}) do
			local v5 = v4
			task.delay(0.2, function()
				if v5.Name == "Eye" then
					v5.Enabled = true
				elseif v5.Name == "EYEGLOW" then
					v5:Emit(3)
				end
			end)
		end

		local mammothChargeJump = Util.Anims:Get(mammothSilhouette, "MammothChargeJump")

		for _, part in pairs(mammothSilhouette:GetChildren()) do
			if part:IsA("MeshPart") and part.Name ~= "eye" then
				TweenService:Create(
					part,
					TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, false, 0),
					{
						Transparency = 0
					}
				):Play()
			end
		end

		for _, v4 in pairs({
			mammothSilhouette.eyeL.EyeL.Eye,
			mammothSilhouette.eyeL.EyeL.EYEGLOW,
			mammothSilhouette.eyeR.EyeR.Eye,
			mammothSilhouette.eyeR.EyeR.EYEGLOW
		}) do
			local v5 = v4
			task.delay(0.2, function()
				if v5.Name == "Eye" then
					v5.Enabled = true
				elseif v5.Name == "EYEGLOW" then
					v5:Emit(3)
				end
			end)
		end

		mammothChargeJump.Priority = Enum.AnimationPriority.Action
		mammothChargeJump:Play()
		local flag = false
		task.spawn(function()
			local lookVector2 = plr.Character.PrimaryPart.CFrame.LookVector
			local v4 = hrp.Position + lookVector2 * 1
			local rayMap2, v5, v6 = Util.RayMap(v4, createVector(0, -15, 0))

			if not (rayMap2 and clone2) then
				body.PrepareJumpIN.dust:Destroy()
				return
			end

			body.PrepareJumpIN.dust.Color = ColorSequence.new(rayMap2.Color)
			clone2.CFrame = CFrame.new(v5, v5 + v6) * CFrame.Angles(-1.5707963267948966, 0, 0)
			TweenService:Create(
				clone2,
				TweenInfo.new(0.62, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 0, false, 0),
				{
					Size = createVector(30, 0.03, 30)
				}
			):Play()
			TweenService:Create(
				clone2.Decal,
				TweenInfo.new(0.64, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 0, false, 0),
				{
					Transparency = 0.2
				}
			):Play()
			task.delay(1.25, function()
				if not holdValue.Value or not holdValue:IsDescendantOf(workspace) or flag then
					return
				end

				if plr == game.Players.LocalPlayer then
					Util.CameraShaker:ShakeOnce(10, 11, 0, 0.3, createVector(1, 1, 1), createVector(1, 1, 1))
				end

				RocksModule2.Ground(
					clone2.Position + createVector(0, 1, 0),
					28,
					createVector(5, 3, 5),
					nil,
					15,
					false,
					1.1
				)
				TweenService:Create(
					clone2.Decal2,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
					{
						Color3 = Color3.new(0, 0, 0)
					}
				):Play()
				TweenService:Create(
					clone2,
					TweenInfo.new(0.12, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
					{
						Size = createVector(45, 0.03, 45)
					}
				):Play()
				Util.Sound:Play("MammothCraterIncrease", hrp, 20, 1 + math.random(-19, -5) / 100, 5)
				clone2.ForceLines:Emit(25)
				clone2.Decal.Transparency = 1
				clone2.Decal2.Transparency = 0.2
				TweenService:Create(
					clone2.Decal,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
					{
						Transparency = 0.5
					}
				):Play()
			end)
			task.delay(2.5, function()
				if not holdValue.Value or not holdValue:IsDescendantOf(workspace) or flag then
					return
				end

				RocksModule2.Ground(
					clone2.Position + createVector(0, 1, 0),
					36,
					createVector(8, 5, 8),
					nil,
					18,
					false,
					3
				)
				Util.Sound:Play("MammothCraterIncrease", hrp, 20, 1 + math.random(-19, -5) / 100, 2.5)
				clone2.ForceLinesRED:Emit(25)
				TweenService:Create(
					clone2.Decal3,
					TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
					{
						Color3 = Color3.new(0, 0, 0)
					}
				):Play()
				TweenService:Create(
					clone2,
					TweenInfo.new(0.12, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
					{
						Size = createVector(55, 0.03, 55)
					}
				):Play()
				clone2.Decal2.Transparency = 1
				clone2.Decal3.Transparency = 0.2
			end)
			mammothChargeJump.Priority = Enum.AnimationPriority.Action
			mammothChargeJump:Play()
		end)
		local descendants = body.PrepareJumpIN:GetDescendants()
		local v4 = {}

		for _, descendant in pairs(descendants) do
			v4[descendant] = {
				count = descendant:GetAttribute("EmitCount") or 0,
				delay = descendant:GetAttribute("EmitDelay") or 0
			}
		end

		task.spawn(function()
			while holdValue.Value and holdValue:IsDescendantOf(workspace) do
				wait(0.095)

				for _, descendant in pairs(descendants) do
					if v4[descendant].delay > 0 then
						local v5 = descendant
						task.spawn(function()
							task.wait(v4[v5].delay)
							v5:Emit(v4[v5].count)
						end)
					else
						descendant:Emit(v4[descendant].count)
					end
				end
			end

			flag = true
		end)

		if plr == game.Players.LocalPlayer then
			task.spawn(function()
				while holdValue.Value do
					task.wait(0.14)
					Util.CameraShaker:ShakeOnce(
						2,
						2,
						0.1,
						0.5,
						createVector(0.4, 0.4, 0.4),
						createVector(0.4, 0.4, 0.4)
					)
				end
			end)
		end
	elseif stage == 2 then
		local mammothChargeJump = Util.Anims:Get(mammothSilhouette, "MammothChargeJump")
		local jump = body.Jump
		jump.Parent = workspace.Terrain
		jump.CFrame = cf or CFrame.new(hrp.Position)
		Util.Debris:AddItem(jump, 2.5)

		for _, child in pairs(jump:GetChildren()) do
			if not (child.SpreadAngle.X < 10) or clone2 then
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end

		if plr == game.Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(12, 15, 0, 1, createVector(1, 1, 1), createVector(1, 1, 1))
		end

		Util.Sound:Play("MammothBlast", hrp.Position, 20, 1 + math.random(-10, 10) / 100, 1.65)
		Util.Sound:Play("MammothFly", hrp, 20, 1 + math.random(-10, 10) / 100, 1.65)

		if clone2 then
			for _, descendant in pairs(clone2:GetDescendants()) do
				if descendant:IsA("Decal") then
					TweenService:Create(descendant, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				elseif descendant:IsA("MeshPart") then
					TweenService:Create(
						descendant,
						TweenInfo.new(2, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
						{
							Position = descendant.Position + createVector(0, -3, 0),
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
				end
			end
		end

		if clone then
			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		for _, v4 in pairs({ mammothSilhouette.body.Swirl, mammothSilhouette.body.Swirl2 }) do
			v4.Enabled = true
			TweenService:Create(v4, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Width1 = 12,
				Width0 = 100
			}):Play()
		end

		if mammothChargeJump then
			mammothChargeJump:Stop()
		end

		body.PrepareJumpV2.Crescents.Enabled = false
		local mammothJump = Util.Anims:Get(mammothSilhouette, "MammothJump")
		mammothJump.Priority = Enum.AnimationPriority.Action2
		mammothJump:Play()
		local mammothFall = Util.Anims:Get(mammothSilhouette, "MammothFall")
		mammothFall.Priority = Enum.AnimationPriority.Movement
		mammothFall.Looped = true
		mammothFall:Play()
		task.spawn(function()
			wait(1.2)
			mammothFall:Stop()
		end)
		Util.Debris:AddItem(mammothSilhouette, 4)
		mammothSilhouette.body.exp:Destroy()
		local exp = mammothSilhouette.exp
		body.Fly.Parent = exp
		exp.Anchored = true
		exp.Size = createVector(18, 18, 18)
		exp.Sparks2.VelocityInheritance = 0
		exp.Sparks3.VelocityInheritance = 0
		exp.Fly.ringbig2.VelocityInheritance = 0
		exp.Fly.shadow1.VelocityInheritance = 0
		exp.Fly.CFrame = CFrame.new()
		exp.Fly.ringbig2.Speed = NumberRange.new(1, 3)
		exp.Fly.shadow1.Speed = NumberRange.new(1, 3)
		exp.Sparks2.EmissionDirection = "Front"
		exp.Sparks3.EmissionDirection = "Front"
		exp.Sparks2.Shape = "Box"
		exp.Sparks2.ShapeInOut = "Inward"
		exp.Sparks2.ShapeStyle = "Volume"
		exp.Sparks3.Shape = "Box"
		exp.Sparks3.ShapeInOut = "Inward"
		exp.Sparks3.ShapeStyle = "Volume"
		task.defer(function()
			local lastTime = tick()
			local now = 0

			while tick() - lastTime < 0.45 do
				exp.CFrame = hrp.CFrame * CFrame.new(0, 3, -9)

				if tick() - now > 0.015873015873015872 then
					exp.Fly.ringbig2:Emit(2)
					exp.Fly.shadow1:Emit(1)
					exp.Sparks3:Emit(2)
					exp.Sparks2:Emit(2)
					now = tick()
				end

				task.wait()
			end
		end)
	elseif stage == 3 then
		for _, child in pairs(body.PrepareJumpIN:GetChildren()) do
			TimeScaleParticle(child, 1.2)
		end

		body.PrepareJumpV2.Crescents.Enabled = true
		local lookVector2 = plr.Character.PrimaryPart.CFrame.LookVector
		local v4 = hrp.Position + lookVector2 * 0
		local rayMap2, v5, v6 = Util.RayMap(v4, createVector(0, -25, 0))

		if rayMap2 and clone then
			body.JumpIndicate.dust.Color = ColorSequence.new(rayMap2.Color)
			clone.CFrame = CFrame.new(v5, v5 + v6) * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone.Parent = _WorldOrigin
			clone.UpSlashes.Enabled = true
			TimeScaleParticle(clone.UpSlashes, 1.4)
		else
			body.JumpIndicate.dust:Destroy()
		end

		if plr == game.Players.LocalPlayer then
			task.spawn(function()
				local clone3 = script.Blur:Clone()
				local Debris = game:GetService("Debris")
				Debris:AddItem(clone3, 1)
				clone3.Parent = game.Lighting
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 83
					}
				):Play()
				TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = 35
				}):Play()
				task.wait(0.022)
				TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = 0
				}):Play()
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						FieldOfView = 70
					}
				):Play()
				local clone4 = script.LTN:Clone()
				clone4.Parent = game.Lighting
				Util.Debris:AddItem(clone4, 2)
				TweenService:Create(clone4, TweenInfo.new(0.013), {
					TintColor = Color3.fromRGB(0, 0, 0),
					Brightness = 0.3,
					Contrast = -1,
					Saturation = 30
				}):Play()
				task.wait()
				TweenService:Create(clone4, TweenInfo.new(0.01), {
					TintColor = Color3.fromRGB(255, 16, 16),
					Brightness = 1,
					Contrast = 10,
					Saturation = -1
				}):Play()
				task.wait(0.01)
				TweenService:Create(clone4, TweenInfo.new(0.01), {
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				}):Play()
				Util.Debris:AddItem(clone4, 1)
			end)
			Util.CameraShaker:ShakeOnce(12, 11, 0.1, 0.5, createVector(3, 3, 3), createVector(2, 2, 2))
		end

		for _, child in pairs(body.JumpIndicate:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		for _, child in pairs(body.PrepareJumpIN:GetChildren()) do
			child:SetAttribute("EmitCount", child:GetAttribute("EmitCount") * 2)
		end

		mammothSilhouette.eyeL.EyeL.EYEGLOW.Enabled = true
		mammothSilhouette.eyeR.EyeR.EYEGLOW.Enabled = true
		Util.Sound:Play("MammothMiniRoar", hrp, 20, 1 + math.random(-10, 10) / 100, 2)
	elseif stage == 4 then
		mammothAccessoryJUMP.Name = "MammothDONE"

		for _, v4 in pairs({ mammothSilhouette.body.Swirl, mammothSilhouette.body.Swirl2 }) do
			v4.Enabled = true
			TweenService:Create(v4, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Width1 = 0,
				Width0 = 0
			}):Play()
		end

		mammothSilhouette.eyeL.EyeL.EyeBurst.Enabled = false
		mammothSilhouette.eyeR.EyeR.EyeBurst.Enabled = false
		local hit = groundData.Hit
		local position = groundData.Position
		local normal = groundData.Normal

		if hit then
			Util.Anims:Get(mammothSilhouette, "MammothGround"):Play()
			Util.Sound:Play("MammothCrush", hrp, 20, 1 + math.random(-5, 5) / 100, 2.5)
			Util.Sound:Play("MammothImpactSlice", hrp, 20, 1 + math.random(-10, 10) / 100, 2.5)
			local mammoth2 = FX:WaitForChild("Mammoth")
			mammoth2.Ground:Clone()
			local clone3 = mammoth2.SmashCrack:Clone()
			local primaryPart = clone3.PrimaryPart
			local clone4 = mammoth2.RedCracksGround:Clone()

			if plr == game.Players.LocalPlayer then
				task.spawn(function()
					Util.CameraShaker:ShakeOnce(18, 15, 0.1, 0.25, createVector(3, 3, 3), createVector(2, 2, 2))
					task.wait(0.08)
					Util.CameraShaker:ShakeOnce(17, 15, 0.05, 0.4, createVector(3, 3, 3), createVector(3, 3, 3))
					task.wait(0.025)
					local clone5 = script.Blur:Clone()
					local Debris = game:GetService("Debris")
					Debris:AddItem(clone5, 1)
					clone5.Parent = game.Lighting
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 98
						}
					):Play()
					TweenService:Create(clone5, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = 35
					}):Play()
					task.wait(0.082)
					TweenService:Create(clone5, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = 0
					}):Play()
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							FieldOfView = 70
						}
					):Play()
				end)
				task.spawn(function()
					task.wait(0.075)
					local clone5 = script.LTN:Clone()
					clone5.Parent = game.Lighting
					Util.Debris:AddItem(clone5, 2)
					TweenService:Create(clone5, TweenInfo.new(0.013), {
						TintColor = Color3.fromRGB(0, 0, 0),
						Brightness = 0.3,
						Contrast = -1,
						Saturation = 30
					}):Play()
					task.wait(0.013)
					TweenService:Create(clone5, TweenInfo.new(0.01), {
						TintColor = Color3.fromRGB(255, 16, 16),
						Brightness = 1,
						Contrast = 10,
						Saturation = -1
					}):Play()
					task.wait()
					TweenService:Create(clone5, TweenInfo.new(0.01), {
						TintColor = Color3.fromRGB(255, 255, 255),
						Brightness = 0,
						Contrast = 0,
						Saturation = 0
					}):Play()
					Util.Debris:AddItem(clone5, 1)
				end)
			end

			primaryPart.CFrame = CFrame.new(position, position + normal) * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone3.Parent = _WorldOrigin
			clone4.CFrame = primaryPart.CFrame * CFrame.new(0, 0.05, 0)
			clone4.Parent = _WorldOrigin
			Util.Debris:AddItem(clone3, 3)
			Util.Debris:AddItem(clone4, 2.5)
			task.spawn(function()
				local _, _ = Util.RayMap(primaryPart.Position, createVector(0, -5, 0))

				for _ = 1, 10 do
					debrisPart(hit, position, normal)
				end
			end)
			task.spawn(function()
				for _, descendant in pairs(clone3:GetDescendants()) do
					if not (descendant.Name == "wind" or descendant.Name == "Embers") then
						continue
					end

					descendant:Emit(descendant:GetAttribute("EmitCount"))

					if descendant.Name ~= "wind" then
						continue
					end

					local v4 = descendant
					task.delay(descendant.Lifetime.Max + 0.1, function()
						v4:Destroy()
					end)
				end

				RocksModule2.Ground(
					primaryPart.Position + createVector(0, 1, 0),
					58,
					createVector(10, 5.83, 10),
					nil,
					5,
					false,
					2.5
				)
				RocksModule2.Ground(
					primaryPart.Position + createVector(0, 1, 0),
					68,
					createVector(15.5, 7.25, 15.5),
					nil,
					8,
					false,
					2.75
				)
				RocksModule2.Ground(
					primaryPart.Position + createVector(0, 1, 0),
					73,
					createVector(20, 15.5, 20),
					nil,
					10,
					false,
					3
				)
				RocksModule2.Ground(
					primaryPart.Position + createVector(0, 1, 0),
					84,
					createVector(25, 19.5, 25),
					nil,
					12,
					false,
					3
				)
				TweenService:Create(
					primaryPart,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
					{
						Size = createVector(105, 0.03, 105)
					}
				):Play()
				TweenService:Create(
					clone4,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
					{
						Size = createVector(105, 0.05, 105)
					}
				):Play()
				task.wait(0.15)
				TweenService:Create(
					clone4.Decal,
					TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0),
					{
						Transparency = 1
					}
				):Play()
				TweenService:Create(
					primaryPart.Decal,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
					{
						Color3 = Color3.new(0, 0, 0)
					}
				):Play()
				TweenService:Create(
					primaryPart.Decal,
					TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
					{
						Transparency = 1
					}
				):Play()
			end)
			local clone5 = mammoth2.Wind:Clone()
			clone5.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
			clone5.Parent = _WorldOrigin
			Util.Debris:AddItem(clone5, 1)
			TweenService:Create(clone5, TweenInfo.new(0.45, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				CFrame = hrp.CFrame * CFrame.new(0, -2, 0),
				Size = createVector(160, 25, 160),
				Transparency = 1
			}):Play()
			local clone6 = mammoth2.purple:Clone()
			clone6.CFrame = hrp.CFrame
			clone6.Parent = _WorldOrigin
			Util.Debris:AddItem(clone6, 1)
			TweenService:Create(clone6, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = createVector(180, 180, 180),
				Transparency = 1
			}):Play()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function groundEffects(_, hit2)
				if hit2 then
					primaryPart.Attachment.SMOKE.Color = ColorSequence.new(hit2.Color)
				end
			end

			task.spawn(function()
				task.wait(0.12)
				local descendants = primaryPart.Attachment:GetDescendants()
				local v4 = {}

				for k, descendant in pairs(descendants) do
					v4[k] = {
						count = descendant:GetAttribute("EmitCount") or 0,
						delay = descendant:GetAttribute("EmitDelay") or 0
					}
				end

				for k, descendant in pairs(descendants) do
					if not v4[k] then
						continue
					end

					if v4[k].delay > 0 then
						local v5 = k
						local v6 = descendant
						task.spawn(function()
							task.wait(v4[v5].delay)
							v6:Emit(v4[v5].count)
						end)
					else
						descendant:Emit(v4[k].count)
					end
				end
			end)
			groundEffects(nil, hit) -- equivalent call inferred; original call site unknown
		end

		body.BLACKTRAIL.Trail.Enabled = false
		body.SiloTrailPerm.smoke.Enabled = false
		body.Parent.eyeR.EyeR.Eye:Destroy()
		body.Parent.eyeL.EyeL.Eye:Destroy()
		body.Parent.eyeR.EyeR.EYEGLOW.Enabled = false
		body.Parent.eyeL.EyeL.EYEGLOW.Enabled = false
		mammothSilhouette.PrimaryPart.Anchored = true
		mammothSilhouette.PrimaryPart.RigWeld:Destroy()
		task.wait(0.3)
		local descendants = body.Disperse:GetDescendants()
		local v4 = {}

		for k, emitter in pairs(descendants) do
			if emitter:IsA("ParticleEmitter") then
				v4[k] = {
					count = emitter:GetAttribute("EmitCount") or 0,
					delay = emitter:GetAttribute("EmitDelay") or 0
				}
			end
		end

		for k, descendant in pairs(descendants) do
			local v5 = k
			local v6 = descendant
			task.spawn(function()
				if v4[v5] then
					task.wait(v4[v5].delay)
					v6:Emit(v4[v5].count)
				end
			end)
		end

		for _, part in pairs(body.Parent:GetChildren()) do
			if part:IsA("MeshPart") then
				TweenService:Create(part, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
					Transparency = 1
				}):Play()
			end
		end

		task.wait(0.34)
		Util.Debris:AddItem(mammothAccessoryJUMP, 1)
	end
end

return function(data)
	local plr = data.plr
	local hrp = data.hrp
	local stage = data.stage
	local holdValue = data.HoldValue
	local cf = data.cf

	if (hrp.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	LEAP(plr, hrp, stage, holdValue, cf, data.id, data.GroundData)

	if stage == 1 then
		local v = Util.Sound:Play("MammothCharging", hrp.Position, 20, 1, 2.5)
		tick()

		while data.HoldValue and data.HoldValue.Value == true and hrp ~= nil and data.HoldValue:IsDescendantOf(workspace) do
			wait(0.1)
		end

		if v then
			v:Destroy()
		end
	end
end