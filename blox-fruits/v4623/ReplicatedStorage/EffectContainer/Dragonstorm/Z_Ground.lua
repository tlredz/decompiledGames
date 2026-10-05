local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local fieldOfView = currentCamera.FieldOfView
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local z_Ground = FX:WaitForChild("Dragonstorm").Z_Ground
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local Rock2 = require(ReplicatedStorage.Util.Rock2)
local random = Random.new()

local function ParticleState(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == nil then
			if effect:IsA("ParticleEmitter") then
				effect:Emit(effect:GetAttribute("EmitCount"))
			end
		else
			effect.Enabled = enabled
		end
	end
end

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

Util.ResizeModel(z_Ground.Charge, 0.5)
Util.ResizeModel(z_Ground.FloorShoot, 0.85, z_Ground.FloorShoot.Position)
Util.ResizeModel(z_Ground.FloorShockwaveParticles, 0.6, z_Ground.FloorShockwaveParticles.Position)
Util.ResizeModel(z_Ground.FloorGlow, 0.85, z_Ground.FloorGlow.Position)
Util.ResizeModel(z_Ground.BeginingFloorFlame, 0.85, z_Ground.BeginingFloorFlame.Position)
Util.ResizeModel(z_Ground.FloorCrackBegin, 0.85, z_Ground.FloorCrackBegin.Position)
Util.ResizeModel(z_Ground.FloorFireCharge, 0.85, z_Ground.FloorFireCharge.Position)
return function(data)
	local DELAY_DURATION = 0.1
	local origin = data.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1000 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		folder.Parent = _WorldOrigin
		local root = data.Root
		local holding = data.Holding
		local clone = z_Ground.Charge:Clone()
		clone.Position = root.Position + createVector(0, -2, 0)
		clone.Parent = folder
		sound:Play("DragonStorm_Z_Ground_Activate_01", root)
		local v = sound:Play("DragonStorm_Z_Ground_Charge_Loop_01", root)
		TweenService:Create(v, TweenInfo.new(0.5), {
			Volume = 1
		}):Play()

		repeat
			task.wait()
		until not (holding and holding.Value)

		if v then
			sound:FadeOut(v, 0.15)
		end

		task.wait(0.15)
		local emiteDisapear = clone.EmiteDisapear
		emiteDisapear.Parent = folder
		clone:Destroy()
		ParticleState(emiteDisapear)
		task.wait(5)
		folder:Destroy()
	elseif stage == 2 then
		local floorRay = data.FloorRay
		local rayData = data.RayData
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		folder.Parent = _WorldOrigin
		sound:Play("DragonStorm_Z_GroundSlam_01", floorRay.Position)
		task.wait(0.1)
		local eruptSpeed = data.EruptSpeed
		local _ = data.DragonSpeed
		local clone = z_Ground.FloorShoot:Clone()
		clone.CFrame = CFrame.lookAt(floorRay.Position, floorRay.Position + floorRay.Normal)
		clone.Parent = folder
		ParticleState(clone)

		if data.Player == Players.LocalPlayer or (currentCamera.CFrame.p - floorRay.Position).Magnitude <= 100 then
			Util.CameraShaker:Shake(Util.CameraShaker.Presets.Explosion2)
		end

		task.spawn(function()
			local v = math.random(5, 8)
			local v2 = floorRay.Position + createVector(0, 1, 0)

			for i = 1, v do
				local v3 = 360 / v * i
				local v4 = CFrame.new(v2, v2 + floorRay.Normal * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					math.rad(v3),
					0
				) * CFrame.new(0, 0, -15)
				local ray, v5, v6 = Util.Ray(
					v4.Position,
					v4.upVector.Unit * -30,
					{ workspace.Characters, workspace.Enemies },
					false
				)

				if not ray then
					continue
				end

				local v7 = Rock2.new({
					FadeIn = { 0.3, 0.6 },
					Lifetime = math.random(10, 20) / 10,
					FadeOut = { 0.4, 0.5 },
					Type = "Flying",
					Size = Vector3.new(math.random(2, 3), 2, math.random(2, 3)),
					Scale = { 1, 2 }
				})
				v7:Spawn(CFrame.new(v5, v5 + v6) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(0, 0, 0))
				v7:Eject({
					Velocity = v4.UpVector * (workspace.Gravity / 2 + math.random(-10, 20)) + v7.Part.CFrame.lookVector * math.random(
						10,
						20
					),
					RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
				})
			end
		end)
		TweenService:Create(currentCamera, TweenInfo.new(0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			FieldOfView = fieldOfView - 7
		}):Play()
		task.wait(0.05)
		TweenService:Create(currentCamera, TweenInfo.new(0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			FieldOfView = fieldOfView + 5
		}):Play()
		task.wait(0.05)
		TweenService:Create(currentCamera, TweenInfo.new(0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			FieldOfView = fieldOfView
		}):Play()
		local clone2 = z_Ground.FloorShockwaveParticles:Clone()
		clone2.CFrame = CFrame.lookAt(
			floorRay.Position + floorRay.Normal * clone2.Size.Z / 2,
			floorRay.Position + floorRay.Normal * clone2.Size.Z
		)
		clone2.Parent = folder
		ParticleState(clone2)
		local clone3 = z_Ground.Wave:Clone()
		clone3.CFrame = CFrame.lookAt(floorRay.Position, floorRay.Position + floorRay.Normal) * CFrame.Angles(
			3.141592653589793,
			0,
			0
		) * CFrame.new(0, 0, 25)
		clone3.Parent = folder
		TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1,
			Size = createVector(120, 120, 5),
			CFrame = CFrame.lookAt(floorRay.Position, floorRay.Position + floorRay.Normal) * CFrame.Angles(
				3.141592653589793,
				0,
				0
			)
		}):Play()

		for i = 1, 3 do
			local clone4 = z_Ground.FloorShockwaveModel:Clone()
			clone4:ScaleTo(i * 1.3)
			local number = random:NextNumber(0, 360)
			local floorShockwave = clone4.FloorShockwave
			floorShockwave.CFrame = CFrame.lookAt(
				floorRay.Position + floorRay.Normal * -floorShockwave.Beam.Width0,
				floorRay.Position
			) * CFrame.Angles(0, 0, (math.rad(number)))
			floorShockwave.Parent = folder
			TweenService:Create(floorShockwave, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = CFrame.lookAt(floorRay.Position, floorRay.Position + floorRay.Normal) * CFrame.Angles(
					0,
					0,
					(math.rad(number))
				)
			}):Play()
			local folder2 = floorShockwave
			task.delay(DELAY_DURATION, function()
				for i2, beam in folder2:GetDescendants() do
					if beam:IsA("Beam") then
						TweenService:Create(
							beam,
							TweenInfo.new(0.03, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Brightness = 0,
								LightEmission = 1
							}
						):Play()
					end
				end
			end)
			task.wait(0.03)
		end

		local clone4 = z_Ground.FloorFireCharge:Clone()
		clone4.CFrame = CFrame.lookAt(rayData.Position, rayData.Position + rayData.Normal)
		clone4.Parent = folder
		local clone5 = z_Ground.FloorGlow:Clone()
		clone5.CFrame = CFrame.lookAt(floorRay.Position, floorRay.Position + floorRay.Normal) * CFrame.Angles(
			-1.5707963267948966,
			random:NextNumber(0, 6.283185307179586),
			0
		)
		clone5.Parent = folder
		ParticleState(clone5)
		local clone6 = z_Ground.BeginingFloorFlame:Clone()
		clone6.CFrame = CFrame.lookAt(floorRay.Position, floorRay.Position + floorRay.Normal)
		clone6.Parent = folder
		task.delay(0.75, function()
			for _, effect in clone6:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
		local v = (floorRay.Position - rayData.Position).Magnitude / eruptSpeed * 0.5
		task.wait(v)
		local number = random:NextNumber(0, 6.283185307179586)
		local clone7 = z_Ground.FloorCrackBegin:Clone()
		clone7.CFrame = CFrame.lookAt(rayData.Position, rayData.Position + rayData.Normal) * CFrame.Angles(
			-1.5707963267948966,
			number,
			0
		)
		clone7.Parent = folder
		ParticleState(clone7)
		clone7.Attachment["2_Appear"].Lifetime = NumberRange.new(v, v)
		task.wait(v)
		task.delay(DELAY_DURATION, function()
			local clone8 = z_Ground.CC:Clone()
			local brightness = clone8.Brightness
			local contrast = clone8.Contrast
			local saturation = clone8.Saturation
			local tintColor = clone8.TintColor
			clone8.Brightness = 0
			clone8.Contrast = 0
			clone8.Saturation = 0
			clone8.TintColor = Color3.new(1, 1, 1)

			if (currentCamera.CFrame.p - rayData.Position).Magnitude <= 120 then
				clone8.Parent = Lighting
				Util.CameraShaker:ShakeOnce(25, 25, 0.05, 1.2)
				TweenService:Create(clone8, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Brightness = brightness,
					Contrast = contrast,
					Saturation = saturation,
					TintColor = tintColor
				}):Play()
			else
				clone8.Parent = _WorldOrigin
			end

			task.wait(0.5)
			clone8:Destroy()
		end)
		task.spawn(function()
			local v2 = rayData.Position + createVector(0, 1, 0)

			for i = 1, 16 do
				local v4 = CFrame.new(v2, v2 + rayData.Normal * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					math.rad(i * 22.5),
					0
				) * CFrame.new(0, 0, -40)
				local ray, v5, v6 = Util.Ray(
					v4.Position,
					v4.upVector.Unit * -30,
					{ workspace.Characters, workspace.Enemies },
					false
				)

				if ray then
					Rock2.new({
						FadeIn = { 0.1, 0.15 },
						Lifetime = math.random(25, 28) / 10,
						FadeOut = { 0.2, 0.3 },
						Size = Vector3.new(math.random(3, 4), 2, math.random(3, 4)) * 1.35,
						Scale = { 1.2, 3 }
					}):Spawn(CFrame.new(v5, v5 + v6) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(0, 0, 0))
				end
			end
		end)
		local hit = rayData.Hit

		for _ = 1, 9 do
			local clone8 = z_Ground.Debree:Clone()
			clone8.Color = hit.Color
			clone8.Material = hit.Material
			clone8.CFrame = clone7.CFrame * CFrame.Angles(
				random:NextNumber(0, 6.283185307179586),
				random:NextNumber(0, 6.283185307179586),
				random:NextNumber(0, 6.283185307179586)
			)
			clone8.Size *= Vector3.new(3, random:NextNumber(0.9, 1.4), 3)
			rocks:ApplyCollision(clone8, nil, true)
			clone8.Parent = folder
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = (CFrame.lookAt(rayData.Position, rayData.Position + rayData.Normal) * CFrame.Angles(
				math.rad((random:NextNumber(-25, 25))),
				math.rad((random:NextNumber(-25, 25))),
				0
			)).LookVector * random:NextNumber(120, 170)
			bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
			bodyVelocity.Parent = clone8
			local folder2 = clone8
			task.delay(0.2, function()
				bodyVelocity:Destroy()
				task.wait(random:NextNumber(2, 3.6))

				for i, effect in folder2:GetDescendants() do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				local number2 = random:NextNumber(0.2, 0.4)
				TweenService:Create(folder2, TweenInfo.new(number2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				task.wait(number2)

				for i, effect in folder2:GetDescendants() do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end)
		end

		local clone8 = z_Ground.FloorCrack:Clone()
		clone8.CFrame = CFrame.lookAt(rayData.Position, rayData.Position + rayData.Normal) * CFrame.Angles(
			-1.5707963267948966,
			number,
			0
		)
		clone8.Parent = folder
		local _ = rayData.Position

		for _, effect in clone4:GetDescendants() do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local clone9 = z_Ground.FloorExplode:Clone()
		clone9.CFrame = CFrame.lookAt(rayData.Position, rayData.Position + rayData.Normal)
		clone9.Parent = folder
		ParticleState(clone9)
		sound:Play("DragonStorm_Z_Ground_Dragon_Emerge_01", rayData.Position)
		local clone10 = z_Ground.FloorFlame:Clone()
		clone10.CFrame = CFrame.lookAt(rayData.Position, rayData.Position + rayData.Normal)
		clone10.Parent = folder
		task.delay(0.5, function()
			for _, effect in clone10:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			task.wait(1.5)

			for _, effect in clone8:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
		task.wait(0.2)
		local position = rayData.Position
		local clone11 = z_Ground.Dragon:Clone()
		local rootPart = clone11.RootPart
		rootPart:PivotTo(CFrame.new(position))
		clone11.Parent = folder
		local v2 = sound:Play("DragonStorm_Z_GroundSlam_DragonHeadLoop_01_V", rootPart)
		ParticleState(clone11.Dragon.UpperJaw.LeftEye)
		ParticleState(clone11.Dragon.UpperJaw.RightEye)
		local flyTime = data.FlyTime
		local upDistance = data.UpDistance
		local position2 = rayData.Position
		local v3 = rayData.Position + rayData.Normal * upDistance / 2 + Vector3.new(
			random:NextNumber(-80, 80) * data.Multiplier,
			random:NextNumber(-10, 10),
			random:NextNumber(-80, 80) * data.Multiplier
		)
		local v4 = rayData.Position + rayData.Normal * upDistance * 3 / 4 + Vector3.new(
			random:NextNumber(-80, 80),
			random:NextNumber(-10, 10),
			random:NextNumber(-80, 80)
		)
		local endPoint = data.EndPoint

		for _ = 1, 3 do
			local clone12 = z_Ground.FireTrailPart:Clone()
			local number2 = random:NextNumber(0, 360)
			local v5 = (random:NextInteger(0, 1) * 2 - 1) * random:NextNumber(500, 800)
			local number3 = random:NextNumber(0, 360)
			local number4 = random:NextNumber(200, 500)
			local number5 = random:NextNumber(30, 70)
			local number6 = random:NextNumber(30, 50)
			local position3 = rootPart.Position
			local v6 = math.sin((math.rad(number2))) * number6
			local v7 = math.sin((math.rad(number3))) * number5
			clone12.Position = position3 + Vector3.new(v6, v7, math.cos((math.rad(number2))) * number6)
			clone12.Parent = folder
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				number2 += v5 * dt
				number3 += number4 * dt
				clone12.Position = rootPart.Position + Vector3.new(
					math.sin((math.rad(number2))) * number6,
					math.sin((math.rad(number3))),
					math.cos((math.rad(number2))) * number6
				)
			end)
			local folder2 = clone12
			task.delay(flyTime, function()
				heartbeatConnection:Disconnect()

				for i, effect in folder2:GetDescendants() do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end)
		end

		local lastTime = os.clock()
		local v5 = flyTime / 10
		local descendants = rootPart.tail["tail.010"]:GetDescendants()
		task.delay(flyTime * 0.4, function()
			local bone002 = rootPart.tail.Bone["Bone.002"]
			local bone004 = rootPart.tail.Bone["Bone.004"]
			TweenService:Create(
				bone002,
				TweenInfo.new(flyTime * 0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
				{
					CFrame = CFrame.new(0, 4.764, -0.937) * CFrame.Angles(0.87720248205235, 0, 0)
				}
			):Play()
			TweenService:Create(
				bone004,
				TweenInfo.new(flyTime * 0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
				{
					CFrame = CFrame.new(-0, 4.015, -3.49) * CFrame.Angles(-1.3535202882141226, 0, 0)
				}
			):Play()
			task.wait(flyTime * 0.3)
			TweenService:Create(
				bone002,
				TweenInfo.new(flyTime * 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
				{
					CFrame = CFrame.new(0, 3.436, 0) * CFrame.Angles(0.532150888933071, 0, 0)
				}
			):Play()
			TweenService:Create(
				bone004,
				TweenInfo.new(flyTime * 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
				{
					CFrame = CFrame.new(0, 3.435, 0) * CFrame.Angles(0.04771730174952497, 0, 0)
				}
			):Play()
			local v6 = sound:Play("DragonStorm_Z_Ground_DragonHeadExplode_01", rootPart)
			task.wait(flyTime * 0.2)
			TweenService:Create(clone11.Body, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = Color3.new(1, 1, 1)
			}):Play()
			task.wait(0.1)
			local clone12 = z_Ground.DragonExplodeGrandFinale:Clone()
			clone12.CFrame = rootPart.CFrame
			clone12.Parent = folder
			v6.Parent = clone12

			if v2 then
				v2.Parent = clone12
				sound:FadeOut(v2, 0.2)
			end

			ParticleState(clone12)
			clone11:Destroy()
		end)
		local lastTime2 = os.clock()
		os.clock()
		local lastTime3 = os.clock()
		local lastTime4 = os.clock()
		local v6 = 0
		local v7 = {}

		while os.clock() - lastTime4 < flyTime do
			local v8 = (os.clock() - lastTime4) / flyTime

			if v8 == 0 then
				continue
			end

			local value = TweenService:GetValue(v8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			local v9 = position2 + (v3 - position2) * value
			local v10 = v3 + (v4 - v3) * value
			local v11 = v4 + (endPoint - v4) * value
			local v12 = v9 + (v10 - v9) * value
			local v13 = v12 + (v10 + (v11 - v10) * value - v12) * value

			if v6 <= os.clock() - lastTime3 and value < 0.98 then
				v6 = random:NextNumber(0.03, 0.07)
				lastTime3 = os.clock()

				for _, descendant in descendants do
					if not v7[tonumber((string.sub(descendant.Name, 8, 8)))] then
						continue
					end

					descendant.WorldCFrame = v7[tonumber((string.sub(descendant.Name, 8, 8)))]
				end

				local clone12 = z_Ground.DragonExplode:Clone()
				clone12.Position = v13 + Vector3.new(
					random:NextNumber(-10, 10),
					random:NextNumber(-10, 10),
					random:NextNumber(-10, 10)
				)
				clone12.Parent = folder
				task.delay(DELAY_DURATION, function()
					ParticleState(clone12)
				end)

				for _ = 1, 3 do
					local clone13 = z_Ground.DragonCrackle:Clone()
					clone13.CFrame = rootPart.CFrame * CFrame.Angles(
						random:NextNumber(0, 6.283185307179586),
						random:NextNumber(0, 6.283185307179586),
						random:NextNumber(0, 6.283185307179586)
					)
					clone13.Parent = folder
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = Vector3.new(
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1)
					).Unit * random:NextNumber(120, 200)
					bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
					bodyVelocity.Parent = clone13
					local folder2 = clone13
					task.delay(random:NextNumber(0.1, 0.3), function()
						bodyVelocity:Destroy()
						task.wait(random:NextNumber(0.4, 0.6))

						for i, effect in folder2:GetDescendants() do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end)
				end
			end

			if v5 <= os.clock() - lastTime and value < 0.98 then
				lastTime = os.clock()
				local clone12 = z_Ground.DragonExplodeFinale:Clone()
				clone12.Position = rootPart.Position + Vector3.new(
					random:NextNumber(-10, 10),
					random:NextNumber(-10, 10),
					random:NextNumber(-10, 10)
				)
				clone12.Parent = folder
				task.delay(0.3, function()
					sound:Play("DragonStorm_Z_Air_Explosion_0" .. tostring(math.random(1, 6)), clone12.Position)
					ParticleState(clone12)
				end)
			end

			rootPart.CFrame = CFrame.lookAt(v13, position) * CFrame.Angles(0, 3.141592653589793, 0)

			if os.clock() - lastTime2 >= 0.03 then
				lastTime2 = os.clock()

				if #v7 == 9 then
					for k, v14 in v7 do
						if k == 1 then
							continue
						end

						v7[k] = nil
						v7[k - 1] = v14
					end
				end

				table.insert(v7, rootPart.CFrame)
			end

			task.wait(0.016666666666666666)
			position = v13
		end

		for _, descendant in descendants do
			descendant.CFrame = CFrame.new(0, 0, 0)
		end

		task.wait(3)
		task.wait(5)
		folder:Destroy()
	end
end