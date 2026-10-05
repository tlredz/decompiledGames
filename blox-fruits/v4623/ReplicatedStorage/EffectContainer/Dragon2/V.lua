local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")

local function putFolder(p, instance, name: string)
	local v = instance:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		Util.SetParentOverrideWithColor(v, instance, p, "DragonFruitVFXColor")
	end

	return v
end

local rescheduleDestruction

rescheduleDestruction = function(p, instance, duration: number, flag: boolean?)
	if (flag == nil or flag) == true or instance:GetAttribute("PrevTimeDestructInitiated") == nil then
		instance:SetAttribute("PrevTimeDestructInitiated", time())
	end

	local destructionDepth = instance:GetAttribute("DestructionDepth") or 0
	instance:SetAttribute("DestructionDepth", destructionDepth + 1)

	if destructionDepth >= 100 then
		instance:Destroy()
		warn("rescheduleDestruction: Maximum re-entrancy depth of 100 exceeded")
	else
		task.delay(duration, function()
			local prevTimeDestructInitiated = instance:GetAttribute("PrevTimeDestructInitiated")

			if duration - (time() - prevTimeDestructInitiated) < 0.2 and instance ~= nil and instance.Parent ~= nil then
				instance:Destroy()
				return
			end

			if instance == nil or instance.Parent == nil then
				return
			end

			rescheduleDestruction(p, instance, duration, false)
		end)
	end
end

local function putValueAsValueObject(p, instance, name: string, p2, value: number)
	local v2 = {
		boolean = "BoolValue",
		CFrame = "CFrameValue",
		Color3 = "Color3Value",
		number = "NumberValue",
		Instance = "ObjectValue",
		Ray = "RayValue",
		string = "StringValue",
		Vector3 = "Vector3Value"
	}
	local instance2 = instance:FindFirstChild(name)

	if instance2 == nil then
		instance2 = Instance.new(v2[typeof(p2)])
		instance2.Name = name
		Util.SetParentOverrideWithColor(instance2, instance, p, "DragonFruitVFXColor")
	end

	instance2.Value = p2
	rescheduleDestruction(p, instance2, value or 60)
	return instance2
end

local function getValueOfValueObject(_, instance, childName: string)
	local child = instance:FindFirstChild(childName)

	if child == nil then
		return nil
	end

	return child.Value
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function createDefaultProjectile(p, p2: number)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(4, 4, 4)
	part.Transparency = 1
	part.Name = "Projectile"
	Util.SetParentOverrideWithColor(part, _WorldOrigin, p, "DragonFruitVFXColor")
	destroyAfter(part, p2 + 7)
	return part
end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(_, p, p2)
	p.CFrame = p.CFrame.Rotation + p2
end

local function shouldStopProjectile(_, instance)
	return instance:GetAttribute("ProjectileActive") ~= true and instance:GetAttribute("ImpactPos") ~= nil and instance:GetAttribute("DisabledInterp") < 0.9999
end

local function fireClientProjectile(p, p2: number, callback, p3, p4, callback2)
	local v = callback2 or function(_)
		return CFrame.new()
	end
	local v2 = p3 or Instance.new("Folder")
	local v3 = p4 or createDefaultProjectile(p, p2)
	v3.CFrame = CFrame.lookAt(callback(0.001), callback(0.002)) * v(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v4 = false
	local connection = nil
	connection = heartbeatLoopFor2(p2, function(_, _, p5)
		local v5 = v2
		local v6

		if v5:GetAttribute("ProjectileActive") == true or v5:GetAttribute("ImpactPos") == nil then
			v6 = false
		else
			v6 = v5:GetAttribute("DisabledInterp") < 0.9999
		end

		if not v6 then
			v3.CFrame = CFrame.lookAt(callback(p5), callback(p5 + 0.01)) * v(p5)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(nil, v3, v2:GetAttribute("ImpactPos")) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(v2:GetAttribute("ImpactPos"), "Impact")
		v4 = true
	end, function()
		if v4 == true then
			return
		end

		snapProjectileToFinalPos(nil, v3, callback(1)) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(callback(1), "NonImpact")
	end)
	return bindableEvent, v3, connection
end

local function cameraShakeAt(_, vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 100) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

local function haltUntilCondition(_, callback, value: number?)
	local v = value or 14
	local bindableEvent = Instance.new("BindableEvent")
	task.delay(v, bindableEvent.Fire, bindableEvent)
	local connection = nil
	connection = heartbeatLoopFor2(v, function()
		local success, result = pcall(callback)

		if success and result then
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		elseif not success then
			print("haltUntilCondition: Error in predicate function: ", result)
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		end
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()
end

local function alignCFrameWithPlane(_, cframe: CFrame, vector2: Vector3)
	local v = { cframe.RightVector, cframe.UpVector, cframe.LookVector }
	local v2 = -1e999
	local vector3 = nil

	for _, vector4 in ipairs(v) do
		local dot = vector4:Dot(vector2)

		if not (v2 < math.abs(dot)) then
			continue
		end

		v2 = math.abs(dot)
		vector3 = math.sign(dot) * vector4
	end

	local cross = vector3:Cross(vector2)
	local v3 = math.acos((math.clamp(v2, -1, 1)))

	if cross.Magnitude < 0.0001 then
		return cframe.Rotation
	end

	return CFrame.fromAxisAngle(cross, v3) * cframe.Rotation
end

local function snapPointToPlane(_, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local unit = vector3.Unit
	local X = unit.X
	local Y = unit.Y
	local Z = unit.Z
	local X2 = vector2.X
	local Z2 = vector2.Z
	local dot = vector4:Dot(unit)
	local v

	if math.abs(Y) < 0.1 then
		v = vector2.Y
	else
		v = (dot - X2 * X - Z2 * Z) / Y
	end

	return (Vector3.new(X2, v, Z2))
end

local function mockRootPart(p, _, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	Util.SetParentOverrideWithColor(part, _WorldOrigin, p, "DragonFruitVFXColor")
	destroyAfter(part, 7)
	return part
end

local V = FX:WaitForChild("Dragon2").V
return function(player)
	local WAIT_INTERVAL = 0.1
	local player2 = player.player
	local hrp = player.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 2000 then
		return
	end

	local function RandomTrails(player3, hrp2, folder, clone, sizeMultiplier)
		local function quadBezier(_, p, p2, p3, p4)
			return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
		end

		local function lerp(_, p, p2, p3)
			return p + (p2 - p) * p3
		end

		local function cubicBezier(_, p, position, p2, p3, position2)
			local v = position + (p2 - position) * p
			local v2 = p2 + (p3 - p2) * p
			local v3 = p3 + (position2 - p3) * p
			local v4 = v + (v2 - v) * p
			return v4 + (v2 + (v3 - v2) * p - v4) * p
		end

		local trails = clone.Trails
		task.spawn(function()
			local count = #trails:GetChildren()

			for _ = 1, 10 do
				task.spawn(function()
					local cFrame = hrp2.CFrame * CFrame.new(
						math.random(-25, 25) * 3 * sizeMultiplier,
						math.random(0, 25) * 3 * sizeMultiplier,
						math.random(-25, 25) * 3 * sizeMultiplier
					)
					local position = hrp2.CFrame.Position
					local v2 = math.random(50, 70) / 10
					local v3 = math.random(1, count)
					local clone2 = trails["Trail" .. tostring(v3)]:Clone()
					clone2.CFrame = cFrame
					Util.SetParentOverrideWithColor(clone2, folder, player3, "DragonFruitVFXColor")
					destroyAfter(clone2, 7)
					local position2 = clone2.Position
					local magnitude = (position2 - position).Magnitude
					clone2.CFrame = CFrame.new(position2, position)
					local v4 = (position2 - position) / 2
					local position3 = CFrame.new(CFrame.new(position2) * (v4 / -1.5)).Position
					local position4 = CFrame.new(CFrame.new(position) * (v4 / 1.5)).Position
					local v5 = position3 + Vector3.new(
						math.random(-magnitude, magnitude),
						math.random(-magnitude / 2, magnitude),
						math.random(-magnitude, magnitude)
					)
					local v6 = position4 + Vector3.new(
						math.random(-magnitude, magnitude),
						math.random(-magnitude / 2, magnitude),
						math.random(-magnitude, magnitude)
					)
					local lastTime = tick()
					local v7 = magnitude / v2 / 60
					local v8 = time()

					for _ = 1, 600 do
						if not (tick() - lastTime < v7) or time() - v8 > 10 then
							break
						end

						local v9 = (tick() - lastTime) / v7
						local v10 = cubicBezier(player3, v9, position2, v5, v6, position)
						clone2.CFrame = clone2.CFrame:Lerp(CFrame.new(v10, position), v9)
						task.wait()
					end

					TweenService:Create(clone2, TweenInfo.new(0.1), {
						Position = position
					}):Play()

					for _, emitter in ipairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
			end
		end)
	end

	local function AlignCFrame(_, data, normal)
		local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
		local p = data.p
		local unit = data.LookVector:Cross(v).Unit
		local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
		local unit3 = unit2:Cross(v).Unit
		return CFrame.fromMatrix(p, unit2, v, unit3)
	end

	local function GroundFlyRocks(player3, raycastResult, folder, data, RocksFlyVelocityCallbackFunction2, sizeMultiplier, clone)
		local cframe = CFrame.new(raycastResult.Position)
		local material = raycastResult.Material
		local color = raycastResult.Instance.Color
		local rockAmount = data.RockAmount
		local rockSize = data.RockSize
		local positionOffset = data.PositionOffset
		local rockRotationAmount = data.RockRotationAmount
		local rockRotationSpeed = data.RockRotationSpeed
		local rockRotationPower = data.RockRotationPower
		local duration = data.Duration

		for _ = 1, rockAmount do
			task.spawn(function()
				local clone2 = clone.FlyRock:Clone()
				clone2.CFrame = cframe * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
				clone2.CFrame *= CFrame.new(0, 0, -positionOffset * sizeMultiplier)
				clone2.Size = Vector3.new(
					math.random(rockSize / 2, rockSize),
					math.random(rockSize / 2, rockSize),
					math.random(rockSize / 2, rockSize)
				)
				clone2.Size = Vector3.new(
					clone2.Size.X * sizeMultiplier,
					clone2.Size.Y * sizeMultiplier,
					clone2.Size.Z * sizeMultiplier
				)
				clone2.Material = material
				clone2.Color = color:Lerp(
					Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player3, "DragonFruitVFXColor"),
					0.75
				)
				rocks:ApplyCollision(clone2, nil, true)
				clone2.Anchored = false
				Util.SetParentOverrideWithColor(clone2, folder, player3, "DragonFruitVFXColor")
				clone2.Color = color:Lerp(Color3.fromRGB(0, 0, 0), 0.75)
				destroyAfter(clone2, 7)
				task.spawn(function()
					for _, emitter in ipairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					TweenService:Create(
						clone2,
						TweenInfo.new(duration / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Color = Util.WrapColor3Constructor(Color3.fromRGB(7, 7, 7), player3, "DragonFruitVFXColor")
						}
					):Play()
					task.wait(duration + 1.5 + math.random(10, 50) / 100)

					for _, emitter in ipairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					local tween = TweenService:Create(
						clone2,
						TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
						{
							Size = createVector(0, 0, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					clone2.Anchored = true
					clone2.CanCollide = false
				end)
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
				bodyVelocity.P = 3000
				Util.SetParentOverrideWithColor(bodyVelocity, clone2, player3, "DragonFruitVFXColor")
				destroyAfter(bodyVelocity, 7)
				RocksFlyVelocityCallbackFunction2(player3, bodyVelocity, clone2)
				local attachment0 = clone2.Attachment0
				attachment0.Orientation = createVector(0, 0, 0)
				local alignOrientation = clone2.AlignOrientation
				local v = math.random(-rockRotationPower, rockRotationPower)
				local v2 = math.random(-rockRotationPower, rockRotationPower)
				local v3 = math.random(-rockRotationPower, rockRotationPower)
				local v4 = v / rockRotationAmount
				local v5 = v2 / rockRotationAmount
				local v6 = v3 / rockRotationAmount
				task.spawn(function()
					task.wait(0.05)

					for i = 1, rockRotationAmount do
						v = math.clamp(v - v4, 0, rockRotationPower * 1.5)
						v2 = math.clamp(v2 - v5, 0, rockRotationPower * 1.5)
						v3 = math.clamp(v3 - v6, 0, rockRotationPower * 1.5)
						local tween = TweenService:Create(
							attachment0,
							TweenInfo.new(rockRotationSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = attachment0.CFrame * CFrame.Angles(math.rad(v), math.rad(v2), (math.rad(v3)))
							}
						)
						tween:Play()
						tween.Completed:Wait()
						tween:Destroy()

						if i ~= rockRotationAmount then
							continue
						end

						for _, emitter in ipairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end

					alignOrientation:Destroy()
				end)
			end)
		end
	end

	local function ScreenEffect(player3, folder)
		if player3 == game.Players.LocalPlayer or (Workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude < 300 then
			local lastTime = tick()
			task.spawn(function()
				while tick() - lastTime < 1.5 do
					Util.CameraShaker:ShakeOnce(9, 15, 0.2, 0.7)
					task.wait(0.1)
				end
			end)

			if player3 == game.Players.LocalPlayer then
				local humanoid = game.Players.LocalPlayer.Character.Humanoid

				local function dead()
					if not (humanoid.Health <= 0) then
						return
					end

					game.Players.LocalPlayer.CameraMinZoomDistance = 0.5
					game.Players.LocalPlayer.CameraMaxZoomDistance = 128
					local UserInputService = game:GetService("UserInputService")

					if UserInputService.GamepadEnabled then
						game.Players.LocalPlayer.CameraMaxZoomDistance = 15
						task.delay(0.1, function()
							game.Players.LocalPlayer.CameraMaxZoomDistance = 200
						end)
					end

					return true
				end

				local lastTime2 = tick()
				task.spawn(function()
					while tick() - lastTime2 < 2 do
						local v = (tick() - lastTime2) / 2
						game.Players.LocalPlayer.CameraMaxZoomDistance = 350
						game.Players.LocalPlayer.CameraMinZoomDistance = 100 + v ^ 0.5 * 250
						task.wait()

						if dead() then
							return
						end
					end

					game.Players.LocalPlayer.CameraMinZoomDistance = 350
					local lastTime3 = tick()

					while tick() - lastTime3 < 0.4 do
						local v = ((tick() - lastTime3) / 0.4) ^ 2
						local v2 = 350 - v * 100
						game.Players.LocalPlayer.CameraMinZoomDistance = v2
						game.Players.LocalPlayer.CameraMaxZoomDistance = v2
						Workspace.CurrentCamera.FieldOfView = 70 - v * 30
						task.wait()

						if dead() then
							return
						end
					end

					if dead() then
						return
					end

					Workspace.CurrentCamera.FieldOfView = 40
					game.Players.LocalPlayer.CameraMinZoomDistance = 250
					local lastTime4 = tick()

					while tick() - lastTime4 < 0.6 do
						local v = ((tick() - lastTime4) / 0.6) ^ 2
						local v2 = 250 - v * 100
						Workspace.CurrentCamera.FieldOfView = 40 + v * 30
						game.Players.LocalPlayer.CameraMinZoomDistance = v2
						game.Players.LocalPlayer.CameraMaxZoomDistance = v2
						task.wait()

						if dead() then
							return
						end
					end

					if dead() then
						return
					end

					game.Players.LocalPlayer.CameraMinZoomDistance = 150
					Workspace.CurrentCamera.FieldOfView = 70
					game.Players.LocalPlayer.CameraMaxZoomDistance = 350
					game.Players.LocalPlayer.CameraMinZoomDistance = 75
				end)
			end

			local screenColorDV2 = Lighting:FindFirstChild("ScreenColorDV2") or V.Phase2.ScreenColorDV2:Clone()
			Util.SetParentOverrideWithColor(screenColorDV2, Lighting, player3, "DragonFruitVFXColor")
			destroyAfter(screenColorDV2, 7)
			screenColorDV2:SetAttribute("UsedTimes", screenColorDV2:GetAttribute("UsedTimes") + 1)
			local usedTimes = screenColorDV2:GetAttribute("UsedTimes")
			TweenService:Create(screenColorDV2, TweenInfo.new(0.15), {
				Brightness = -0.01,
				Contrast = 0.1,
				Saturation = 0.1,
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(231, 185, 159),
					player3,
					"DragonFruitVFXColor"
				)
			}):Play()
			local currentCamera2 = Workspace.CurrentCamera
			local clone = V.Phase2.CameraFocus:Clone()
			Util.SetParentOverrideWithColor(clone, folder, player3, "DragonFruitVFXColor")
			destroyAfter(clone, 7)
			local renderSteppedConnection = RunService.RenderStepped:Connect(function()
				clone.CFrame = currentCamera2.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
			end)

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.spawn(function()
				task.wait(1)

				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(0.5)
				renderSteppedConnection:Disconnect()
				clone:Destroy()
			end)
			task.wait(1.5)

			if screenColorDV2:GetAttribute("UsedTimes") == usedTimes then
				local tween = TweenService:Create(screenColorDV2, TweenInfo.new(1.5), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player3,
						"DragonFruitVFXColor"
					),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				})
				tween:Play()
				tween.Completed:Wait()

				if screenColorDV2:GetAttribute("UsedTimes") == usedTimes then
					screenColorDV2:Destroy()
				end
			end
		end
	end

	local character = player.Character
	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "DragonFruitVFXColor")
	destroyAfter(folder, 15)
	local cframe = CFrame.new(hrp.Position, hrp.Position + hrp.CFrame.LookVector * createVector(1, 0, 1))
	local sizeMultiplier = player.SizeMultiplier or 1.5
	local raycastParams2 = RaycastParams.new()
	raycastParams2.IgnoreWater = false
	raycastParams2.FilterDescendantsInstances = { character, folder }
	local clone = V.Phase1.ScaleModel:Clone()
	clone:ScaleTo(sizeMultiplier)
	local startImpact = clone.StartImpact
	startImpact.CFrame = cframe
	Util.SetParentOverrideWithColor(startImpact, folder, player2, "DragonFruitVFXColor")
	destroyAfter(startImpact, 7)
	sound:Play("BF_WD_WesternDragon_WhiteGlove_01", hrp)

	for _, emitter in ipairs(startImpact:GetDescendants()) do
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

	RandomTrails(player2, hrp, folder, clone, sizeMultiplier)
	task.spawn(function()
		local startAura = clone.StartAura
		startAura.CFrame = cframe
		Util.SetParentOverrideWithColor(startAura, folder, player2, "DragonFruitVFXColor")
		destroyAfter(startAura, 7)
		local emittersByEmitter = {}

		for _, emitter in ipairs(startAura:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emittersByEmitter[emitter] = emitter
		end

		local v = 0.2 + tick()
		local v2 = time()

		for _ = 1, 600 do
			for _, v3 in pairs(emittersByEmitter) do
				v3:Emit(1)
			end

			task.wait(0.1)

			if v - tick() <= 0 or time() - v2 > 10 then
				break
			end
		end

		for _, emitter in ipairs(startAura:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	task.spawn(function()
		task.wait(0.15)
		local raycastResult = Workspace:Raycast(
			cframe.Position + createVector(0, 1, 0),
			createVector(-0, -50, -0),
			raycastParams
		)

		if raycastResult then
			local v = AlignCFrame(player2, CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.001
			local cframe2 = CFrame.new(v.Position, v.Position + cframe.LookVector)
			local groundShockwaveModel = clone.GroundShockwaveModel
			local groundShockwave = groundShockwaveModel.GroundShockwave
			groundShockwave.CFrame = cframe2
			Util.SetParentOverrideWithColor(groundShockwaveModel, folder, player2, "DragonFruitVFXColor")
			destroyAfter(groundShockwaveModel, 7)
			local emittersByEmitter = {}
			local emittersByEmitter2 = {}

			for _, emitter in ipairs(groundShockwave:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emittersByEmitter[emitter] = emitter

				if emitter.Parent ~= groundShockwave.Shockwave2 then
					continue
				end

				destroyAfter(emitter, 7)
				emittersByEmitter2[emitter] = emitter
			end

			task.spawn(function()
				for i = 20 * sizeMultiplier, 50 * sizeMultiplier do
					groundShockwaveModel:ScaleTo(i / 10)
					task.wait(0.1 / sizeMultiplier)
				end
			end)
			local v2 = 0.75 + tick()
			local v3 = time()

			for _ = 1, 600 do
				for _, v4 in pairs(emittersByEmitter) do
					v4:Emit(1)
				end

				for _, v4 in pairs(emittersByEmitter2) do
					v4:Emit(2)
				end

				task.wait(0.05)

				if v2 - tick() <= 0 or time() - v3 > 10 then
					break
				end
			end

			for _, emitter in ipairs(groundShockwave:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end
	end)
	local clone2 = V.Phase2.ScaleModel:Clone()
	clone2:ScaleTo(sizeMultiplier)
	local explosionSphere = clone2.ExplosionSphere
	explosionSphere.CFrame = cframe
	Util.SetParentOverrideWithColor(explosionSphere, folder, player2, "DragonFruitVFXColor")
	destroyAfter(explosionSphere, 7)

	for _, emitter in ipairs(explosionSphere:GetDescendants()) do
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

	task.wait(0.225)
	local sphere = clone2.Sphere
	sphere.CFrame = cframe
	Util.SetParentOverrideWithColor(sphere, folder, player2, "DragonFruitVFXColor")
	task.delay(0.05, function()
		Util.ColorShiftObjectDescendants(sphere, player2, "DragonFruitVFXColor")
	end)
	destroyAfter(sphere, 7)
	sphere.Size = createVector(10, 10, 10) * sizeMultiplier
	local size = createVector(200, 200, 200) * sizeMultiplier
	TweenService:Create(sphere, TweenInfo.new(1), {
		Size = size
	}):Play()
	local sphereRing = clone2.SphereRing
	sphereRing:SetPrimaryPartCFrame(cframe)
	Util.SetParentOverrideWithColor(sphereRing, folder, player2, "DragonFruitVFXColor")
	destroyAfter(sphereRing, 7)
	task.spawn(function()
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 1 * sizeMultiplier
		TweenService:Create(numberValue, TweenInfo.new(0.9), {
			Value = 20 * sizeMultiplier
		}):Play()
		local beamsByBeam = {}

		for _, folder2 in ipairs(sphereRing:GetChildren()) do
			local v2 = math.random(20, 50) / 10

			for _, beam in ipairs(folder2:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				beamsByBeam[beam] = beam
				TweenService:Create(beam, TweenInfo.new(0.9), {
					TextureSpeed = beam.TextureSpeed * v2
				}):Play()
			end
		end

		local v2 = time()

		for _ = 1, 600 do
			sphereRing:ScaleTo(numberValue.Value)
			task.wait()
			local value = numberValue.Value

			if 20 * sizeMultiplier <= value or time() - v2 > 10 then
				break
			end
		end

		numberValue:Destroy()

		for _, v3 in pairs(beamsByBeam) do
			TweenService:Create(v3, TweenInfo.new(0.25), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end
	end)
	task.spawn(function()
		ScreenEffect(player2, folder)
	end)
	task.wait(0.9)
	local sphereAura = clone2.SphereAura
	sphereAura.CFrame = cframe
	Util.SetParentOverrideWithColor(sphereAura, folder, player2, "DragonFruitVFXColor")
	destroyAfter(sphereAura, 7)

	for _, emitter in ipairs(sphereAura:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:Emit(emitter:GetAttribute("EmitCount"))
		emitter.Enabled = true
	end

	task.spawn(function()
		local function SphereRays(player3, folder2, cframe2)
			local v2 = size
			local clonesByClone = {}

			for _ = 1, 3 do
				local clone3 = clone2.Ray.StartImpact:Clone()
				clone3.CFrame = cframe2
				Util.SetParentOverrideWithColor(clone3, folder2, player3, "DragonFruitVFXColor")
				destroyAfter(clone3, 7)
				clonesByClone[clone3] = clone3
				clone3:SetAttribute("Busy", false)
			end

			local clonesByClone2 = {}

			for _ = 1, 3 do
				local clone3 = clone2.Ray.BeamAura:Clone()
				clone3.CFrame = cframe2
				Util.SetParentOverrideWithColor(clone3, folder2, player3, "DragonFruitVFXColor")
				destroyAfter(clone3, 7)
				clonesByClone2[clone3] = clone3
				clone3:SetAttribute("Busy", false)
			end

			local lastTime = tick()
			local lastTime2 = tick()
			local v3 = time()
			local clonesByClone3 = {}

			for _ = 1, 600 do
				if tick() - lastTime2 >= 0.025 and tick() - lastTime < 1.13 then
					lastTime2 = tick()

					for _ = 1, math.random(1, 1) do
						task.spawn(function()
							math.random(1, 3)
							v2 = math.random(100, 200)
							local clone3 = nil
							local clone4 = nil

							for _, v5 in pairs(clonesByClone) do
								if v5:GetAttribute("Busy") ~= false then
									continue
								end

								v5:SetAttribute("Busy", true)
								local v6 = v5
								task.spawn(function()
									task.wait(0.025)
									v6:SetAttribute("Busy", false)
								end)
								clone4 = v5
								break
							end

							if clone4 == nil then
								clone4 = clone2.Ray.StartImpact:Clone()
								clone4.CFrame = cframe2
								Util.SetParentOverrideWithColor(clone4, folder2, player3, "DragonFruitVFXColor")
								destroyAfter(clone4, 7)
								clonesByClone[clone4] = clone4
								clone4:SetAttribute("Busy", true)
								task.spawn(function()
									task.wait(0.025)
									clone4:SetAttribute("Busy", false)
								end)
							end

							for _, v6 in pairs(clonesByClone2) do
								if v6:GetAttribute("Busy") ~= false then
									continue
								end

								v6:SetAttribute("Busy", true)
								local v7 = v6
								task.spawn(function()
									task.wait(0.025)
									v7:SetAttribute("Busy", false)
								end)
								clone3 = v6
								break
							end

							if clone3 == nil then
								clone3 = clone2.Ray.RayBeamAura:Clone()
								clone3.CFrame = cframe2
								Util.SetParentOverrideWithColor(clone3, folder2, player3, "DragonFruitVFXColor")
								destroyAfter(clone3, 7)
								clonesByClone[clone3] = clone3
								clone3:SetAttribute("Busy", true)
								task.spawn(function()
									task.wait(0.025)
									clone3:SetAttribute("Busy", false)
								end)
							end

							local clone5 = clone2.Ray.CrackBeam:Clone()
							clonesByClone3[clone5] = clone5
							clone5.CFrame = cframe2 * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							)
							clone5.CFrame *= CFrame.new(0, 0, -101 * sizeMultiplier)
							Util.SetParentOverrideWithColor(clone5, folder2, player3, "DragonFruitVFXColor")
							destroyAfter(clone5, 7)
							local _, v6 = Workspace:FindPartOnRayWithIgnoreList(
								Ray.new(
									clone5.Position,
									CFrame.new(clone5.Position, clone5.CFrame * CFrame.new(0, 0, -v2).Position).LookVector * v2
								),
								raycastParams.FilterDescendantsInstances
							)
							local magnitude = (clone5.Position - v6).Magnitude
							local attach1 = clone5.Attach1
							attach1.Position = Vector3.new(0, 0, -magnitude)
							local v7 = magnitude / v2 * 0.15
							local tween = TweenService:Create(
								attach1,
								TweenInfo.new(v7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									Position = attach1.Position
								}
							)
							attach1.Position = createVector(0, 0, 0)
							tween:Play()
							clone4.CFrame = clone5.CFrame

							for _, emitter in ipairs(clone4:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end

							clone3.CFrame = clone5.CFrame
							clone3.Size = Vector3.new(0, 0, magnitude)
							clone3.CFrame *= CFrame.new(0, 0, -clone3.Size.Z / 2)

							for _, emitter in ipairs(clone3:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end

							for _, beam in ipairs(clone5:GetDescendants()) do
								if not beam:IsA("Beam") then
									continue
								end

								local width = beam.Width0 * math.random(10, 20) / 10 * sizeMultiplier
								local width2 = beam.Width1 * math.random(10, 30) / 10 * sizeMultiplier
								local tween2 = TweenService:Create(
									beam,
									TweenInfo.new(v7 / 2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
									{
										Width0 = width,
										Width1 = width2
									}
								)
								beam.Width0 = 0
								beam.Width1 = 0
								tween2:Play()
								local v10 = beam
								task.spawn(function()
									tween2.Completed:Wait()
									task.wait(0.15 + math.random(1, 10) / 100)
									tween2 = TweenService:Create(
										v10,
										TweenInfo.new(0.175, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Width0 = 0,
											Width1 = 0
										}
									)
									tween2:Play()
								end)
							end
						end)
					end
				end

				task.wait()

				if tick() - lastTime >= 1.13 or time() - v3 > 10 then
					break
				end
			end

			for _, v4 in pairs(clonesByClone) do
				v4:Destroy()
			end

			for _, v4 in pairs(clonesByClone2) do
				v4:Destroy()
			end

			for _, v4 in pairs(clonesByClone3) do
				v4:Destroy()
			end

			clonesByClone = nil
			clonesByClone2 = nil
			clonesByClone3 = nil
		end

		SphereRays(player2, folder, cframe)
	end)
	task.wait(0.5)
	local crack = clone2.Crack
	crack.CFrame = cframe
	Util.SetParentOverrideWithColor(crack, folder, player2, "DragonFruitVFXColor")
	destroyAfter(crack, 7)

	for _, emitter in ipairs(crack:GetDescendants()) do
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

	local clonesByClone = {}

	for _ = 1, 3 do
		local clone3 = clone2.SphereCrack:Clone()
		clone3.CFrame = cframe * CFrame.Angles(
			math.rad((math.random(-90, 90))),
			math.rad((math.random(-90, 90))),
			(math.rad((math.random(-90, 90))))
		)
		Util.SetParentOverrideWithColor(clone3, folder, player2, "DragonFruitVFXColor")
		destroyAfter(clone3, 7)
		clone3.Size = size
		clonesByClone[clone3] = clone3

		for _, emitter in ipairs(crack:GetDescendants()) do
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

		task.wait(WAIT_INTERVAL)
	end

	task.wait(WAIT_INTERVAL)
	local tween = TweenService:Create(sphere, TweenInfo.new(0.15), {
		Color = Util.WrapColor3Constructor(Color3.fromRGB(202, 164, 102), player2, "DragonFruitVFXColor")
	})
	tween:Play()
	tween.Completed:Wait()
	crack.Crack2:Destroy()
	task.spawn(function()
		task.spawn(function()
			local clone3 = V.Phase3.ScreenColor:Clone()

			if player2 == game.Players.LocalPlayer or (Workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude < 300 then
				Util.SetParentOverrideWithColor(clone3, Lighting, player2, "DragonFruitVFXColor")
			end

			destroyAfter(clone3, 7)
			local tween2 = TweenService:Create(clone3, TweenInfo.new(0.025), {
				Brightness = clone3.Brightness,
				Contrast = clone3.Contrast,
				Saturation = clone3.Saturation,
				TintColor = clone3.TintColor
			})
			clone3.Brightness = 0
			clone3.Contrast = 0
			clone3.Saturation = 0
			clone3.TintColor = Util.WrapColor3ConstructorForTintColor(
				Color3.fromRGB(255, 255, 255),
				player2,
				"DragonFruitVFXColor"
			)
			tween2:Play()
			task.wait(0.05)
			local tween3 = TweenService:Create(clone3, TweenInfo.new(0.0125), {
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(255, 255, 255),
					player2,
					"DragonFruitVFXColor"
				),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			})
			tween3:Play()
			tween3.Completed:Wait()
			clone3:Destroy()
		end)
		task.spawn(function()
			local clone3 = V.Phase3.Bloom:Clone()

			if player2 == game.Players.LocalPlayer or (Workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude < 300 then
				Util.SetParentOverrideWithColor(clone3, Lighting, player2, "DragonFruitVFXColor")
			end

			destroyAfter(clone3, 7)
			local tween2 = TweenService:Create(clone3, TweenInfo.new(0.15), {
				Size = 50,
				Threshold = 1.5
			})
			tween2:Play()
			tween2.Completed:Wait()
			task.wait(0.15)
			local tween3 = TweenService:Create(clone3, TweenInfo.new(0.25), {
				Size = 24,
				Threshold = 2
			})
			tween3:Play()
			tween3.Completed:Wait()
			clone3:Destroy()
		end)
		task.wait(0.065)
		local clone3 = V.Phase3.ScreenColor2:Clone()

		if player2 == game.Players.LocalPlayer or (Workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude < 300 then
			Util.SetParentOverrideWithColor(clone3, Lighting, player2, "DragonFruitVFXColor")
		end

		destroyAfter(clone3, 7)
		local tween2 = TweenService:Create(clone3, TweenInfo.new(0.07), {
			Brightness = clone3.Brightness,
			Contrast = clone3.Contrast,
			Saturation = clone3.Saturation,
			TintColor = clone3.TintColor
		})
		clone3.Brightness = 0
		clone3.Contrast = 0
		clone3.Saturation = 0
		clone3.TintColor = Util.WrapColor3ConstructorForTintColor(
			Color3.fromRGB(255, 255, 255),
			player2,
			"DragonFruitVFXColor"
		)
		tween2:Play()
		tween2.Completed:Wait()
		task.wait(0.07)
		local tween3 = TweenService:Create(clone3, TweenInfo.new(0.05), {
			TintColor = Util.WrapColor3ConstructorForTintColor(
				Color3.fromRGB(255, 255, 255),
				player2,
				"DragonFruitVFXColor"
			),
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		})
		tween3:Play()
		tween3.Completed:Wait()
		clone3:Destroy()
	end)

	for _, v2 in pairs(clonesByClone) do
		v2:Destroy()
	end

	sphere:Destroy()
	sphereRing:Destroy()

	for _, emitter in ipairs(sphereAura:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	if player2 == game.Players.LocalPlayer or (Workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude < 300 then
		Util.CameraShaker:ShakeOnce(24, 18, 0.2, 1.4)
	end

	local clone3 = V.Phase3.ScaleModel:Clone()
	clone3:ScaleTo(sizeMultiplier)
	local sphereExplosion = clone3.SphereExplosion
	sphereExplosion.CFrame = cframe
	Util.SetParentOverrideWithColor(sphereExplosion, folder, player2, "DragonFruitVFXColor")
	destroyAfter(sphereExplosion, 7)

	for _, emitter in ipairs(sphereExplosion:GetDescendants()) do
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

	local sphereExplosion2 = clone3.SphereExplosion2
	sphereExplosion2.CFrame = cframe
	Util.SetParentOverrideWithColor(sphereExplosion2, folder, player2, "DragonFruitVFXColor")
	destroyAfter(sphereExplosion2, 7)

	for _, emitter in ipairs(sphereExplosion2:GetDescendants()) do
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

	local raycastResult = Workspace:Raycast(
		cframe.Position + createVector(0, 1, 0),
		createVector(-0, -50, -0),
		raycastParams
	)

	if raycastResult then
		local v2 = AlignCFrame(player2, CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.001
		local cframe2 = CFrame.new(v2.Position, v2.Position + cframe.LookVector)
		task.spawn(function()
			local groundExplosion2 = clone3.GroundExplosion2
			groundExplosion2.CFrame = cframe2
			Util.SetParentOverrideWithColor(groundExplosion2, folder, player2, "DragonFruitVFXColor")
			destroyAfter(groundExplosion2, 7)

			for _, emitter in ipairs(groundExplosion2:GetDescendants()) do
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

			local groundImpact = clone3.GroundImpact
			groundImpact.CFrame = cframe2
			Util.SetParentOverrideWithColor(groundImpact, folder, player2, "DragonFruitVFXColor")
			destroyAfter(groundImpact, 7)

			for _, emitter in ipairs(groundImpact:GetDescendants()) do
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

			local spinImpact = clone3.SpinImpact
			spinImpact.CFrame = cframe2
			Util.SetParentOverrideWithColor(spinImpact, folder, player2, "DragonFruitVFXColor")
			destroyAfter(spinImpact, 7)

			for _, emitter in ipairs(spinImpact:GetDescendants()) do
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
		local groundBurn = clone3.GroundBurn
		groundBurn.CFrame = cframe2
		Util.SetParentOverrideWithColor(groundBurn, folder, player2, "DragonFruitVFXColor")
		destroyAfter(groundBurn, 7)
		local emittersByEmitter = {}

		for _, emitter in ipairs(groundBurn:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emittersByEmitter[emitter] = emitter
		end

		task.spawn(function()
			local function RocksFlyVelocityCallbackFunction2(_, instance, p)
				local vector2 = Vector3.new(math.random(-30, 30) / 2, 0, math.random(-30, 30) / 2)
				local vector3 = Vector3.new(0, math.random(150, 200) / 1.25, 0)
				local v3 = math.random(120, 180) * sizeMultiplier
				instance.Velocity = CFrame.new(p.Position, p.Position + vector2 + vector3).LookVector * v3
				task.delay(0.07, function()
					instance:Destroy()
				end)
			end

			GroundFlyRocks(player2, raycastResult, folder, {
				RockAmount = 25,
				RockSize = 12,
				PositionOffset = 125,
				RockRotationAmount = 7,
				RockRotationSpeed = 0.15,
				RockRotationPower = 100,
				Duration = 0.75
			}, RocksFlyVelocityCallbackFunction2, sizeMultiplier, clone3)
		end)
		local v3 = 1 + tick()
		local v4 = time()

		for _ = 1, 600 do
			for _, v5 in pairs(emittersByEmitter) do
				v5:Emit(1)
			end

			task.wait(WAIT_INTERVAL)

			if v3 - tick() <= 0 or time() - v4 > 10 then
				break
			end
		end

		for _, emitter in ipairs(groundBurn:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end

	task.wait(1)
	clone:Destroy()
	clone2:Destroy()
	clone3:Destroy()
end