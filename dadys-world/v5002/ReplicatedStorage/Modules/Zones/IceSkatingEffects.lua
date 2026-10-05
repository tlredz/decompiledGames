local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local InputService = require(game.ReplicatedStorage.SharedUtils.InputService)
local IceSkatingEffects_VectorForce = require(game.ReplicatedStorage.Modules.Zones.IceSkatingEffects_VectorForce)
local CollectionService = game:GetService("CollectionService")
local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local Audio = require(game.ReplicatedStorage.SharedUtils.Audio)
local v = nil
pcall(function()
	local SoundGroupManager = require(game.ReplicatedStorage.Modules.Audio.SoundGroupManager)
	v = SoundGroupManager
end)

local function debugPrint(...) end

local IceSkatingEffects = {}
local v2 = {
	trails = {},
	sounds = {},
	connections = {},
	active = false,
	preset = nil,
	vectorForceState = nil,
	bodyVelocityState = nil,
	speedTween = nil,
	sprintBoostActive = false,
	baseSpeedOriginal = nil,
	slideBoostOriginal = nil,
	slideDecayOriginal = nil,
	sprintBoostTween = nil,
	pendingActivation = nil
}
local v3 = {
	Flutter = true,
	Rudie = true
}

local function IsDashTower(instance)
	local config = instance and instance:FindFirstChild("Config")
	local moduleName = config and config:FindFirstChild("ModuleName")
	return moduleName ~= nil and v3[moduleName.Value] == true
end

local function ShouldPausePhysics()
	local character = v2.character
	local humanoid = v2.humanoid

	if not (character and humanoid) or humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then
		return true
	end

	if character:FindFirstChild("Grabbed") or character:FindFirstChild("Invincible") then
		return true
	end

	local decoding = character:FindFirstChild("Decoding")

	if decoding and decoding.Value ~= nil or character:FindFirstChild("BoxAbilityActive") or character:GetAttribute("HoldAbilityActive") then
		return true
	end

	local grabbing = character:FindFirstChild("Grabbing")

	if grabbing and grabbing:IsA("BoolValue") and grabbing.Value == true or character:GetAttribute("Ragdolled") then
		return true
	end

	if character:GetAttribute("AbilityAnimationActive") then
		local config = character and character:FindFirstChild("Config")
		local moduleName = config and config:FindFirstChild("ModuleName")
		local v4

		if moduleName == nil then
			v4 = false
		else
			v4 = v3[moduleName.Value] == true
		end

		if v4 then
			return true
		end
	end

	if character:GetAttribute("Transforming") then
		return true
	end

	return false
end

function IceSkatingEffects.Init(player, character)
	debugPrint("[IceSkatingEffects] Initializing for", player.Name)

	if v2.active then
		debugPrint("[IceSkatingEffects] Cleaning up stale effects from previous character...")

		for _, connection in ipairs(v2.connections) do
			if connection and connection.Connected then
				connection:Disconnect()
			end
		end

		v2.connections = {}
		v2.active = false
		v2.trails = {}
		v2.sounds = {}
		v2.vectorForceState = nil
		v2.bodyVelocityState = nil
		v2.speedTween = nil
		v2.skatingAnimState = nil
		v2.circleSkatingState = nil
		v2.armBalanceState = nil
		v2.panicEmitter = nil
		v2.blur = nil
		v2.sprintBlur = nil
		v2.modifiersApplied = nil
		v2.appliedMultiplier = nil
		v2.baseWalkSpeed = nil
		v2.targetWalkSpeed = nil
		v2.baseWalkSpeedAtStart = nil
		v2.iceBuffTracking = nil
		debugPrint("[IceSkatingEffects] Stale effects cleaned up")
	end

	v2.player = player
	v2.character = character
	local success, result = pcall(function()
		v2.humanoid = character:WaitForChild("Humanoid", 5)
		v2.rootPart = character:WaitForChild("HumanoidRootPart", 5)
		v2.camera = workspace.CurrentCamera
	end)

	if not success then
		warn("[IceSkatingEffects] Init failed:", result)
		return false
	end

	debugPrint("[IceSkatingEffects] Init successful - Character ready")
	debugPrint("[IceSkatingEffects] Character parts:")

	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			debugPrint("  -", part.Name, part.ClassName)
		end
	end

	if not v2.pendingActivation then
		return true
	end

	local pendingActivation = v2.pendingActivation
	v2.pendingActivation = nil
	debugPrint("[IceSkatingEffects] Applying pending activation - Preset:", pendingActivation.presetName)
	task.defer(function()
		IceSkatingEffects.Activate(pendingActivation.presetName, pendingActivation.config)
	end)
	return true
end

function IceSkatingEffects.CreateTrails()
	local IMAGE_ID = "rbxasset://textures/particles/sparkles_main.dds"
	local v4 = {}
	local character = v2.character

	if not character then
		return v4
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		warn("[IceSkatingEffects] No HumanoidRootPart found")
		return v4
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "LeftSkateStart"
	attachment.Position = createVector(-0.7, -1.2, 0.3)
	attachment.Parent = humanoidRootPart
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "LeftSkateEnd"
	attachment2.Position = createVector(-0.7, -1.2, -0.3)
	attachment2.Parent = humanoidRootPart
	local trail = Instance.new("Trail")
	trail.Name = "LeftSkateTrail"
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Lifetime = 1.2
	trail.MinLength = 0.05
	trail.Color = ColorSequence.new(Color3.fromRGB(200, 240, 255))
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0.15) })
	trail.LightEmission = 1
	trail.Enabled = true
	trail.Parent = humanoidRootPart
	local attachment3 = Instance.new("Attachment")
	attachment3.Name = "RightSkateStart"
	attachment3.Position = createVector(0.7, -1.2, 0.3)
	attachment3.Parent = humanoidRootPart
	local attachment4 = Instance.new("Attachment")
	attachment4.Name = "RightSkateEnd"
	attachment4.Position = createVector(0.7, -1.2, -0.3)
	attachment4.Parent = humanoidRootPart
	local trail2 = Instance.new("Trail")
	trail2.Name = "RightSkateTrail"
	trail2.Attachment0 = attachment3
	trail2.Attachment1 = attachment4
	trail2.Lifetime = 1.2
	trail2.MinLength = 0.05
	trail2.Color = ColorSequence.new(Color3.fromRGB(200, 240, 255))
	trail2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail2.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0.15) })
	trail2.LightEmission = 1
	trail2.Enabled = true
	trail2.Parent = humanoidRootPart
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "IceSparkles"
	particleEmitter.Texture = IMAGE_ID
	particleEmitter.Rate = 30
	particleEmitter.Lifetime = NumberRange.new(0.5, 1)
	particleEmitter.Speed = NumberRange.new(2, 5)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 240, 255))
	particleEmitter.LightEmission = 1
	particleEmitter.Size = NumberSequence.new(0.15, 0)
	particleEmitter.Enabled = true
	particleEmitter.Parent = humanoidRootPart
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Name = "IceDust"
	particleEmitter2.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter2.Rate = 40
	particleEmitter2.Lifetime = NumberRange.new(0.3, 0.8)
	particleEmitter2.Speed = NumberRange.new(3, 8)
	particleEmitter2.SpreadAngle = Vector2.new(30, 30)
	particleEmitter2.Color = ColorSequence.new(Color3.fromRGB(220, 240, 255))
	particleEmitter2.LightEmission = 0.5
	particleEmitter2.Size = NumberSequence.new(0.3, 0.8)
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.EmissionDirection = Enum.NormalId.Top
	particleEmitter2.Enabled = true
	particleEmitter2.Parent = humanoidRootPart
	local particleEmitter3 = Instance.new("ParticleEmitter")
	particleEmitter3.Name = "IceSpeedLines"
	particleEmitter3.Texture = IMAGE_ID
	particleEmitter3.Rate = 0
	particleEmitter3.Lifetime = NumberRange.new(0.2, 0.4)
	particleEmitter3.Speed = NumberRange.new(15, 25)
	particleEmitter3.SpreadAngle = Vector2.new(180, 180)
	particleEmitter3.Color = ColorSequence.new(Color3.fromRGB(200, 230, 255))
	particleEmitter3.LightEmission = 0.8
	particleEmitter3.Size = NumberSequence.new(0.1, 0.3)
	particleEmitter3.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter3.Enabled = false
	particleEmitter3.Parent = humanoidRootPart
	local camera = v2.camera
	local particleEmitter4 = nil
	local colorCorrectionEffect = nil
	local activeConfig = v2.activeConfig or {}
	local bloomEffect, sunRaysEffect, depthOfFieldEffect

	if camera then
		if activeConfig.useScreenSnow ~= false then
			particleEmitter4 = Instance.new("ParticleEmitter")
			particleEmitter4.Name = "ScreenSnowflakes"
			particleEmitter4.Texture = IMAGE_ID
			particleEmitter4.Rate = 8
			particleEmitter4.Lifetime = NumberRange.new(3, 5)
			particleEmitter4.Speed = NumberRange.new(2, 4)
			particleEmitter4.SpreadAngle = Vector2.new(180, 0)
			particleEmitter4.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			particleEmitter4.LightEmission = 0.8
			particleEmitter4.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.1),
				NumberSequenceKeypoint.new(0.5, 0.15),
				NumberSequenceKeypoint.new(1, 0.05)
			})
			particleEmitter4.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(0.5, 0.5),
				NumberSequenceKeypoint.new(1, 1)
			})
			particleEmitter4.Rotation = NumberRange.new(0, 360)
			particleEmitter4.RotSpeed = NumberRange.new(-20, 20)
			particleEmitter4.EmissionDirection = Enum.NormalId.Bottom
			particleEmitter4.Enabled = true
			particleEmitter4.Parent = humanoidRootPart
		end

		if activeConfig.useBlueTint ~= false then
			local winterBlueTint = camera:FindFirstChild("WinterBlueTint")

			if winterBlueTint then
				winterBlueTint:Destroy()
			end

			colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Name = "WinterBlueTint"
			colorCorrectionEffect.Saturation = 0
			colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
			colorCorrectionEffect.Contrast = 0
			colorCorrectionEffect.Brightness = 0
			colorCorrectionEffect.Enabled = true
			colorCorrectionEffect.Parent = camera
			local color = Color3.fromRGB(200, 220, 255)
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Saturation = -0.25,
					TintColor = color,
					Contrast = 0.12,
					Brightness = 0.05
				}
			):Play()
		end

		local iceSkatingBloom = camera:FindFirstChild("IceSkatingBloom")

		if iceSkatingBloom then
			iceSkatingBloom:Destroy()
		end

		bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Name = "IceSkatingBloom"
		bloomEffect.Intensity = 0.4
		bloomEffect.Size = 24
		bloomEffect.Threshold = 0.8
		bloomEffect.Enabled = false
		bloomEffect.Parent = camera
		local iceSkatingSunRays = camera:FindFirstChild("IceSkatingSunRays")

		if iceSkatingSunRays then
			iceSkatingSunRays:Destroy()
		end

		sunRaysEffect = Instance.new("SunRaysEffect")
		sunRaysEffect.Name = "IceSkatingSunRays"
		sunRaysEffect.Intensity = 0.15
		sunRaysEffect.Spread = 0.25
		sunRaysEffect.Enabled = false
		sunRaysEffect.Parent = camera
		local iceSkatingDepthOfField = camera:FindFirstChild("IceSkatingDepthOfField")

		if iceSkatingDepthOfField then
			iceSkatingDepthOfField:Destroy()
		end

		depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
		depthOfFieldEffect.Name = "IceSkatingDepthOfField"
		depthOfFieldEffect.FocusDistance = 10
		depthOfFieldEffect.InFocusRadius = 15
		depthOfFieldEffect.NearIntensity = 0
		depthOfFieldEffect.FarIntensity = 0
		depthOfFieldEffect.Enabled = false
		depthOfFieldEffect.Parent = camera
	end

	table.insert(v4, {
		leftTrail = trail,
		rightTrail = trail2,
		sparkles = particleEmitter,
		iceDust = particleEmitter2,
		speedLines = particleEmitter3,
		screenSnow = particleEmitter4,
		blueTint = colorCorrectionEffect,
		bloom = bloomEffect,
		sunRays = sunRaysEffect,
		depthOfField = depthOfFieldEffect,
		leftAtt0 = attachment,
		leftAtt1 = attachment2,
		rightAtt0 = attachment3,
		rightAtt1 = attachment4
	})
	local v5 = { "dual skate trails", "ice dust", "speed lines" }

	if particleEmitter4 then
		table.insert(v5, "screen snow")
	end

	if colorCorrectionEffect then
		table.insert(v5, "blue winter tint")
	end

	table.insert(v5, "lighting effects (Bloom/SunRays/DepthOfField)")
	debugPrint("[IceSkatingEffects] Created " .. table.concat(v5, " + "))
	return v4
end

function IceSkatingEffects.SetupMomentum(data)
	local rootPart = v2.rootPart
	local humanoid = v2.humanoid
	local _ = v2.player
	local character = v2.character
	rootPart.CustomPhysicalProperties = PhysicalProperties.new(
		data.density or 0.5,
		data.friction or 0,
		data.elasticity or 0.02,
		data.frictionWeight or 100,
		data.elasticityWeight or 1
	)
	humanoid.MaxSlopeAngle = 89

	if v2.modifiersApplied then
		debugPrint("[IceSkatingEffects] SetupMomentum: SpeedModifiers already applied, skipping")
	else
		local walkSpeedMultiplier = data.walkSpeedMultiplier or 1.8
		v2.modifiersApplied = true
		v2.appliedMultiplier = walkSpeedMultiplier
		debugPrint(
			"[IceSkatingEffects] SetupMomentum: Speed mods handled server-side, tracking multiplier:",
			walkSpeedMultiplier
		)
	end

	local baseSkatingSpeed = data.baseSkatingSpeed or 24
	local maxSpeedMultiplier = data.maxSpeedMultiplier or 3.5
	local accelerationRate = data.accelerationRate or 0.8
	local decelerationRate = data.decelerationRate or 0.6
	local slideBoost = data.slideBoost or 1
	v2.baseSkatingSpeed = baseSkatingSpeed
	local v4 = 1
	local v5 = false
	local stats = character:FindFirstChild("Stats")
	v2.iceBuffTracking = {
		baseWalkSpeed = 16,
		baseRunSpeed = 16,
		baseSpeedMod = 1,
		baseRunSpeedMod = 1,
		iceSpeedMultiplier = v2.appliedMultiplier or 1,
		maxExternalBuffFactor = data.maxExternalBuffFactor or 2.5
	}

	if stats then
		local walkSpeed = stats:FindFirstChild("WalkSpeed")
		local runSpeed = stats:FindFirstChild("RunSpeed")
		local speedModifier = stats:FindFirstChild("SpeedModifier")
		local runSpeedModifier = stats:FindFirstChild("RunSpeedModifier")

		if walkSpeed then
			v2.iceBuffTracking.baseWalkSpeed = walkSpeed.Value
		end

		if runSpeed then
			v2.iceBuffTracking.baseRunSpeed = runSpeed.Value
		end

		if speedModifier then
			local appliedMultiplier = v2.appliedMultiplier or 1
			v2.iceBuffTracking.baseSpeedMod = speedModifier.Value / appliedMultiplier
		end

		if runSpeedModifier then
			local appliedMultiplier = v2.appliedMultiplier or 1
			v2.iceBuffTracking.baseRunSpeedMod = runSpeedModifier.Value / appliedMultiplier
		end
	end

	v2.baseWalkSpeedAtStart = v2.iceBuffTracking.baseWalkSpeed

	local function getExternalSpeedFactor()
		local stats2 = character:FindFirstChild("Stats")

		if not stats2 then
			return 1
		end

		local iceBuffTracking = v2.iceBuffTracking

		if not iceBuffTracking then
			return 1
		end

		local speedModifier = stats2:FindFirstChild("SpeedModifier")
		local lastMultiplicativeFactor

		if speedModifier and iceBuffTracking.baseSpeedMod > 0 then
			local appliedMultiplier = v2.appliedMultiplier or 1
			lastMultiplicativeFactor = speedModifier.Value / appliedMultiplier / iceBuffTracking.baseSpeedMod
		else
			lastMultiplicativeFactor = 1
		end

		local walkSpeed = stats2:FindFirstChild("WalkSpeed")
		local lastAdditiveFactor = not (walkSpeed and iceBuffTracking.baseWalkSpeed > 0) and 1 or walkSpeed.Value / iceBuffTracking.baseWalkSpeed
		local lastTotalFactor = lastMultiplicativeFactor * lastAdditiveFactor
		local lastCappedFactor = math.clamp(lastTotalFactor, 0.25, iceBuffTracking.maxExternalBuffFactor or 2.5)
		v2.iceBuffTracking.lastMultiplicativeFactor = lastMultiplicativeFactor
		v2.iceBuffTracking.lastAdditiveFactor = lastAdditiveFactor
		v2.iceBuffTracking.lastTotalFactor = lastTotalFactor
		v2.iceBuffTracking.lastCappedFactor = lastCappedFactor
		return lastCappedFactor
	end

	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if not (v2.active and rootPart and rootPart.Parent) then
			return
		end

		if ShouldPausePhysics() then
			v4 = 1
			v5 = false
			local character2 = v2.character
			local decoding = character2 and character2:FindFirstChild("Decoding")
			local v6 = decoding and decoding.Value ~= nil
			local grabbed = character2 and character2:FindFirstChild("Grabbed")
			local transforming = character2 and character2:GetAttribute("Transforming")
			local holdAbilityActive = character2 and character2:GetAttribute("HoldAbilityActive")

			if v6 or grabbed or transforming or holdAbilityActive then
				local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
				rootPart.AssemblyLinearVelocity = Vector3.new(0, assemblyLinearVelocity.Y, 0)
			end
		else
			local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
			local vector2 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)
			local baseSkatingSpeed2 = v2.baseSkatingSpeed or baseSkatingSpeed
			local slideBoost2 = v2.slideBoost or slideBoost
			local state = humanoid:GetState()
			local magnitude = vector2.Magnitude
			local v6 = state == Enum.HumanoidStateType.Freefall
			local v7

			if assemblyLinearVelocity.Y > 0.5 then
				v7 = magnitude > 5
			else
				v7 = false
			end

			if v6 or v7 then
				local v8 = assemblyLinearVelocity.Y + -15 * dt

				if assemblyLinearVelocity.Y > 0 then
					v8 = math.max(assemblyLinearVelocity.Y * 0.6, v8)
				end

				rootPart.AssemblyLinearVelocity = Vector3.new(
					assemblyLinearVelocity.X,
					math.max(v8, -50),
					assemblyLinearVelocity.Z
				)
			elseif assemblyLinearVelocity.Y > 2 then
				rootPart.AssemblyLinearVelocity = Vector3.new(
					assemblyLinearVelocity.X,
					math.min(assemblyLinearVelocity.Y, 3),
					assemblyLinearVelocity.Z
				)
			end

			local v8 = humanoid.MoveDirection.Magnitude > 0.1

			if v8 then
				v4 = math.min(maxSpeedMultiplier, v4 + accelerationRate * dt)
				local v9 = humanoid.MoveDirection * (baseSkatingSpeed2 * getExternalSpeedFactor()) * v4
				rootPart.AssemblyLinearVelocity = Vector3.new(v9.X, assemblyLinearVelocity.Y, v9.Z)
			else
				local v9

				if v5 and slideBoost2 > 1 and vector2.Magnitude > 1 then
					local v10 = vector2 * slideBoost2
					rootPart.AssemblyLinearVelocity = Vector3.new(v10.X, assemblyLinearVelocity.Y, v10.Z)
					v9 = true
				else
					v9 = false
				end

				v4 = math.max(1, v4 - decelerationRate * dt)

				if not v9 and vector2.Magnitude > 0.5 then
					local v10 = vector2 * (v2.slideDecay or 0.95)
					rootPart.AssemblyLinearVelocity = Vector3.new(v10.X, assemblyLinearVelocity.Y, v10.Z)
				end
			end

			v5 = v8
		end
	end)
	table.insert(v2.connections, heartbeatConnection)
	debugPrint(
		"[IceSkatingEffects] Momentum system enabled (base speed:",
		baseSkatingSpeed .. ", max multiplier: " .. maxSpeedMultiplier .. "x, slideBoost: " .. slideBoost .. ")"
	)
end

function IceSkatingEffects.SetupFOV(data)
	local baseFOV = data.baseFOV or 70
	local maxFOV = data.maxFOV or 85
	local rootPart = v2.rootPart
	local humanoid = v2.humanoid
	local camera = v2.camera
	local useCameraBanking = data.useCameraBanking ~= false
	local useCameraShake = data.useCameraShake ~= false
	local useCameraBobbing = data.useCameraBobbing ~= false
	local useBlur = data.useBlur ~= false
	local maxCameraBankDegrees = data.maxCameraBankDegrees or 8
	local cameraShakeIntensity = data.cameraShakeIntensity or 0.15
	local cameraBobbingIntensity = data.cameraBobbingIntensity or 0.08
	local cameraBobbingSpeed = data.cameraBobbingSpeed or 12
	local blurEffect

	if useBlur then
		blurEffect = Instance.new("BlurEffect")
		blurEffect.Name = "IceSkatingBlur"
		blurEffect.Size = 0
		blurEffect.Parent = camera
	else
		blurEffect = nil
	end

	local v4 = createVector(0, 0, 0)
	local total = 0
	local _ = camera.CFrame
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if v2.active and rootPart and rootPart.Parent then
			local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
			local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude
			local moveDirection = humanoid.MoveDirection
			local v5 = math.clamp(magnitude / 30, 0, 1)

			if data.useFOV then
				local v6 = baseFOV + (maxFOV - baseFOV) * v5
				camera.FieldOfView += (v6 - camera.FieldOfView) * dt * 5
			end

			if blurEffect and useBlur then
				if v2.animationSpeedUpEnabled then
					local v6 = v5 * (data.maxBlurSize or 8)
					blurEffect.Size += (v6 - blurEffect.Size) * dt * 5
				else
					blurEffect.Size += (0 - blurEffect.Size) * dt * 8
				end
			end

			local v6 = v2.animationSpeedUpEnabled and v2.trails and #v2.trails > 0 and v2.trails[1]

			if v6 then
				local v7 = v5 * 0.24999999999999997 + 0.1
				local v8 = 0.8 - v5 * 0.7
				local numberSequence = NumberSequence.new({
					NumberSequenceKeypoint.new(0, v7),
					NumberSequenceKeypoint.new(1, v7 * 0.4)
				})
				local numberSequence2 = NumberSequence.new({
					NumberSequenceKeypoint.new(0, v8),
					NumberSequenceKeypoint.new(0.5, v8 + 0.3),
					NumberSequenceKeypoint.new(1, 1)
				})

				if v6.leftTrail then
					v6.leftTrail.WidthScale = numberSequence
					v6.leftTrail.Transparency = numberSequence2
				end

				if v6.rightTrail then
					v6.rightTrail.WidthScale = numberSequence
					v6.rightTrail.Transparency = numberSequence2
				end
			end

			local v7 = 0

			if data.useFOV and useCameraBanking and magnitude > 8 and moveDirection.Magnitude > 0.1 then
				local vector2 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)

				if vector2.Magnitude > 0.1 then
					v7 = -vector2.Unit:Cross(moveDirection).Y * math.rad(maxCameraBankDegrees) * v5
				end
			end

			local cframe = CFrame.new()

			if data.useFOV and useCameraShake and magnitude > 18 then
				local v8 = math.clamp((magnitude - 18) / 30 * cameraShakeIntensity, 0, cameraShakeIntensity)
				cframe = CFrame.new(
					(math.random() * 2 - 1) * v8,
					(math.random() * 2 - 1) * v8,
					(math.random() * 2 - 1) * v8 * 0.5
				)
			end

			local cframe2 = CFrame.new()

			if data.useFOV and useCameraBobbing and magnitude > 5 then
				total += dt * cameraBobbingSpeed * v5
				local v8 = math.sin(total) * cameraBobbingIntensity * v5
				cframe2 = CFrame.new(0, v8, 0)
			elseif magnitude <= 5 then
				total = 0
			end

			local cframe3 = CFrame.Angles(0, 0, v7)
			camera.CFrame = camera.CFrame * cframe3 * cframe * cframe2
			v4 = assemblyLinearVelocity
		elseif blurEffect and blurEffect.Parent then
			blurEffect.Size = math.max(0, blurEffect.Size - dt * 10)
		end
	end)
	table.insert(v2.connections, renderSteppedConnection)

	if not v2.blur then
		v2.blur = blurEffect
	end

	local v5 = { "FOV" }

	if useBlur then
		table.insert(v5, "Blur")
	end

	if useCameraBanking then
		table.insert(v5, "Banking")
	end

	if useCameraShake then
		table.insert(v5, "Shake")
	end

	if useCameraBobbing then
		table.insert(v5, "Bobbing")
	end

	debugPrint("[IceSkatingEffects] Camera effects enabled:", table.concat(v5, ", "))
end

function IceSkatingEffects.SetupAnimationSpeedUp(data)
	local humanoid = v2.humanoid
	local rootPart = v2.rootPart
	local character = v2.character

	if not (humanoid and rootPart and character) then
		debugPrint("[IceSkatingEffects] Missing humanoid/rootPart - animation speed-up disabled")
		return
	end

	local animationSpeedMultiplier = data.animationSpeedMultiplier or 1.3
	local maxEffectiveSpeed = data.maxEffectiveSpeed or 30
	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		warn("[IceSkatingEffects] No Animator found!")
		return
	end

	character:SetAttribute("DisableSprintAnimations", true)

	if not character:GetAttribute("IceSkatingMode") then
		warn("[IceSkatingEffects] WARNING: IceSkatingMode not set by server! Anti-cheat may trigger.")
	end

	local runAnimationId = character:GetAttribute("RunAnimationId")

	if not runAnimationId then
		local animations = character:FindFirstChild("Animations")

		if animations then
			local run = animations:FindFirstChild("Run")

			if run and run:IsA("Animation") then
				runAnimationId = run.AnimationId
			end
		end
	end

	if not runAnimationId then
		local animate = character:FindFirstChild("Animate")

		if animate then
			local run = animate:FindFirstChild("run")

			if run then
				local animation = run:FindFirstChildOfClass("Animation")

				if animation then
					runAnimationId = animation.AnimationId
				end
			end
		end
	end

	if not runAnimationId then
		warn("[IceSkatingEffects] Could not find run animation!")
		return
	end

	local walkAnimationId = character:GetAttribute("WalkAnimationId")

	if not walkAnimationId then
		local animations = character:FindFirstChild("Animations")

		if animations then
			local walk = animations:FindFirstChild("Walk")

			if walk and walk:IsA("Animation") then
				walkAnimationId = walk.AnimationId
			end
		end
	end

	if not walkAnimationId then
		local animate = character:FindFirstChild("Animate")

		if animate then
			local walk = animate:FindFirstChild("walk")

			if walk then
				local animation = walk:FindFirstChildOfClass("Animation")

				if animation then
					walkAnimationId = animation.AnimationId
				end
			end
		end
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = runAnimationId
	animation.Name = "IceSkatingRun"
	local track = animator:LoadAnimation(animation)
	track.Looped = true
	track.Priority = Enum.AnimationPriority.Action
	local track2

	if walkAnimationId then
		local animation2 = Instance.new("Animation")
		animation2.AnimationId = walkAnimationId
		animation2.Name = "IceSkatingWalk"
		track2 = animator:LoadAnimation(animation2)
		track2.Looped = true
		track2.Priority = Enum.AnimationPriority.Action
		debugPrint("[IceSkatingEffects] Loaded walk animation:", walkAnimationId)
	else
		track2 = nil
	end

	debugPrint("[IceSkatingEffects] Loaded run animation:", runAnimationId)
	local particleEmitter, attachment

	if data.useSkatingParticles == false then
		particleEmitter = nil
	else
		attachment = Instance.new("Attachment")
		attachment.Name = "IceSkatingSprayAttachment"
		attachment.CFrame = CFrame.new(0, -1.5, 0)
		attachment.Parent = rootPart
		particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "IceSkatingSpray"
		particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
		particleEmitter.Rate = 0
		particleEmitter.Lifetime = NumberRange.new(0.3, 0.5)
		particleEmitter.Speed = NumberRange.new(3, 6)
		particleEmitter.SpreadAngle = Vector2.new(60, 60)
		particleEmitter.Color = ColorSequence.new(Color3.fromRGB(220, 240, 255))
		particleEmitter.LightEmission = 0.4
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.5, 0.5),
			NumberSequenceKeypoint.new(1, 0.2)
		})
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.EmissionDirection = Enum.NormalId.Back
		particleEmitter.Enabled = true
		particleEmitter.Parent = attachment
		debugPrint("[IceSkatingEffects] Created ice spray particle (treadmill-style)")
	end

	v2.skatingAnimState = {
		runTrack = track,
		walkTrack = track2,
		runAnimation = animation,
		iceSprayParticle = particleEmitter,
		iceSprayAttachment = attachment,
		animationConnection = nil,
		currentAnimState = "idle",
		currentAnimSpeed = 1
	}
	local skatingAnimState = v2.skatingAnimState
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		if v2.active and rootPart and rootPart.Parent then
			if v2.animationSpeedUpEnabled == false then
				if track and track.IsPlaying then
					track:Stop(0.2)
				end

				if track2 and track2.IsPlaying then
					track2:Stop(0.2)
				end

				if particleEmitter then
					particleEmitter.Rate = 0
				end

				skatingAnimState.currentAnimState = "idle"
			else
				local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
				local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude
				local currentAnimState = magnitude >= 10 and "run" or magnitude >= 1 and "walk" or "idle"

				if currentAnimState ~= skatingAnimState.currentAnimState then
					if skatingAnimState.currentAnimState == "run" and track and track.IsPlaying then
						track:Stop(0.15)
					elseif skatingAnimState.currentAnimState == "walk" and track2 and track2.IsPlaying then
						track2:Stop(0.15)
					end

					if currentAnimState == "run" and track then
						track:Play(0.15)
					elseif currentAnimState == "walk" and track2 then
						track2:Play(0.15)
					end

					if currentAnimState ~= "idle" then
						for _, v5 in pairs(animator:GetPlayingAnimationTracks()) do
							if not (v5 ~= track and v5 ~= track2) then
								continue
							end

							local v6 = not v5.Animation and "" or v5.Animation.Name or ""

							if not (v6:lower():find("walk") or v6:lower():find("run") or v6:lower():find("sprint")) then
								continue
							end

							if not (v5.Priority.Value < Enum.AnimationPriority.Action.Value) then
								continue
							end

							v5:Stop(0)
						end
					end

					skatingAnimState.currentAnimState = currentAnimState
				end

				if currentAnimState == "idle" then
					skatingAnimState.currentAnimSpeed = 1
				else
					local v5 = 1 + math.min(magnitude / maxEffectiveSpeed, 1) * (animationSpeedMultiplier - 1)
					skatingAnimState.currentAnimSpeed += (v5 - skatingAnimState.currentAnimSpeed) * 0.048

					if currentAnimState == "run" and track then
						track:AdjustSpeed(skatingAnimState.currentAnimSpeed)
					elseif currentAnimState == "walk" and track2 then
						track2:AdjustSpeed(skatingAnimState.currentAnimSpeed)
					end
				end

				if particleEmitter then
					if magnitude > 10 then
						particleEmitter.Rate = math.clamp((magnitude - 10) / 15, 0, 1) * 35 + 15
					else
						particleEmitter.Rate = 0
					end
				end
			end
		else
			if track and track.IsPlaying then
				track:Stop(0.1)
			end

			if track2 and track2.IsPlaying then
				track2:Stop(0.1)
			end

			if particleEmitter then
				particleEmitter.Rate = 0
			end

			skatingAnimState.currentAnimState = "idle"
		end
	end)
	table.insert(v2.connections, heartbeatConnection)
	v2.skatingAnimState.animationConnection = heartbeatConnection
	debugPrint("[IceSkatingEffects] Animation system: velocity-based walk/run (walk:" .. (track2 and "yes" or "no") .. ", run at " .. 10 .. "+ studs/s, speed scale:" .. animationSpeedMultiplier .. "x)")
end

function IceSkatingEffects.SetupTilt(p)
	local character = v2.character
	local rootPart = v2.rootPart
	local humanoid = v2.humanoid
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("LowerTorso") or character:FindFirstChild("UpperTorso")

	if not torso then
		for _, bone in pairs(character:GetDescendants()) do
			if not bone:IsA("Bone") then
				continue
			end

			local name = bone.Name:lower()

			if not (name == "torso" or name == "lowertorso" or name == "uppertorso" or name == "spine") then
				continue
			end

			debugPrint("[IceSkatingEffects] Found torso bone:", bone.Name)
			torso = bone
			break
		end
	end

	if not torso then
		debugPrint("[IceSkatingEffects] No torso found - tilt disabled")
		return
	end

	local v4 = nil

	for _, motor6D in pairs(torso:GetChildren()) do
		if not motor6D:IsA("Motor6D") then
			continue
		end

		local v6 = not motor6D.Part0 and "" or motor6D.Part0.Name or ""
		local v7 = not motor6D.Part1 and "" or motor6D.Part1.Name or ""

		if not (v6:find("Root") or v7:find("Root")) then
			continue
		end

		v4 = motor6D
		break
	end

	if v4 then
		local C0 = v4.C0
		local maxTiltDegrees = p.maxTiltDegrees or 25
		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if not (v2.active and rootPart and rootPart.Parent) then
				v4.C0 = v4.C0:Lerp(C0, 0.1)
				return
			end

			local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
			local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude
			local moveDirection = humanoid.MoveDirection

			if not (moveDirection.Magnitude > 0.1 and magnitude > 5) then
				v4.C0 = v4.C0:Lerp(C0, 0.1)
				return
			end

			local v6 = math.clamp(
				Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Unit:Cross(moveDirection).Y * maxTiltDegrees,
				-maxTiltDegrees,
				maxTiltDegrees
			)
			local cframe = CFrame.Angles(0, 0, (math.rad(v6)))
			v4.C0 = v4.C0:Lerp(C0 * cframe, 0.15)
		end)
		table.insert(v2.connections, renderSteppedConnection)
		debugPrint("[IceSkatingEffects] Tilt enabled on", v4.Name)
	else
		debugPrint("[IceSkatingEffects] No root joint found in Torso - tilt disabled")
		debugPrint("[IceSkatingEffects] Available Motor6Ds:")

		for _, motor6D in pairs(torso:GetChildren()) do
			if motor6D:IsA("Motor6D") then
				print(
					"  -",
					motor6D.Name,
					"connects",
					not motor6D.Part0 and "nil" or motor6D.Part0.Name or "nil",
					"to",
					motor6D.Part1 and motor6D.Part1.Name or "nil"
				)
			end
		end
	end
end

function IceSkatingEffects.SetupCircleSkating(data)
	local rootPart = v2.rootPart
	local humanoid = v2.humanoid

	if not (rootPart and humanoid) then
		warn("[IceSkatingEffects] Cannot setup circle skating - missing rootPart or humanoid")
		return
	end

	local circleSpinForce = data.circleSpinForce or 2.5
	local circleMinSpeed = data.circleMinSpeed or 5
	math.rad(data.circleDetectionAngle or 45)
	local v4 = createVector(0, 0, 0)
	local attachment = Instance.new("Attachment")
	attachment.Name = "CircleSkatingAttachment"
	attachment.Parent = rootPart
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Name = "CircleSkatingSpin"
	alignOrientation.Attachment0 = attachment
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Responsiveness = 20
	alignOrientation.MaxTorque = 40000
	alignOrientation.PrimaryAxis = createVector(0, 1, 0)
	alignOrientation.Enabled = false
	alignOrientation.Parent = rootPart
	v2.circleSkatingState = {
		attachment = attachment,
		alignOrientation = alignOrientation
	}
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not (v2.active and rootPart and rootPart.Parent) then
			alignOrientation.Enabled = false
			return
		end

		local moveDirection = humanoid.MoveDirection
		local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
		local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude

		if magnitude < circleMinSpeed or moveDirection.Magnitude < 0.1 then
			alignOrientation.Enabled = false
			v4 = moveDirection
		else
			local Z = moveDirection.Z
			local X = moveDirection.X
			local v5 = Z < -0.3
			local v6 = math.abs(X) > 0.3

			if v5 and v6 then
				local v7 = -X
				local cFrame = rootPart.CFrame
				local v8 = cFrame - cFrame.Position
				local v9 = v7 * circleSpinForce * (magnitude / 20)
				local v10 = v8 * CFrame.Angles(0, math.rad(v9), 0)
				alignOrientation.CFrame = CFrame.new(rootPart.Position) * v10
				alignOrientation.Enabled = true

				if v2.panicEmitter then
					local v12 = math.clamp(magnitude / 20, 0, 1)
					v2.panicEmitter.Rate = v12 * 40 + 30
					v2.panicEmitter.Enabled = true
				end
			else
				alignOrientation.Enabled = false

				if v2.panicEmitter then
					local _ = v2.panicEmitter.Enabled
				end
			end

			v4 = moveDirection
		end
	end)
	table.insert(v2.connections, heartbeatConnection)
	debugPrint("[IceSkatingEffects] Circle skating enabled (forward + left/right = spin boost)")
end

function IceSkatingEffects.SetupPanicEffects(_)
	local rootPart = v2.rootPart
	local humanoid = v2.humanoid

	if not (rootPart and humanoid) then
		warn("[IceSkatingEffects] Cannot setup panic effects - missing rootPart or humanoid")
		return
	end

	local v4 = createVector(0, 0, 0)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "IceShavingsBurst"
	particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter.Rate = 50
	particleEmitter.Lifetime = NumberRange.new(0.3, 0.6)
	particleEmitter.Speed = NumberRange.new(8, 15)
	particleEmitter.SpreadAngle = Vector2.new(45, 45)
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(230, 240, 255))
	particleEmitter.LightEmission = 0.6
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 0.2)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Enabled = false
	particleEmitter.Parent = rootPart
	v2.panicEmitter = particleEmitter
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not (v2.active and rootPart and rootPart.Parent) then
			return
		end

		local moveDirection = humanoid.MoveDirection
		local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
		local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude

		if moveDirection.Magnitude > 0.1 and v4.Magnitude > 0.1 then
			local v5 = math.acos((math.clamp(moveDirection:Dot(v4), -1, 1)))

			if v5 > 1.0471975511965976 and magnitude > 15 then
				particleEmitter.Enabled = true
				particleEmitter.Rate = 50
				task.delay(0.1, function()
					if particleEmitter then
						particleEmitter.Enabled = false
					end
				end)
				debugPrint("[IceSkatingEffects] Panic burst triggered - Turn angle:", math.deg(v5), "Speed:", magnitude)
			end
		end

		v4 = moveDirection
	end)
	table.insert(v2.connections, heartbeatConnection)
	debugPrint("[IceSkatingEffects] Panic effects enabled (sharp turns >60 degrees + speed >15 studs/s)")
end

function IceSkatingEffects.SetupCrashDetection()
	local rootPart = v2.rootPart
	local camera = v2.camera

	if not (rootPart and camera) then
		warn("[IceSkatingEffects] Cannot setup crash detection - missing rootPart or camera")
		return
	end

	local v4 = 0
	local touchedConnection = rootPart.Touched:Connect(function(part)
		if not (v2.active and rootPart and rootPart.Parent) then
			return
		end

		if not (part:IsA("BasePart") and part.Anchored) then
			return
		end

		local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
		local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude
		local now = tick()

		if magnitude > 25 and now - v4 > 3 then
			local v5 = Audio:Play("rbxasset://sounds/impact.wav", {
				Name = "IceCrashSound",
				Volume = 0.3,
				PlaybackSpeed = 1,
				Parent = rootPart
			})

			if v5 and v then
				v.AssignSound(v5, "Environmental")
			end

			local v6 = math.min(magnitude / 30, 1) * 0.3
			task.spawn(function()
				for _ = 1, 8 do
					if not v2.active then
						break
					end

					camera.CFrame *= CFrame.new(math.random() * v6 * 2 - v6, math.random() * v6 * 2 - v6, 0)
					task.wait(0.0375)
				end
			end)
			v4 = now
			debugPrint("[IceSkatingEffects] Crash detected - Speed:", math.floor(magnitude), "studs/s")
		end
	end)
	table.insert(v2.connections, touchedConnection)
	debugPrint("[IceSkatingEffects] Crash detection enabled (speed >" .. 25 .. " studs/s)")
end

function IceSkatingEffects.SetupArmBalancing(_)
	local character = v2.character
	local rootPart = v2.rootPart
	local humanoid = v2.humanoid

	if not (character and rootPart and humanoid) then
		warn("[IceSkatingEffects] Cannot setup arm sway - missing character/rootPart/humanoid")
		return
	end

	local bones = {}

	for _, bone in pairs(character:GetDescendants()) do
		if bone:IsA("Bone") then
			table.insert(bones, bone)
		end
	end

	local bone = nil
	local bone2 = nil

	for _, v4 in pairs(bones) do
		local name = v4.Name:lower()

		if bone or name ~= "lefthand" and name ~= "left_hand" and name ~= "l_hand" and name ~= "hand.l" then
			if not bone and name:find("left") and name:find("hand") then
				bone = v4
			end
		else
			bone = v4
		end

		if bone2 or name ~= "righthand" and name ~= "right_hand" and name ~= "r_hand" and name ~= "hand.r" then
			if not bone2 and name:find("right") and name:find("hand") then
				bone2 = v4
			end
		else
			bone2 = v4
		end
	end

	if not (bone and bone2) then
		warn("[IceSkatingEffects] Could not find hand bones - arm sway disabled")
		return
	end

	local function getParentOfParentBone(bone3)
		if not (bone3 and bone3:IsA("Bone")) then
			return nil
		end

		local parent = bone3.Parent

		if not (parent and parent:IsA("Bone")) then
			return nil
		end

		local parent2 = parent.Parent

		if parent2 and parent2:IsA("Bone") then
			return parent2
		end

		return nil
	end

	local parent

	if bone and bone:IsA("Bone") then
		local parent2 = bone.Parent

		if parent2 and parent2:IsA("Bone") then
			parent = parent2.Parent

			if not (parent and parent:IsA("Bone")) then
				parent = nil
			end
		end
	end

	local parent2

	if bone2 and bone2:IsA("Bone") then
		local parent3 = bone2.Parent

		if parent3 and parent3:IsA("Bone") then
			parent2 = parent3.Parent

			if not (parent2 and parent2:IsA("Bone")) then
				parent2 = nil
			end
		end
	end

	if not (parent and parent2) then
		warn("[IceSkatingEffects] Could not find chain root bones - arm sway disabled")
		return
	end

	local function createArmIK(parent3, bone3, side)
		local attachment = Instance.new("Attachment")
		attachment.Name = "IceyArmsTarget_" .. side
		attachment.Parent = rootPart
		attachment.Position = Vector3.new(side == "Left" and -3 or 3, 0.5, 0.5)
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "IceyArmsPole_" .. side
		attachment2.Parent = rootPart
		attachment2.Position = Vector3.new(side == "Left" and -1.5 or 1.5, 0.2, -0.5)
		local iKControl = Instance.new("IKControl")
		iKControl.Name = "ArmSwayIK_" .. side
		iKControl.Type = Enum.IKControlType.Position
		iKControl.EndEffector = bone3
		iKControl.Target = attachment
		iKControl.ChainRoot = parent3
		iKControl.Pole = attachment2
		iKControl.Weight = 0
		iKControl.SmoothTime = 0.25
		iKControl.Enabled = true
		iKControl.Parent = humanoid
		local attachment3 = Instance.new("Attachment")
		attachment3.Name = "IceyArmsRotTarget_" .. side
		attachment3.Parent = rootPart
		attachment3.Position = attachment.Position
		attachment3.CFrame = CFrame.new(attachment.Position) * CFrame.Angles(0, 0, 0)
		local iKControl2 = Instance.new("IKControl")
		iKControl2.Name = "ArmSwayRotIK_" .. side
		iKControl2.Type = Enum.IKControlType.Rotation
		iKControl2.EndEffector = bone3
		iKControl2.Target = attachment3
		iKControl2.Weight = 0
		iKControl2.SmoothTime = 0.15
		iKControl2.Enabled = false
		iKControl2.Parent = humanoid
		return {
			ik = iKControl,
			rotIK = iKControl2,
			target = attachment,
			rotTarget = attachment3,
			pole = attachment2,
			side = side
		}
	end

	local armIK = createArmIK(parent, bone, "Left")
	local armIK2 = createArmIK(parent2, bone2, "Right")
	local total = 0
	local total2 = 0
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if not (v2.active and rootPart and rootPart.Parent) then
			return
		end

		local sprintBoostProxy = character:FindFirstChild("SprintBoostProxy")
		local v4 = sprintBoostProxy and sprintBoostProxy.Value > 0.01
		local v5 = 1 - math.exp(-(v4 and 6 or 4) * dt)
		total += ((v4 and 1 or 0) - total) * v5

		if not v4 and total < 0.08 then
			total = 0
		end

		local enabled = total > 0.001
		armIK.ik.Enabled = enabled
		armIK2.ik.Enabled = enabled

		if enabled then
			total2 += dt * 2
			local v7 = math.sin(total2 * 3.141592653589793)
			local v8 = v7 * 1.8
			local v9 = -v7 * 1.2
			armIK.target.Position = Vector3.new(-3, v8 + 0.5, 0.5)
			armIK2.target.Position = Vector3.new(3, v9 + 0.5, 0.5)
			armIK.pole.Position = Vector3.new(-1.7999999999999998, v8 * 0.5 + 0.5, -0.5)
			armIK2.pole.Position = Vector3.new(1.7999999999999998, v9 * 0.5 + 0.5, -0.5)
			armIK.ik.Weight = total
			armIK2.ik.Weight = total
			local enabled2 = total >= 0.95
			armIK.rotIK.Enabled = enabled2
			armIK2.rotIK.Enabled = enabled2

			if enabled2 then
				armIK.rotIK.Weight = 1
				armIK2.rotIK.Weight = 1
			end
		else
			armIK.rotIK.Enabled = false
			armIK2.rotIK.Enabled = false
			total2 = 0
		end
	end)
	table.insert(v2.connections, heartbeatConnection)
	v2.armBalanceState = {
		leftIK = armIK,
		rightIK = armIK2
	}
	debugPrint("[IceSkatingEffects] Arm Sway enabled (tied to sprint boost)")
end

function IceSkatingEffects.SetupSounds()
	local rootPart = v2.rootPart

	if not rootPart then
		warn("[IceSkatingEffects] SetupSounds: No root part found")
		return
	end

	local v4 = Audio:Play("Sounds.ZoneEvents.Skating.Loop", {
		Name = "IceSlideLoop",
		Looped = true,
		Volume = 0,
		PlaybackSpeed = 1,
		Parent = rootPart
	})

	if not v4 then
		warn("[IceSkatingEffects] SetupSounds: Failed to create ice slide loop")
		return
	end

	if v then
		v.AssignSound(v4, "Environmental")
	end

	v2.sounds.slideLoop = v4
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		if v2.active and rootPart and rootPart.Parent then
			local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
			local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude
			local moveDirection = v2.humanoid and v2.humanoid.MoveDirection or createVector(0, 0, 0)
			local v5 = not (assemblyLinearVelocity.Magnitude > 0.1 and moveDirection.Magnitude > 0.1) and 0 or math.acos((math.clamp(
				Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Unit:Dot(moveDirection),
				-1,
				1
			)))
			local v6 = math.clamp(magnitude / 30, 0, 1)
			local v7 = v6 * 0.3
			local v8 = v6 * 0.25 + 0.9 + v5 * 0.05
			v4.Volume += (v7 - v4.Volume) * 0.15
			v4.PlaybackSpeed += (v8 - v4.PlaybackSpeed) * 0.1

			if not v4:FindFirstChild("TurnEqualizer") then
				local equalizerSoundEffect = Instance.new("EqualizerSoundEffect")
				equalizerSoundEffect.Name = "TurnEqualizer"
				equalizerSoundEffect.HighGain = 0
				equalizerSoundEffect.MidGain = 0
				equalizerSoundEffect.LowGain = -5
				equalizerSoundEffect.Parent = v4
			end

			v4.TurnEqualizer.HighGain = math.clamp(v5 * 10, 0, 8)

			if v7 > 0.05 and not v4.Playing then
				v4:Play()
			elseif v7 < 0.05 and v4.Playing then
				v4:Stop()
			end
		elseif v4 and v4.Parent then
			v4:Stop()
		end
	end)
	table.insert(v2.connections, heartbeatConnection)
	debugPrint("[IceSkatingEffects] Sound effects enabled - IceSkate_Smooth_Loop with speed-based volume/pitch")
end

function IceSkatingEffects.Activate(preset, config2)
	debugPrint("[IceSkatingEffects] ========== ACTIVATION STARTED ==========")
	debugPrint("[IceSkatingEffects] Preset requested:", preset)

	if v2.character and v2.character.Parent then
		if v2.humanoid and v2.rootPart then
			if v2.active then
				debugPrint("[IceSkatingEffects] Deactivating previous effects (preserving physics for reactivation)...")
				IceSkatingEffects.Deactivate(true)
			end

			if not config2 then
				local IceSkatingConfig = require(game.ReplicatedStorage.Modules.Zones.IceSkatingConfig)
				config2 = IceSkatingConfig.Presets[preset]
			end

			local activeConfig = config2

			if not activeConfig then
				warn("[IceSkatingEffects] Preset not found:", preset)
				return
			end

			debugPrint("[IceSkatingEffects] Activating:", activeConfig.name, "- Preset:", preset)
			v2.active = true
			v2.preset = preset
			v2.activeConfig = activeConfig
			local _ = v2.character

			if activeConfig.disableSprint ~= false then
				debugPrint("[IceSkatingEffects] Sprint disabled via server-set IceSkatingMode attribute")
			end

			debugPrint("[IceSkatingEffects] Creating trails...")
			local success, result = pcall(function()
				v2.trails = IceSkatingEffects.CreateTrails()
			end)

			if success then
				debugPrint("[IceSkatingEffects] Created", #v2.trails, "trail sets")
			else
				warn("[IceSkatingEffects] Trail creation failed:", result)
				v2.trails = {}
			end

			for _, trail in ipairs(v2.trails) do
				if trail.leftTrail then
					trail.leftTrail.Enabled = true
				end

				if trail.rightTrail then
					trail.rightTrail.Enabled = true
					debugPrint("[IceSkatingEffects] Enabled dual skate blade trails")
				end

				if trail.sparkles then
					trail.sparkles.Enabled = activeConfig.useTrails or false
				end

				if trail.screenSnow then
					trail.screenSnow.Enabled = activeConfig.useScreenSnow ~= false
				end

				if not (trail.speedLines and (activeConfig.useMomentum or activeConfig.useVectorForce or activeConfig.useFOV)) then
					continue
				end

				local speedLines = trail.speedLines
				local heartbeatConnection = RunService.Heartbeat:Connect(function()
					if not (v2.active and v2.rootPart) then
						speedLines.Enabled = false
						return
					end

					local assemblyLinearVelocity = v2.rootPart.AssemblyLinearVelocity
					local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude

					if magnitude > 20 then
						speedLines.Enabled = true
						speedLines.Rate = math.min(100, (magnitude - 20) * 3)
					else
						speedLines.Enabled = false
					end
				end)
				table.insert(v2.connections, heartbeatConnection)
				debugPrint("[IceSkatingEffects] Speed lines system enabled")
			end

			if activeConfig.useBodyVelocity then
				if activeConfig.useMomentum or activeConfig.useVectorForce then
					warn("[IceSkatingEffects] BodyVelocity cannot be used with Momentum or VectorForce - disabling others")
					activeConfig.useMomentum = false
					activeConfig.useVectorForce = false
				end

				debugPrint("[IceSkatingEffects] Setting up BodyVelocity system...")
				local success2, result2 = pcall(function()
					v2.bodyVelocityState = IceSkatingEffects_VectorForce.SetupBodyVelocity(v2, activeConfig)
				end)

				if success2 then
					debugPrint("[IceSkatingEffects] BodyVelocity system activated")
				else
					warn("[IceSkatingEffects] BodyVelocity setup failed:", result2)
					v2.bodyVelocityState = nil
				end
			elseif activeConfig.useVectorForce then
				if activeConfig.useMomentum then
					warn("[IceSkatingEffects] Cannot use both VectorForce and Momentum - disabling Momentum")
					activeConfig.useMomentum = false
				end

				debugPrint("[IceSkatingEffects] Setting up VectorForce system...")
				local success2, result2 = pcall(function()
					v2.vectorForceState = IceSkatingEffects_VectorForce.SetupVectorForce(v2, activeConfig)
				end)

				if success2 then
					debugPrint("[IceSkatingEffects] VectorForce system activated")
				else
					warn("[IceSkatingEffects] VectorForce setup failed:", result2)
					v2.vectorForceState = nil
				end
			elseif activeConfig.useMomentum then
				debugPrint("[IceSkatingEffects] Setting up Momentum system...")
				local success2, result2 = pcall(function()
					IceSkatingEffects.SetupMomentum(activeConfig)
				end)

				if not success2 then
					warn("[IceSkatingEffects] Momentum setup failed:", result2)
				end
			else
				debugPrint("[IceSkatingEffects] Applying basic ice physics (no momentum)...")
				local rootPart = v2.rootPart
				local humanoid = v2.humanoid
				local density = activeConfig.density or 0.05
				local friction = activeConfig.friction or 0
				debugPrint("[IceSkatingEffects] Applying physics: density=" .. density .. ", friction=" .. friction)
				rootPart.CustomPhysicalProperties = PhysicalProperties.new(
					density,
					friction,
					activeConfig.elasticity or 0,
					activeConfig.frictionWeight or 100,
					activeConfig.elasticityWeight or 1
				)
				humanoid.MaxSlopeAngle = 89

				if v2.modifiersApplied then
					debugPrint("[IceSkatingEffects] SpeedModifiers already applied, skipping")
				else
					local stats = v2.character:FindFirstChild("Stats")

					if stats then
						local speedModifier = stats:FindFirstChild("SpeedModifier")
						local walkSpeedMultiplier = activeConfig.walkSpeedMultiplier or 1.3
						local baselineSpeedMod = speedModifier and speedModifier.Value or 1
						v2.baselineSpeedMod = baselineSpeedMod
						debugPrint("[IceSkatingEffects] BASELINE SpeedModifier:", baselineSpeedMod)
						v2.modifiersApplied = true
						v2.appliedMultiplier = walkSpeedMultiplier
						debugPrint(
							"[IceSkatingEffects] Speed mods handled server-side, tracking multiplier:",
							walkSpeedMultiplier
						)
					end
				end

				if activeConfig.useNaturalSlide then
					local slideDecay = activeConfig.slideDecay or 0.98
					local velocityThreshold = activeConfig.velocityThreshold or 0.5
					local slideBoost = activeConfig.slideBoost or 1
					local baseSkatingSpeed = activeConfig.baseSkatingSpeed or 24
					local baseWalkSpeed = 16
					local stats = v2.character:FindFirstChild("Stats")

					if stats then
						local runSpeed = stats:FindFirstChild("RunSpeed")
						local walkSpeed = stats:FindFirstChild("WalkSpeed")

						if runSpeed then
							baseSkatingSpeed = runSpeed.Value
							debugPrint("[IceSkatingEffects] Using character RunSpeed as base:", baseSkatingSpeed)
						end

						if walkSpeed then
							baseWalkSpeed = walkSpeed.Value
							debugPrint("[IceSkatingEffects] Using character WalkSpeed:", baseWalkSpeed)
						end
					end

					v2.slideDecay = slideDecay
					v2.velocityThreshold = velocityThreshold
					v2.slideBoost = slideBoost
					v2.baseSkatingSpeed = baseSkatingSpeed
					v2.baseWalkSpeed = baseWalkSpeed
					local v5 = 1
					local accelerationRate = activeConfig.accelerationRate or 0.5
					local decelerationRate = activeConfig.decelerationRate or 0.8
					local maxSpeedMultiplier = activeConfig.maxSpeedMultiplier or 2
					local _ = activeConfig.useMomentumTurnResistance or false

					if not v2.baseWalkSpeedAtStart then
						local stats2 = v2.character:FindFirstChild("Stats")
						local walkSpeed = stats2 and stats2:FindFirstChild("WalkSpeed")

						if walkSpeed then
							v2.baseWalkSpeedAtStart = walkSpeed.Value
						end

						v2.baseWalkSpeedAtStart = v2.baseWalkSpeedAtStart or 16
					end

					local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						if not (v2.active and rootPart and rootPart.Parent) then
							return
						end

						if ShouldPausePhysics() then
							v5 = 1
							local character = v2.character
							local decoding = character and character:FindFirstChild("Decoding")
							local v6 = decoding and decoding.Value ~= nil
							local grabbed = character and character:FindFirstChild("Grabbed")
							local transforming = character and character:GetAttribute("Transforming")
							local holdAbilityActive = character and character:GetAttribute("HoldAbilityActive")

							if v6 or grabbed or transforming or holdAbilityActive then
								local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
								rootPart.AssemblyLinearVelocity = Vector3.new(0, assemblyLinearVelocity.Y, 0)
							end
						else
							local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
							local vector2 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)
							local slideDecay2 = v2.slideDecay or slideDecay
							local velocityThreshold2 = v2.velocityThreshold or velocityThreshold
							local _ = v2.slideBoost

							if humanoid.MoveDirection.Magnitude > 0.1 then
								if vector2.Magnitude > 3 then
									local moveDirection = humanoid.MoveDirection
									local v6 = math.deg((math.acos((math.clamp(moveDirection:Dot(vector2.Unit), -1, 1)))))

									if v6 >= 45 then
										local v7 = (v6 - 45) / 135 * 0.015 + 0.005
										local lerped = vector2:Lerp(moveDirection * vector2.Magnitude, v7)
										rootPart.AssemblyLinearVelocity = Vector3.new(
											lerped.X,
											assemblyLinearVelocity.Y,
											lerped.Z
										)
									end
								end

								v5 = math.min(maxSpeedMultiplier, v5 + accelerationRate * dt)
							else
								v5 = math.max(1, v5 - decelerationRate * dt)

								if velocityThreshold2 < vector2.Magnitude then
									local v6 = vector2 * slideDecay2
									rootPart.AssemblyLinearVelocity = Vector3.new(v6.X, assemblyLinearVelocity.Y, v6.Z)
								end
							end

							local state = humanoid:GetState()
							local magnitude = vector2.Magnitude
							local v6 = state == Enum.HumanoidStateType.Freefall
							local v7

							if assemblyLinearVelocity.Y > 0.5 then
								v7 = magnitude > 5
							else
								v7 = false
							end

							if v6 or v7 then
								local v8 = assemblyLinearVelocity.Y + -15 * dt

								if assemblyLinearVelocity.Y > 0 then
									v8 = math.max(assemblyLinearVelocity.Y * 0.6, v8)
								end

								rootPart.AssemblyLinearVelocity = Vector3.new(
									assemblyLinearVelocity.X,
									math.max(v8, -50),
									assemblyLinearVelocity.Z
								)
							elseif assemblyLinearVelocity.Y > 2 then
								rootPart.AssemblyLinearVelocity = Vector3.new(
									assemblyLinearVelocity.X,
									math.min(assemblyLinearVelocity.Y, 3),
									assemblyLinearVelocity.Z
								)
							end
						end
					end)
					table.insert(v2.connections, heartbeatConnection)
					debugPrint("[IceSkatingEffects] Natural sliding: decay=" .. slideDecay .. ", threshold=" .. velocityThreshold .. ", baseSpeed=" .. baseSkatingSpeed .. ", boost=" .. slideBoost)
				else
					debugPrint("[IceSkatingEffects] Natural slide disabled (stops on key release)")
				end
			end

			if activeConfig.useSprintBoost then
				debugPrint("[IceSkatingEffects] Setting up Sprint Boost System...")
				v2.baseSpeedOriginal = v2.baseSkatingSpeed or activeConfig.baseSkatingSpeed or 20
				v2.slideBoostOriginal = v2.slideBoost or activeConfig.slideBoost or 2
				v2.slideDecayOriginal = v2.slideDecay or activeConfig.slideDecay or 0.999
				local sprintSpeedBoost = activeConfig.sprintSpeedBoost or 8
				local sprintSlideBoostIncrease = activeConfig.sprintSlideBoostIncrease or 0.5
				local sprintDecayBoost = activeConfig.sprintDecayBoost or 0.0005
				local sprintBoostTweenInTime = activeConfig.sprintBoostTweenInTime or 0.2
				local sprintBoostTweenOutTime = activeConfig.sprintBoostTweenOutTime or 0.8
				local tweenInfo = TweenInfo.new(sprintBoostTweenInTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tweenInfo2 = TweenInfo.new(
					sprintBoostTweenOutTime,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				)
				local numberValue = Instance.new("NumberValue")
				numberValue.Name = "SprintBoostProxy"
				numberValue.Value = 0
				numberValue.Parent = v2.character
				local baseWalkSpeed = v2.baseWalkSpeed or 26
				local walkSpeedMultiplier = activeConfig.walkSpeedMultiplier or 1.15
				local targetWalkSpeed = baseWalkSpeed * walkSpeedMultiplier
				v2.targetWalkSpeed = targetWalkSpeed
				debugPrint("[IceSkatingEffects] Sprint boost using target speed: " .. baseWalkSpeed .. " * " .. walkSpeedMultiplier .. " = " .. math.floor(targetWalkSpeed + 0.5))
				local useSprintBlur = activeConfig.useSprintBlur == true
				local useSprintTilt = activeConfig.useSprintTilt == true
				local useSprintFOV = activeConfig.useSprintFOV == true
				local sprintBlurSize = activeConfig.sprintBlurSize or 4
				local sprintTiltDegrees = activeConfig.sprintTiltDegrees or 5
				local sprintFOVBoost = activeConfig.sprintFOVBoost or 8
				local blurEffect

				if useSprintBlur and v2.camera then
					blurEffect = Instance.new("BlurEffect")
					blurEffect.Name = "SprintSpeedBlur"
					blurEffect.Size = 0
					blurEffect.Parent = v2.camera
					v2.sprintBlur = blurEffect
					debugPrint("[IceSkatingEffects] Sprint blur effect created (max size: " .. sprintBlurSize .. ") - activates with treadmill mode")
				else
					blurEffect = nil
				end

				local fieldOfView

				if useSprintFOV and v2.camera then
					fieldOfView = v2.camera.FieldOfView
					v2.sprintBaseFOV = fieldOfView
					debugPrint("[IceSkatingEffects] Sprint FOV effect enabled (base: " .. fieldOfView .. ", boost: +" .. sprintFOVBoost .. ")")
				else
					fieldOfView = nil
				end

				v2.currentSprintTilt = 0
				v2.targetSprintTilt = 0

				if useSprintTilt then
					local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
						if not v2.active then
							return
						end

						local animationSpeedUpEnabled = v2.animationSpeedUpEnabled == true
						local sprintBoostActive = v2.sprintBoostActive == true

						if animationSpeedUpEnabled and sprintBoostActive then
							local rootPart = v2.rootPart
							local humanoid = v2.humanoid

							if rootPart and humanoid then
								local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
								local vector2 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)
								local moveDirection = humanoid.MoveDirection

								if vector2.Magnitude > 3 and moveDirection.Magnitude > 0.1 then
									v2.targetSprintTilt = -vector2.Unit:Cross(moveDirection).Y * sprintTiltDegrees
								else
									v2.targetSprintTilt = 0
								end
							end
						else
							v2.currentSprintTilt *= 0.9

							if math.abs(v2.currentSprintTilt) < 0.01 then
								v2.currentSprintTilt = 0
							end

							v2.targetSprintTilt = 0
						end

						v2.currentSprintTilt += (v2.targetSprintTilt - v2.currentSprintTilt) * dt * 6

						if v2.camera and math.abs(v2.currentSprintTilt) > 0.001 then
							local currentSprintTilt = math.rad(v2.currentSprintTilt)
							v2.camera.CFrame = v2.camera.CFrame * CFrame.Angles(0, 0, currentSprintTilt)
						end
					end)
					table.insert(v2.connections, renderSteppedConnection)
					debugPrint("[IceSkatingEffects] Sprint tilt effect enabled (max degrees: " .. sprintTiltDegrees .. ") - turn-reactive")
				end

				local changedConnection = numberValue.Changed:Connect(function(p2)
					if not v2.active then
						return
					end

					v2.baseSkatingSpeed = v2.baseSpeedOriginal + sprintSpeedBoost * p2
					v2.slideBoost = v2.slideBoostOriginal + sprintSlideBoostIncrease * p2
					v2.slideDecay = math.min(0.9999, v2.slideDecayOriginal + sprintDecayBoost * p2)
					local animationSpeedUpEnabled = v2.animationSpeedUpEnabled == true

					if blurEffect then
						if animationSpeedUpEnabled then
							blurEffect.Size = sprintBlurSize * p2
						else
							blurEffect.Size = 0
						end
					end

					if useSprintTilt then
						if animationSpeedUpEnabled then
							v2.targetSprintTilt = sprintTiltDegrees * p2
						else
							v2.targetSprintTilt = 0
						end
					end

					if useSprintFOV and fieldOfView and v2.camera then
						v2.camera.FieldOfView = fieldOfView + sprintFOVBoost * p2
					end
				end)
				table.insert(v2.connections, changedConnection)
				local sprintMinHoldTime = activeConfig.sprintMinHoldTime or 0.15
				local lastTime = nil
				local flag = false

				local function onSprintStart()
					if not v2.active or v2.sprintBoostActive or flag then
						return
					end

					lastTime = tick()
					flag = true
				end

				local function activateSprintBoost()
					if v2.sprintBoostActive then
						return
					end

					v2.sprintBoostActive = true
					flag = false

					if v2.sprintBoostTween then
						v2.sprintBoostTween:Cancel()
					end

					v2.sprintBoostTween = TweenService:Create(numberValue, tweenInfo, {
						Value = 1
					})
					v2.sprintBoostTween:Play()
					local sprintVelocityImpulse = activeConfig.sprintVelocityImpulse or 0

					if sprintVelocityImpulse > 0 and v2.rootPart and v2.humanoid then
						local moveDirection = v2.humanoid.MoveDirection

						if moveDirection.Magnitude > 0.1 then
							local unit = moveDirection.Unit
							local assemblyLinearVelocity = v2.rootPart.AssemblyLinearVelocity
							v2.rootPart.AssemblyLinearVelocity = Vector3.new(
								assemblyLinearVelocity.X + unit.X * sprintVelocityImpulse,
								assemblyLinearVelocity.Y,
								assemblyLinearVelocity.Z + unit.Z * sprintVelocityImpulse
							)
						end
					end

					debugPrint("[IceSkatingEffects] Sprint boost activated (client visuals) - server handles WalkSpeed ramp")
				end

				local function onSprintEnd()
					if not v2.active then
						return
					end

					if flag then
						flag = false
						lastTime = nil
					else
						if not v2.sprintBoostActive then
							return
						end

						v2.sprintBoostActive = false
						v2.sprintBoostDecaying = true

						if v2.sprintBoostTween then
							v2.sprintBoostTween:Cancel()
						end

						v2.sprintBoostTween = TweenService:Create(numberValue, tweenInfo2, {
							Value = 0
						})
						v2.sprintBoostTween:Play()
						v2.sprintBoostTween.Completed:Connect(function()
							v2.sprintBoostDecaying = false
						end)
						debugPrint("[IceSkatingEffects] Sprint boost decaying (client visuals) - server handles WalkSpeed ramp")
					end
				end

				local heartbeatConnection = RunService.Heartbeat:Connect(function()
					if flag and lastTime and sprintMinHoldTime <= tick() - lastTime then
						activateSprintBoost()
						lastTime = nil
					end
				end)
				table.insert(v2.connections, heartbeatConnection)
				local v6 = InputService:OnAction("Sprint", onSprintStart)
				table.insert(v2.connections, v6)
				local v7 = InputService:OnActionReleased("Sprint", onSprintEnd)
				table.insert(v2.connections, v7)
				local stats = v2.character:FindFirstChild("Stats")
				local holdingSprint = stats and stats:FindFirstChild("HoldingSprint")

				if holdingSprint then
					local valueChangedConnection = holdingSprint:GetPropertyChangedSignal("Value"):Connect(function()
						if holdingSprint.Value == true then
							onSprintStart()
						else
							onSprintEnd()
						end
					end)
					table.insert(v2.connections, valueChangedConnection)
					debugPrint("[IceSkatingEffects] HoldingSprint listener connected (mobile/controller support)")
				end

				local attributeChangedConnection = v2.character.AttributeChanged:Connect(function(p2)
					if p2 == "IceSkatingStaminaDepleted" then
						if v2.character:GetAttribute("IceSkatingStaminaDepleted") then
							if v2.sprintBoostActive or flag then
								debugPrint("[IceSkatingEffects] Stamina depleted - deactivating sprint boost")
								flag = false
								lastTime = nil
								v2.sprintBoostActive = false

								if v2.sprintBoostTween then
									v2.sprintBoostTween:Cancel()
								end

								v2.sprintBoostTween = TweenService:Create(numberValue, tweenInfo2, {
									Value = 0
								})
								v2.sprintBoostTween:Play()
							end
						else
							local v8 = InputService:GetActionState("Sprint") == true
							local v9 = holdingSprint and holdingSprint.Value == true

							if v8 or v9 then
								debugPrint("[IceSkatingEffects] Stamina recovered - reactivating sprint boost")
								onSprintStart()
							end
						end
					end
				end)
				table.insert(v2.connections, attributeChangedConnection)
				local v8 = onSprintStart

				onSprintStart = function()
					if v2.character:GetAttribute("IceSkatingStaminaDepleted") then
						return
					end

					v8()
				end

				local v9 = InputService:GetActionState("Sprint") == true
				local v10 = holdingSprint and holdingSprint.Value == true

				if v9 or v10 then
					onSprintStart()
				end

				local decoding = v2.character:FindFirstChild("Decoding")

				if decoding then
					local changedConnection2 = decoding.Changed:Connect(function(p2)
						if p2 ~= nil then
							debugPrint("[IceSkatingEffects] Generator interaction detected - force stopping sprint")
							IceSkatingEffects.ForceStopSprint()
						end
					end)
					table.insert(v2.connections, changedConnection2)
				end

				local abilityBoostSpeed = activeConfig.abilityBoostSpeed or 55
				local attributeChangedConnection2 = v2.character.AttributeChanged:Connect(function(p2)
					if p2 == "AbilityAnimationActive" and v2.character:GetAttribute("AbilityAnimationActive") then
						local character = v2.character
						local config = character and character:FindFirstChild("Config")
						local moduleName = config and config:FindFirstChild("ModuleName")
						local v11

						if moduleName == nil then
							v11 = false
						else
							v11 = v3[moduleName.Value] == true
						end

						if v11 then
							IceSkatingEffects.ForceStopSprint()

							if v2.active and v2.rootPart then
								local lookVector = v2.rootPart.CFrame.LookVector
								local assemblyLinearVelocity = v2.rootPart.AssemblyLinearVelocity
								v2.rootPart.AssemblyLinearVelocity = Vector3.new(
									lookVector.X * abilityBoostSpeed,
									assemblyLinearVelocity.Y,
									lookVector.Z * abilityBoostSpeed
								)
								debugPrint(
									"[IceSkatingEffects] Ability boost applied - velocity impulse:",
									abilityBoostSpeed
								)
							end
						end
					end
				end)
				table.insert(v2.connections, attributeChangedConnection2)
				local attributeChangedConnection3 = v2.character.AttributeChanged:Connect(function(p2)
					if p2 == "HoldAbilityActive" and v2.character:GetAttribute("HoldAbilityActive") then
						debugPrint("[IceSkatingEffects] Hold ability started - force stopping sprint")
						IceSkatingEffects.ForceStopSprint()
					end
				end)
				table.insert(v2.connections, attributeChangedConnection3)
				local boxAbilityActive = v2.character:FindFirstChild("BoxAbilityActive")

				if boxAbilityActive then
					local changedConnection2 = boxAbilityActive.Changed:Connect(function()
						debugPrint("[IceSkatingEffects] Box ability active - force stopping sprint")
						IceSkatingEffects.ForceStopSprint()
					end)
					table.insert(v2.connections, changedConnection2)
				end

				local childAddedConnection = v2.character.ChildAdded:Connect(function(boolValue)
					if boolValue.Name == "BoxAbilityActive" then
						debugPrint("[IceSkatingEffects] Box ability activated - force stopping sprint")
						IceSkatingEffects.ForceStopSprint()
					elseif boolValue.Name == "Grabbed" then
						debugPrint("[IceSkatingEffects] Player grabbed (Goob Hug) - force stopping sprint")
						IceSkatingEffects.ForceStopSprint()
					elseif boolValue.Name == "Invincible" then
						debugPrint("[IceSkatingEffects] Player invincible state - force stopping sprint")
						IceSkatingEffects.ForceStopSprint()
					elseif boolValue.Name == "Grabbing" and boolValue:IsA("BoolValue") then
						local changedConnection2 = boolValue.Changed:Connect(function(p2)
							if p2 == true then
								debugPrint("[IceSkatingEffects] Player grabbing another - force stopping sprint")
								IceSkatingEffects.ForceStopSprint()
							end
						end)
						table.insert(v2.connections, changedConnection2)
					end
				end)
				table.insert(v2.connections, childAddedConnection)
				local grabbing = v2.character:FindFirstChild("Grabbing")

				if grabbing and grabbing:IsA("BoolValue") then
					local changedConnection2 = grabbing.Changed:Connect(function(p2)
						if p2 == true then
							debugPrint("[IceSkatingEffects] Player grabbing another - force stopping sprint")
							IceSkatingEffects.ForceStopSprint()
						end
					end)
					table.insert(v2.connections, changedConnection2)
				end

				if v2.humanoid then
					local diedConnection = v2.humanoid.Died:Connect(function()
						debugPrint("[IceSkatingEffects] Character died - force stopping sprint")
						IceSkatingEffects.ForceStopSprint()
					end)
					table.insert(v2.connections, diedConnection)
				end

				debugPrint("[IceSkatingEffects] Sprint Boost System ready - hold Shift to boost (WalkSpeed +" .. sprintSpeedBoost .. ", baseSpeed +" .. sprintSpeedBoost .. ", slideBoost +" .. sprintSlideBoostIncrease .. ", stamina-managed)")
				debugPrint("[IceSkatingEffects] Hard cancel listeners active (generator, ability, hold, box, grab, death)")
			end

			if activeConfig.useFOV or activeConfig.useBlur then
				debugPrint(
					"[IceSkatingEffects] Setting up camera effects (FOV:",
					activeConfig.useFOV and "ON" or "OFF",
					"Blur:",
					activeConfig.useBlur and "ON" or "OFF",
					")..."
				)
				local success2, result2 = pcall(function()
					IceSkatingEffects.SetupFOV(activeConfig)
				end)

				if not success2 then
					warn("[IceSkatingEffects] Camera effects setup failed:", result2)
				end
			end

			if activeConfig.useTilt then
				debugPrint("[IceSkatingEffects] Setting up Tilt...")
				local success2, result2 = pcall(function()
					IceSkatingEffects.SetupTilt(activeConfig)
				end)

				if not success2 then
					warn("[IceSkatingEffects] Tilt setup failed:", result2)
				end
			end

			v2.animationSpeedUpEnabled = activeConfig.useAnimationSpeedUp
			debugPrint(
				"[IceSkatingEffects] Animation Speed-Up enabled from config:",
				activeConfig.useAnimationSpeedUp and "YES" or "NO"
			)

			if activeConfig.useAnimationSpeedUp then
				debugPrint("[IceSkatingEffects] Setting up Animation Speed-Up...")
				local success2, result2 = pcall(function()
					IceSkatingEffects.SetupAnimationSpeedUp(activeConfig)
				end)

				if not success2 then
					warn("[IceSkatingEffects] Animation speed-up setup failed:", result2)
				end
			else
				local character = v2.character

				if character then
					character:SetAttribute("DisableSprintAnimations", false)
					debugPrint("[IceSkatingEffects] Normal walk/run animations enabled (treadmill disabled)")
				end
			end

			if activeConfig.useSounds then
				IceSkatingEffects.SetupSounds()
			end

			if activeConfig.usePanicEffects then
				debugPrint("[IceSkatingEffects] Setting up Panic effects...")
				local success2, result2 = pcall(function()
					IceSkatingEffects.SetupPanicEffects(activeConfig)
				end)

				if not success2 then
					warn("[IceSkatingEffects] Panic effects setup failed:", result2)
				end
			end

			if activeConfig.useCrashDetection then
				debugPrint("[IceSkatingEffects] Setting up Crash detection...")
				local success2, result2 = pcall(function()
					IceSkatingEffects.SetupCrashDetection()
				end)

				if not success2 then
					warn("[IceSkatingEffects] Crash detection setup failed:", result2)
				end
			end

			if v2.armBalancingEnabled ~= nil and v2.armBalancingEnabled or activeConfig.useArmBalancing then
				debugPrint(
					"[IceSkatingEffects] Setting up Arm balancing (manual:",
					v2.armBalancingEnabled,
					"config:",
					activeConfig.useArmBalancing,
					")..."
				)
				local success2, result2 = pcall(function()
					IceSkatingEffects.SetupArmBalancing(activeConfig)
				end)

				if not success2 then
					warn("[IceSkatingEffects] Arm balancing setup failed:", result2)
				end

				v2.armBalancingEnabled = true
			else
				v2.armBalancingEnabled = false
			end

			if activeConfig.useCircleSkating then
				debugPrint("[IceSkatingEffects] Setting up Circle skating...")
				local success2, result2 = pcall(function()
					IceSkatingEffects.SetupCircleSkating(activeConfig)
				end)

				if not success2 then
					warn("[IceSkatingEffects] Circle skating setup failed:", result2)
				end
			end

			if activeConfig.useGradualSpeedRamp and not v2.baseWalkSpeed then
				debugPrint("[IceSkatingEffects] Setting up Gradual Speed Ramp...")
				local success2, result2 = pcall(function()
					v2.speedTween = IceSkatingEffects_VectorForce.SetupGradualSpeedRamp(v2, activeConfig)
				end)

				if success2 then
					debugPrint("[IceSkatingEffects] Gradual speed ramp activated")
				else
					warn("[IceSkatingEffects] Speed ramp setup failed:", result2)
					v2.speedTween = nil
				end
			elseif v2.baseWalkSpeed then
				debugPrint("[IceSkatingEffects] Skipping speed ramp - already at target speed")
			end

			for _, trail in ipairs(v2.trails) do
				if not trail.bloom then
					continue
				end

				trail.bloom.Enabled = activeConfig.useBloom or false

				if activeConfig.useBloom then
					debugPrint("[IceSkatingEffects] Bloom effect enabled (sparkly ice glow)")
				end
			end

			for _, trail in ipairs(v2.trails) do
				if not trail.sunRays then
					continue
				end

				trail.sunRays.Enabled = activeConfig.useSunRays or false

				if activeConfig.useSunRays then
					debugPrint("[IceSkatingEffects] SunRays effect enabled (dramatic winter lighting)")
				end
			end

			if activeConfig.useDepthOfField then
				for _, trail in ipairs(v2.trails) do
					if not trail.depthOfField then
						continue
					end

					trail.depthOfField.Enabled = true
					local depthOfField = trail.depthOfField
					local heartbeatConnection = RunService.Heartbeat:Connect(function()
						if not (v2.active and v2.rootPart) then
							depthOfField.FarIntensity = 0
							return
						end

						local assemblyLinearVelocity = v2.rootPart.AssemblyLinearVelocity
						local v6 = math.clamp(
							Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude / 30,
							0,
							1
						) * 0.5
						depthOfField.FarIntensity += (v6 - depthOfField.FarIntensity) * 0.1
					end)
					table.insert(v2.connections, heartbeatConnection)
					debugPrint("[IceSkatingEffects] DepthOfField effect enabled (speed-based background blur)")
				end
			end

			local IceSkatingConfig = require(game.ReplicatedStorage.Modules.Zones.IceSkatingConfig)
			local twisted = IceSkatingConfig.GetTwisted(preset)

			if twisted.enabled ~= false and (twisted.particles or twisted.tilt) then
				IceSkatingEffects.StartWatchingTwisteds(twisted)
			end

			debugPrint("[IceSkatingEffects] ========== ACTIVATION COMPLETE ==========")
		else
			debugPrint("[IceSkatingEffects] Humanoid or RootPart not ready - queueing activation for after Init()")
			v2.pendingActivation = {
				presetName = preset,
				config = config2
			}
		end
	else
		debugPrint("[IceSkatingEffects] Character not ready yet - queueing activation for after Init()")
		v2.pendingActivation = {
			presetName = preset,
			config = config2
		}
	end
end

function IceSkatingEffects.IsActive()
	return v2.active == true
end

function IceSkatingEffects.SetSlideDecay(value)
	v2.slideDecay = math.clamp(value, 0.9, 0.999)
	debugPrint("[IceSkatingEffects] Slide decay set to:", v2.slideDecay)
end

function IceSkatingEffects.GetSlideDecay()
	return v2.slideDecay or 0.98
end

function IceSkatingEffects.SetVelocityThreshold(value)
	v2.velocityThreshold = math.clamp(value, 0.1, 5)
	debugPrint("[IceSkatingEffects] Velocity threshold set to:", v2.velocityThreshold)
end

function IceSkatingEffects.GetVelocityThreshold()
	return v2.velocityThreshold or 0.5
end

function IceSkatingEffects.SetSlideBoost(value)
	v2.slideBoost = math.clamp(value, 0.5, 2)
	debugPrint("[IceSkatingEffects] Slide boost set to:", v2.slideBoost)
end

function IceSkatingEffects.GetSlideBoost()
	return v2.slideBoost or 1
end

function IceSkatingEffects.SetBaseSkatingSpeed(value)
	v2.baseSkatingSpeed = math.clamp(value, 10, 50)
	debugPrint("[IceSkatingEffects] Base skating speed set to:", v2.baseSkatingSpeed)
end

function IceSkatingEffects.GetBaseSkatingSpeed()
	return v2.baseSkatingSpeed or 24
end

function IceSkatingEffects.SetTurnSmoothing(value)
	v2.turnSmoothing = math.clamp(value, 0.01, 0.5)
	debugPrint("[IceSkatingEffects] Turn smoothing set to:", v2.turnSmoothing)
end

function IceSkatingEffects.GetTurnSmoothing()
	return v2.turnSmoothing or 0.08
end

function IceSkatingEffects.SetDensity(value)
	v2.density = math.clamp(value, 0.05, 1.5)

	if v2.active and v2.character then
		local humanoidRootPart = v2.character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart.CustomPhysicalProperties then
			local customPhysicalProperties = humanoidRootPart.CustomPhysicalProperties
			humanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(
				v2.density,
				v2.friction or customPhysicalProperties.Friction,
				customPhysicalProperties.Elasticity,
				customPhysicalProperties.FrictionWeight,
				customPhysicalProperties.ElasticityWeight
			)
		end
	end

	debugPrint("[IceSkatingEffects] Density set to:", v2.density)
end

function IceSkatingEffects.GetDensity()
	return v2.density or 0.4
end

function IceSkatingEffects.SetFriction(value)
	v2.friction = math.clamp(value, 0, 0.3)

	if v2.active and v2.character then
		local humanoidRootPart = v2.character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart.CustomPhysicalProperties then
			local customPhysicalProperties = humanoidRootPart.CustomPhysicalProperties
			humanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(
				v2.density or customPhysicalProperties.Density,
				v2.friction,
				customPhysicalProperties.Elasticity,
				customPhysicalProperties.FrictionWeight,
				customPhysicalProperties.ElasticityWeight
			)
		end
	end

	debugPrint("[IceSkatingEffects] Friction set to:", v2.friction)
end

function IceSkatingEffects.GetFriction()
	return v2.friction or 0.025
end

function IceSkatingEffects.SetSprintBoost(sprintBoostEnabled)
	if not v2.active then
		debugPrint("[IceSkatingEffects] Sprint boost toggle ignored - skating not active")
		return
	end

	if v2.sprintBoostEnabled == sprintBoostEnabled then
		debugPrint("[IceSkatingEffects] Sprint boost already", sprintBoostEnabled and "ON" or "OFF")
		return
	end

	v2.sprintBoostEnabled = sprintBoostEnabled

	if sprintBoostEnabled then
		local IceSkatingConfig = require(game.ReplicatedStorage.Modules.Zones.IceSkatingConfig)
		local charlieBrown = IceSkatingConfig.Presets.CharlieBrown or {}
		v2.baseSpeedOriginal = v2.baseSkatingSpeed or charlieBrown.baseSkatingSpeed or 20
		v2.slideBoostOriginal = v2.slideBoost or charlieBrown.slideBoost or 2
		v2.slideDecayOriginal = v2.slideDecay or charlieBrown.slideDecay or 0.999
		local sprintSpeedBoost = charlieBrown.sprintSpeedBoost or 8
		local sprintSlideBoostIncrease = charlieBrown.sprintSlideBoostIncrease or 0.5
		local sprintDecayBoost = charlieBrown.sprintDecayBoost or 0.0005
		local sprintBoostTweenInTime = charlieBrown.sprintBoostTweenInTime or 0.2
		local sprintBoostTweenOutTime = charlieBrown.sprintBoostTweenOutTime or 0.8
		local tweenInfo = TweenInfo.new(sprintBoostTweenInTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenInfo2 = TweenInfo.new(sprintBoostTweenOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local v4 = v2.character:FindFirstChild("SprintBoostProxy")

		if not v4 then
			v4 = Instance.new("NumberValue")
			v4.Name = "SprintBoostProxy"
			v4.Value = 0
			v4.Parent = v2.character
		end

		local changedConnection = v4.Changed:Connect(function(p)
			if not (v2.active and v2.sprintBoostEnabled) then
				return
			end

			v2.baseSkatingSpeed = v2.baseSpeedOriginal + sprintSpeedBoost * p
			v2.slideBoost = v2.slideBoostOriginal + sprintSlideBoostIncrease * p
			v2.slideDecay = math.min(0.9999, v2.slideDecayOriginal + sprintDecayBoost * p)
		end)
		table.insert(v2.connections, changedConnection)

		local function onSprintStart()
			if not (v2.active and v2.sprintBoostEnabled) or v2.sprintBoostActive then
				return
			end

			v2.sprintBoostActive = true

			if v2.sprintBoostTween then
				v2.sprintBoostTween:Cancel()
			end

			v2.sprintBoostTween = TweenService:Create(v4, tweenInfo, {
				Value = 1
			})
			v2.sprintBoostTween:Play()
			debugPrint("[IceSkatingEffects] Sprint boost activated")
		end

		local function onSprintEnd()
			if not (v2.active and v2.sprintBoostEnabled and v2.sprintBoostActive) then
				return
			end

			v2.sprintBoostActive = false

			if v2.sprintBoostTween then
				v2.sprintBoostTween:Cancel()
			end

			v2.sprintBoostTween = TweenService:Create(v4, tweenInfo2, {
				Value = 0
			})
			v2.sprintBoostTween:Play()
			debugPrint("[IceSkatingEffects] Sprint boost decaying")
		end

		local v5 = InputService:OnAction("Sprint", onSprintStart)
		table.insert(v2.connections, v5)
		local v6 = InputService:OnActionReleased("Sprint", onSprintEnd)
		table.insert(v2.connections, v6)
		local stats = v2.character:FindFirstChild("Stats")
		local holdingSprint = stats and stats:FindFirstChild("HoldingSprint")
		local valueChangedConnection

		if holdingSprint then
			valueChangedConnection = holdingSprint:GetPropertyChangedSignal("Value"):Connect(function()
				if holdingSprint.Value == true then
					onSprintStart()
				else
					onSprintEnd()
				end
			end)
			table.insert(v2.connections, valueChangedConnection)
		end

		v2.sprintBoostInputConns = {
			v5,
			v6,
			changedConnection,
			valueChangedConnection
		}
		local v7 = InputService:GetActionState("Sprint") == true
		local v8 = holdingSprint and holdingSprint.Value == true

		if v7 or v8 then
			onSprintStart()
		end

		debugPrint("[IceSkatingEffects] Sprint Boost ENABLED - hold Shift or use mobile sprint button for speed boost")
	else
		if v2.sprintBoostInputConns then
			for _, sprintBoostInputConn in ipairs(v2.sprintBoostInputConns) do
				if sprintBoostInputConn and sprintBoostInputConn.Connected then
					sprintBoostInputConn:Disconnect()
				end
			end

			v2.sprintBoostInputConns = nil
		end

		if v2.sprintBoostTween then
			v2.sprintBoostTween:Cancel()
			v2.sprintBoostTween = nil
		end

		if v2.baseSpeedOriginal then
			v2.baseSkatingSpeed = v2.baseSpeedOriginal
		end

		if v2.slideBoostOriginal then
			v2.slideBoost = v2.slideBoostOriginal
		end

		if v2.slideDecayOriginal then
			v2.slideDecay = v2.slideDecayOriginal
		end

		local sprintBoostProxy = v2.character and v2.character:FindFirstChild("SprintBoostProxy")

		if sprintBoostProxy then
			sprintBoostProxy:Destroy()
		end

		v2.sprintBoostActive = false
		debugPrint("[IceSkatingEffects] Sprint Boost DISABLED")
	end
end

function IceSkatingEffects.GetSprintBoost()
	return v2.sprintBoostEnabled or false
end

function IceSkatingEffects.ForceStopSprint()
	if not (v2.active and v2.sprintBoostActive) then
		return
	end

	debugPrint("[IceSkatingEffects] Force stopping sprint boost (hard cancel)")
	v2.sprintBoostActive = false

	if v2.sprintBoostTween then
		v2.sprintBoostTween:Cancel()
		v2.sprintBoostTween = nil
	end

	local sprintBoostProxy = v2.character and v2.character:FindFirstChild("SprintBoostProxy")

	if sprintBoostProxy then
		sprintBoostProxy.Value = 0
	end

	debugPrint("[IceSkatingEffects] Sprint boost force stopped")
end

function IceSkatingEffects.IsSprintActive()
	return v2.sprintBoostActive or false
end

function IceSkatingEffects.SetAnimationSpeedUp(animationSpeedUpEnabled)
	if not v2.active then
		debugPrint("[IceSkatingEffects] Animation toggle ignored - skating not active")
		return
	end

	v2.animationSpeedUpEnabled = animationSpeedUpEnabled
	local skatingAnimState = v2.skatingAnimState
	local character = v2.character

	if animationSpeedUpEnabled then
		if character then
			character:SetAttribute("DisableSprintAnimations", true)
		end

		if not (skatingAnimState and skatingAnimState.runTrack and skatingAnimState.animationConnection) then
			debugPrint("[IceSkatingEffects] Animation system not set up or disconnected - setting up now...")
			local v4 = {
				animationSpeedMultiplier = 1.3,
				useSkatingParticles = true
			}
			local success, result = pcall(function()
				IceSkatingEffects.SetupAnimationSpeedUp(v4)
			end)

			if not success then
				warn("[IceSkatingEffects] Animation setup failed:", result)
			end
		end

		debugPrint("[IceSkatingEffects] Animation Speed-Up ENABLED - treadmill-style run animation active")
	else
		if skatingAnimState and skatingAnimState.runTrack and skatingAnimState.runTrack.IsPlaying then
			skatingAnimState.runTrack:Stop(0.2)
		end

		if skatingAnimState and skatingAnimState.iceSprayParticle then
			skatingAnimState.iceSprayParticle.Rate = 0
		end

		if skatingAnimState and skatingAnimState.animationConnection then
			skatingAnimState.animationConnection:Disconnect()
			skatingAnimState.animationConnection = nil
			debugPrint("[IceSkatingEffects] Disconnected animation heartbeat")
		end

		if character then
			character:SetAttribute("DisableSprintAnimations", false)
		end

		debugPrint("[IceSkatingEffects] Animation Speed-Up DISABLED - normal walk/run animations restored")
	end
end

function IceSkatingEffects.GetAnimationSpeedUp()
	return v2.animationSpeedUpEnabled ~= false
end

function IceSkatingEffects.SetArmBalancing(armBalancingEnabled)
	v2.armBalancingEnabled = armBalancingEnabled

	if not v2.active then
		debugPrint(
			"[IceSkatingEffects] Arm balancing preference stored (will apply on next activation):",
			armBalancingEnabled and "ON" or "OFF"
		)
	elseif armBalancingEnabled then
		if IceSkatingEffects.IsArmsOutActive() then
			debugPrint("[IceSkatingEffects] Arms Out detected, disabling to enable Arm Balancing")
			IceSkatingEffects.DisableArmsOut()
		end

		if not v2.armBalanceState then
			debugPrint("[IceSkatingEffects] Setting up arm balancing...")
			local success, result = pcall(function()
				IceSkatingEffects.SetupArmBalancing({})
			end)

			if not success then
				warn("[IceSkatingEffects] Arm balancing setup failed:", result)
			end
		end

		debugPrint("[IceSkatingEffects] Arm Balancing ENABLED")
	else
		if v2.armBalanceState then
			local armBalanceState = v2.armBalanceState

			if armBalanceState.leftIK then
				if armBalanceState.leftIK.ik then
					armBalanceState.leftIK.ik:Destroy()
				end

				if armBalanceState.leftIK.rotIK then
					armBalanceState.leftIK.rotIK:Destroy()
				end

				if armBalanceState.leftIK.target then
					armBalanceState.leftIK.target:Destroy()
				end

				if armBalanceState.leftIK.rotTarget then
					armBalanceState.leftIK.rotTarget:Destroy()
				end

				if armBalanceState.leftIK.pole then
					armBalanceState.leftIK.pole:Destroy()
				end
			end

			if armBalanceState.rightIK then
				if armBalanceState.rightIK.ik then
					armBalanceState.rightIK.ik:Destroy()
				end

				if armBalanceState.rightIK.rotIK then
					armBalanceState.rightIK.rotIK:Destroy()
				end

				if armBalanceState.rightIK.target then
					armBalanceState.rightIK.target:Destroy()
				end

				if armBalanceState.rightIK.rotTarget then
					armBalanceState.rightIK.rotTarget:Destroy()
				end

				if armBalanceState.rightIK.pole then
					armBalanceState.rightIK.pole:Destroy()
				end
			end

			v2.armBalanceState = nil
		end

		debugPrint("[IceSkatingEffects] Arm Sway DISABLED")
	end
end

function IceSkatingEffects.GetArmBalancing()
	return v2.armBalancingEnabled == true
end

local fn

function IceSkatingEffects.Deactivate(p)
	if not v2.active then
		return
	end

	if p then
		debugPrint("[IceSkatingEffects] Deactivating effects (preserving physics)...")
	else
		debugPrint("[IceSkatingEffects] Deactivating effects...")
	end

	local v4

	if v2.preset then
		local IceSkatingConfig = require(game.ReplicatedStorage.Modules.Zones.IceSkatingConfig)
		v4 = IceSkatingConfig.Presets[v2.preset]
	end

	for _, connection in ipairs(v2.connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end

	v2.connections = {}

	if p then
		if v2.speedTween and v2.speedTween.tween then
			v2.speedTween.tween:Cancel()
		end

		v2.speedTween = nil
		debugPrint("[IceSkatingEffects] Keeping current WalkSpeed for reactivation")
	else
		if v2.speedTween then
			if v2.speedTween.tween then
				v2.speedTween.tween:Cancel()
			end

			debugPrint("[IceSkatingEffects] Speed tween cancelled")
		end

		v2.speedTween = nil
		v2.baseWalkSpeed = nil
	end

	if v2.sprintBoostTween then
		v2.sprintBoostTween:Cancel()
		v2.sprintBoostTween = nil
	end

	local sprintBoostProxy = v2.character and v2.character:FindFirstChild("SprintBoostProxy")

	if sprintBoostProxy then
		sprintBoostProxy:Destroy()
	end

	v2.sprintBoostActive = false
	v2.baseSpeedOriginal = nil
	v2.slideBoostOriginal = nil
	v2.slideDecayOriginal = nil

	if v2.vectorForceState then
		if v2.vectorForceState.connection and v2.vectorForceState.connection.Connected then
			v2.vectorForceState.connection:Disconnect()
		end

		if v2.vectorForceState.vectorForce then
			v2.vectorForceState.vectorForce:Destroy()
		end

		if v2.vectorForceState.attachment then
			v2.vectorForceState.attachment:Destroy()
		end

		if v2.vectorForceState.originalAutoRotate ~= nil and v2.humanoid then
			v2.humanoid.AutoRotate = v2.vectorForceState.originalAutoRotate
			debugPrint("[IceSkatingEffects] Restored AutoRotate:", v2.vectorForceState.originalAutoRotate)
		end

		if v2.vectorForceState.multiplier then
			debugPrint("[IceSkatingEffects] VectorForce speed restoration handled server-side")
		end

		v2.vectorForceState = nil
		debugPrint("[IceSkatingEffects] VectorForce cleanup complete")
	end

	if v2.bodyVelocityState then
		if v2.bodyVelocityState.connection and v2.bodyVelocityState.connection.Connected then
			v2.bodyVelocityState.connection:Disconnect()
		end

		if v2.bodyVelocityState.bodyVelocity then
			v2.bodyVelocityState.bodyVelocity:Destroy()
		end

		v2.bodyVelocityState = nil
		debugPrint("[IceSkatingEffects] BodyVelocity cleanup complete")
	end

	if p or not (v4 and v2.character) then
		if p then
			debugPrint("[IceSkatingEffects] Keeping SpeedModifiers for reactivation")
		end
	else
		v2.character:SetAttribute("IceSprintBoost", nil)
		v2.modifiersApplied = nil
		v2.appliedMultiplier = nil
		v2.baseWalkSpeedAtStart = nil
		v2.iceBuffTracking = nil
		debugPrint("[IceSkatingEffects] Speed restoration handled server-side, cleared tracking state")
	end

	if p then
		debugPrint("[IceSkatingEffects] Skipping physics reset for reactivation")
	else
		if v2.rootPart and v2.rootPart.Parent then
			v2.rootPart.CustomPhysicalProperties = PhysicalProperties.new(1.5, 0.3, 0.5, 1, 1)
			debugPrint("[IceSkatingEffects] Restored CustomPhysicalProperties to default values")
		end

		if v2.humanoid and v2.humanoid.Parent then
			v2.humanoid.MaxSlopeAngle = 89
		end
	end

	if v2.trails then
		for _, trail in ipairs(v2.trails) do
			if trail.leftTrail then
				trail.leftTrail:Destroy()
			end

			if trail.rightTrail then
				trail.rightTrail:Destroy()
			end

			if trail.sparkles then
				trail.sparkles:Destroy()
			end

			if trail.iceDust then
				trail.iceDust:Destroy()
			end

			if trail.speedLines then
				trail.speedLines:Destroy()
			end

			if trail.screenSnow then
				trail.screenSnow:Destroy()
			end

			if trail.blueTint then
				trail.blueTint:Destroy()
			end

			if trail.bloom then
				trail.bloom:Destroy()
			end

			if trail.sunRays then
				trail.sunRays:Destroy()
			end

			if trail.depthOfField then
				trail.depthOfField:Destroy()
			end

			if trail.leftAtt0 then
				trail.leftAtt0:Destroy()
			end

			if trail.leftAtt1 then
				trail.leftAtt1:Destroy()
			end

			if trail.rightAtt0 then
				trail.rightAtt0:Destroy()
			end

			if trail.rightAtt1 then
				trail.rightAtt1:Destroy()
			end
		end
	end

	v2.trails = {}

	if v2.panicEmitter and v2.panicEmitter.Parent then
		v2.panicEmitter:Destroy()
		v2.panicEmitter = nil
	end

	if v2.circleSkatingState then
		if v2.circleSkatingState.alignOrientation then
			v2.circleSkatingState.alignOrientation:Destroy()
		end

		if v2.circleSkatingState.attachment then
			v2.circleSkatingState.attachment:Destroy()
		end

		v2.circleSkatingState = nil
		debugPrint("[IceSkatingEffects] Circle skating cleanup complete")
	end

	if v2.armBalanceState then
		if v2.armBalanceState.leftIK then
			local leftIK = v2.armBalanceState.leftIK

			if leftIK.ik then
				leftIK.ik:Destroy()
			end

			if leftIK.target then
				leftIK.target:Destroy()
			end

			if leftIK.pole then
				leftIK.pole:Destroy()
			end
		end

		if v2.armBalanceState.rightIK then
			local rightIK = v2.armBalanceState.rightIK

			if rightIK.ik then
				rightIK.ik:Destroy()
			end

			if rightIK.target then
				rightIK.target:Destroy()
			end

			if rightIK.pole then
				rightIK.pole:Destroy()
			end
		end

		v2.armBalanceState = nil
		debugPrint("[IceSkatingEffects] Arm sway cleanup complete")
	end

	if v2.armIKState then
		for _, v5 in pairs(v2.armIKState) do
			if v5.ikControl then
				v5.ikControl:Destroy()
			end

			if v5.targetAttachment then
				v5.targetAttachment:Destroy()
			end

			if v5.poleAttachment then
				v5.poleAttachment:Destroy()
			end

			if v5.debugMarker then
				v5.debugMarker:Destroy()
			end
		end

		v2.armIKState = nil
	end

	if v2.skatingAnimState then
		if v2.skatingAnimState.runTrack then
			pcall(function()
				if v2.skatingAnimState.runTrack.IsPlaying then
					v2.skatingAnimState.runTrack:Stop(0)
				end

				v2.skatingAnimState.runTrack:Destroy()
			end)
		end

		if v2.skatingAnimState.walkTrack then
			pcall(function()
				if v2.skatingAnimState.walkTrack.IsPlaying then
					v2.skatingAnimState.walkTrack:Stop(0)
				end

				v2.skatingAnimState.walkTrack:Destroy()
			end)
		end

		if v2.skatingAnimState.runAnimation then
			v2.skatingAnimState.runAnimation:Destroy()
		end

		if v2.skatingAnimState.iceSprayParticle then
			v2.skatingAnimState.iceSprayParticle:Destroy()
		end

		if v2.skatingAnimState.iceSprayAttachment then
			v2.skatingAnimState.iceSprayAttachment:Destroy()
		end

		v2.skatingAnimState = nil
		debugPrint("[IceSkatingEffects] Skating animation cleanup complete")
	end

	for _, sound in pairs(v2.sounds) do
		if not sound then
			continue
		end

		sound:Stop()
		sound:Destroy()
	end

	v2.sounds = {}

	if v2.blur and v2.blur.Parent then
		v2.blur:Destroy()
		v2.blur = nil
	end

	if v2.sprintBlur and v2.sprintBlur.Parent then
		v2.sprintBlur:Destroy()
		v2.sprintBlur = nil
	end

	v2.currentSprintTilt = 0
	v2.targetSprintTilt = 0

	if v2.camera then
		local sprintBaseFOV = v2.sprintBaseFOV or v4 and v4.baseFOV or 70
		v2.camera.FieldOfView = sprintBaseFOV
	end

	v2.sprintBaseFOV = nil
	IceSkatingEffects.RemoveIceEventTransition()
	fn()
	v2.active = false
	v2.preset = nil

	if IceSkatingEffects.IsArmsOutActive and IceSkatingEffects.IsArmsOutActive() then
		IceSkatingEffects.DisableArmsOut()
	end

	IceSkatingEffects.StopWatchingTwisteds()
	debugPrint("[IceSkatingEffects] Deactivation complete")
end

local v4 = {}
local v5 = {}
local part = nil
local connection = nil
local v6 = {
	USE_COLLECTION_SERVICE_TAGS = true,
	FREEZABLE_TAG = "Freezable",
	USE_AMBIENT_SNOW_ONLY = false,
	USE_BATCHING = true,
	BATCH_SIZE = 30,
	DELETE_RUGS_AND_CARPETS = false,
	USE_ICE_TRANSITION_EFFECTS = true
}
local v7 = { "rug", "carpet" }
local v8 = {}
local v9 = {
	generator = true,
	machine = true,
	button = true,
	lever = true,
	switch = true,
	door = true,
	spawn = true,
	chest = true,
	crate = true,
	barrel = true,
	prop = true,
	decoration = true,
	item = true,
	pickup = true,
	collectible = true,
	interactable = true,
	trigger = true
}
local v10 = {
	"floor",
	"rug",
	"ground",
	"platform",
	"base",
	"carpet",
	"ramp",
	"stair"
}

local function isExcludedName(name)
	local match = name:match("^(%w+)")

	if match and v9[match] then
		return true
	end

	for k in pairs(v9) do
		if name:find(k, 1, true) then
			return true
		end
	end

	return false
end

local function isFloorName(name)
	for _, v11 in ipairs(v10) do
		if name:find(v11, 1, true) then
			return true
		end
	end

	return false
end

local function isDeleteTarget(name)
	for _, v11 in ipairs(v7) do
		if name:find(v11, 1, true) then
			return true
		end
	end

	return false
end

function IceSkatingEffects.SetFreezeConfig(data)
	if data.useCollectionServiceTags ~= nil then
		v6.USE_COLLECTION_SERVICE_TAGS = data.useCollectionServiceTags
	end

	if data.useAmbientSnowOnly ~= nil then
		v6.USE_AMBIENT_SNOW_ONLY = data.useAmbientSnowOnly
	end

	if data.useBatching ~= nil then
		v6.USE_BATCHING = data.useBatching
	end

	if data.batchSize then
		v6.BATCH_SIZE = data.batchSize
	end

	if data.deleteRugsAndCarpets ~= nil then
		v6.DELETE_RUGS_AND_CARPETS = data.deleteRugsAndCarpets
	end

	if data.useIceTransitionEffects ~= nil then
		v6.USE_ICE_TRANSITION_EFFECTS = data.useIceTransitionEffects
	end

	debugPrint("[IceSkatingEffects] FreezeConfig updated:", v6)
end

function IceSkatingEffects.GetFreezeConfig()
	return v6
end

local function createAmbientSnow()
	if part then
		return
	end

	local character = v2.character

	if not character then
		local localPlayer = game.Players.LocalPlayer
		character = localPlayer and localPlayer.Character
	end

	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		warn("[IceSkatingEffects] No HumanoidRootPart for snow attachment")
		return
	end

	part = Instance.new("Part")
	part.Name = "PlayerSnowEmitter"
	part.Size = createVector(50, 1, 50)
	part.Transparency = 1
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.Anchored = false
	part.Parent = character
	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = part
	weld.C0 = CFrame.new(0, 20, 0)
	weld.Parent = part
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "FallingSnow"
	particleEmitter.Texture = "rbxassetid://241876428"
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 240, 255))
	})
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.3, 0.4),
		NumberSequenceKeypoint.new(0.7, 0.35),
		NumberSequenceKeypoint.new(1, 0.15)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.2, 0),
		NumberSequenceKeypoint.new(0.8, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.LightEmission = 0.2
	particleEmitter.LightInfluence = 0.8
	particleEmitter.Lifetime = NumberRange.new(3, 5)
	particleEmitter.Rate = 200
	particleEmitter.Speed = NumberRange.new(4, 10)
	particleEmitter.SpreadAngle = Vector2.new(70, 70)
	particleEmitter.Acceleration = createVector(0, -4, 0)
	particleEmitter.Drag = 1.2
	particleEmitter.VelocityInheritance = 0.15
	particleEmitter.RotSpeed = NumberRange.new(-100, 100)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.EmissionDirection = Enum.NormalId.Bottom
	particleEmitter.Parent = part
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Name = "BigSnowflakes"
	particleEmitter2.Texture = "rbxassetid://1084981592"
	particleEmitter2.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	particleEmitter2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 0.8),
		NumberSequenceKeypoint.new(1, 0.4)
	})
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.LightEmission = 0.25
	particleEmitter2.LightInfluence = 0.7
	particleEmitter2.Lifetime = NumberRange.new(4, 7)
	particleEmitter2.Rate = 30
	particleEmitter2.Speed = NumberRange.new(2, 6)
	particleEmitter2.SpreadAngle = Vector2.new(50, 50)
	particleEmitter2.Acceleration = createVector(0, -2.5, 0)
	particleEmitter2.Drag = 2
	particleEmitter2.VelocityInheritance = 0.2
	particleEmitter2.RotSpeed = NumberRange.new(-150, 150)
	particleEmitter2.Rotation = NumberRange.new(0, 360)
	particleEmitter2.EmissionDirection = Enum.NormalId.Bottom
	particleEmitter2.Parent = part
	local particleEmitter3 = Instance.new("ParticleEmitter")
	particleEmitter3.Name = "IceSparkles"
	particleEmitter3.Texture = "rbxassetid://6490035152"
	particleEmitter3.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 220, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 230, 255))
	})
	particleEmitter3.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.15, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.45),
		NumberSequenceKeypoint.new(0.85, 0.25),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter3.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.1, 0.1),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(0.9, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter3.LightEmission = 1
	particleEmitter3.LightInfluence = 0.2
	particleEmitter3.Lifetime = NumberRange.new(0.6, 1.2)
	particleEmitter3.Rate = 50
	particleEmitter3.Speed = NumberRange.new(1, 5)
	particleEmitter3.SpreadAngle = Vector2.new(180, 180)
	particleEmitter3.Acceleration = createVector(0, -1, 0)
	particleEmitter3.Drag = 4
	particleEmitter3.VelocityInheritance = 0.25
	particleEmitter3.RotSpeed = NumberRange.new(-250, 250)
	particleEmitter3.Rotation = NumberRange.new(0, 360)
	particleEmitter3.EmissionDirection = Enum.NormalId.Bottom
	particleEmitter3.Parent = part
	local attachment = Instance.new("Attachment")
	attachment.Name = "FrostMistAttachment"
	attachment.Position = createVector(0, -2, 0)
	attachment.Parent = humanoidRootPart
	local particleEmitter4 = Instance.new("ParticleEmitter")
	particleEmitter4.Name = "FrostMist"
	particleEmitter4.Texture = "rbxassetid://243660364"
	particleEmitter4.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 240, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 225, 245))
	})
	particleEmitter4.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.3, 1.5),
		NumberSequenceKeypoint.new(0.7, 2.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter4.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.8),
		NumberSequenceKeypoint.new(0.5, 0.75),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter4.LightEmission = 0.1
	particleEmitter4.LightInfluence = 1
	particleEmitter4.Lifetime = NumberRange.new(1.5, 3)
	particleEmitter4.Rate = 12
	particleEmitter4.Speed = NumberRange.new(1, 3)
	particleEmitter4.SpreadAngle = Vector2.new(180, 40)
	particleEmitter4.Acceleration = createVector(0, 0.5, 0)
	particleEmitter4.Drag = 2.5
	particleEmitter4.VelocityInheritance = 0.4
	particleEmitter4.RotSpeed = NumberRange.new(-30, 30)
	particleEmitter4.Rotation = NumberRange.new(0, 360)
	particleEmitter4.EmissionDirection = Enum.NormalId.Front
	particleEmitter4.Parent = attachment
	table.insert(v5, attachment)
	debugPrint("[IceSkatingEffects] Snow attached to player - 4 particle layers (snow, big flakes, sparkles, mist)")
end

fn = function()
	if connection then
		connection:Disconnect()
		connection = nil
	end

	if part then
		part:Destroy()
		part = nil
	end

	local character = v2.character

	if not character then
		local localPlayer = game.Players.LocalPlayer
		character = localPlayer and localPlayer.Character
	end

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local frostMistAttachment = humanoidRootPart and humanoidRootPart:FindFirstChild("FrostMistAttachment")

		if frostMistAttachment then
			frostMistAttachment:Destroy()
		end
	end

	debugPrint("[IceSkatingEffects] Snow effects removed")
end

local screenGui = nil
local v11 = {}

local function createChillingWindBurst()
	local localPlayer = game.Players.LocalPlayer

	if not localPlayer then
		return
	end

	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local part2 = Instance.new("Part")
	part2.Name = "ChillingWindSource"
	part2.Size = createVector(20, 10, 1)
	part2.Anchored = true
	part2.CanCollide = false
	part2.Transparency = 1
	part2.CastShadow = false
	local lookVector = currentCamera.CFrame.LookVector
	part2.CFrame = CFrame.new(humanoidRootPart.Position + lookVector * 25, humanoidRootPart.Position)
	part2.Parent = workspace
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "ChillingWind"
	particleEmitter.Texture = "rbxassetid://243660364"
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 230, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 220, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 240, 255))
	})
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.3, 3),
		NumberSequenceKeypoint.new(0.7, 4),
		NumberSequenceKeypoint.new(1, 2)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.2, 0.4),
		NumberSequenceKeypoint.new(0.7, 0.6),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.LightEmission = 0.3
	particleEmitter.LightInfluence = 0.8
	particleEmitter.Lifetime = NumberRange.new(0.6, 1)
	particleEmitter.Rate = 100
	particleEmitter.Speed = NumberRange.new(50, 70)
	particleEmitter.SpreadAngle = Vector2.new(25, 15)
	particleEmitter.Drag = 0.5
	particleEmitter.RotSpeed = NumberRange.new(-100, 100)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.EmissionDirection = Enum.NormalId.Front
	particleEmitter.Enabled = true
	particleEmitter.Parent = part2
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Name = "IceCrystalsWind"
	particleEmitter2.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter2.Color = ColorSequence.new(Color3.fromRGB(200, 240, 255))
	particleEmitter2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.3, 0.25),
		NumberSequenceKeypoint.new(1, 0.05)
	})
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(0.4, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.LightEmission = 1
	particleEmitter2.Lifetime = NumberRange.new(0.4, 0.8)
	particleEmitter2.Rate = 80
	particleEmitter2.Speed = NumberRange.new(45, 65)
	particleEmitter2.SpreadAngle = Vector2.new(30, 20)
	particleEmitter2.Drag = 0.3
	particleEmitter2.RotSpeed = NumberRange.new(-200, 200)
	particleEmitter2.Rotation = NumberRange.new(0, 360)
	particleEmitter2.EmissionDirection = Enum.NormalId.Front
	particleEmitter2.Enabled = true
	particleEmitter2.Parent = part2
	table.insert(v11, part2)
	local v12 = Audio:Play("Sounds.ZoneEvents.Skating.Wind", {
		Name = "ChillingWindSound",
		Volume = 0.7,
		PlaybackSpeed = 0.9,
		Parent = humanoidRootPart
	})

	if v12 and v then
		v.AssignSound(v12, "Environmental")
	end

	task.delay(2, function()
		if particleEmitter and particleEmitter.Parent then
			local rate = particleEmitter.Rate

			for i = 1, 10 do
				task.wait(0.1)

				if particleEmitter and particleEmitter.Parent then
					particleEmitter.Rate = rate * (1 - i / 10)
				end
			end

			if particleEmitter and particleEmitter.Parent then
				particleEmitter.Enabled = false
			end
		end

		if particleEmitter2 and particleEmitter2.Parent then
			local rate = particleEmitter2.Rate

			for i = 1, 10 do
				task.wait(0.1)

				if particleEmitter2 and particleEmitter2.Parent then
					particleEmitter2.Rate = rate * (1 - i / 10)
				end
			end

			if particleEmitter2 and particleEmitter2.Parent then
				particleEmitter2.Enabled = false
			end
		end

		task.delay(2, function()
			for _, v13 in ipairs(v11) do
				if v13 and v13.Parent then
					v13:Destroy()
				end
			end

			v11 = {}
		end)
	end)
	debugPrint("[IceSkatingEffects] Chilling wind burst activated!")
end

local function createFrostOverlay()
	local localPlayer = game.Players.LocalPlayer

	if not localPlayer then
		return
	end

	local playerGui = localPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return
	end

	if screenGui and screenGui.Parent then
		screenGui:Destroy()
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FrostOverlayGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 5
	screenGui.Parent = playerGui
	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.Name = "FrostFrame"
	canvasGroup.Size = UDim2.new(1, 0, 1, 0)
	canvasGroup.Position = UDim2.new(0, 0, 0, 0)
	canvasGroup.BackgroundTransparency = 1
	canvasGroup.Parent = screenGui
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "FrostVignette"
	imageLabel.Size = UDim2.new(1, 0, 1, 0)
	imageLabel.Position = UDim2.new(0, 0, 0, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://1039998940"
	imageLabel.ImageColor3 = Color3.fromRGB(170, 215, 255)
	imageLabel.ImageTransparency = 0.3
	imageLabel.ScaleType = Enum.ScaleType.Stretch
	imageLabel.Parent = canvasGroup
	canvasGroup.GroupTransparency = 1
	TweenService:Create(canvasGroup, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		GroupTransparency = 0.25
	}):Play()
	task.delay(1.5, function()
		if canvasGroup and canvasGroup.Parent then
			TweenService:Create(canvasGroup, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				GroupTransparency = 0.6
			}):Play()
		end
	end)
	task.delay(4, function()
		if canvasGroup and canvasGroup.Parent then
			local tween = TweenService:Create(
				canvasGroup,
				TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					GroupTransparency = 1
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				if screenGui and screenGui.Parent then
					screenGui:Destroy()
					screenGui = nil
				end
			end)
		end
	end)
	debugPrint("[IceSkatingEffects] Frost overlay created (smooth fade)")
end

local function removeFrostOverlay()
	if not (screenGui and screenGui.Parent) then
		return
	end

	local frostFrame = screenGui:FindFirstChild("FrostFrame")

	if frostFrame then
		local tween = TweenService:Create(
			frostFrame,
			TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				GroupTransparency = 1
			}
		)
		tween:Play()
		tween.Completed:Connect(function()
			if screenGui and screenGui.Parent then
				screenGui:Destroy()
				screenGui = nil
			end
		end)
	else
		screenGui:Destroy()
		screenGui = nil
	end

	debugPrint("[IceSkatingEffects] Frost overlay fading out smoothly...")
end

function IceSkatingEffects.PlayIceEventTransition()
	createChillingWindBurst()
	task.delay(0.3, function()
		createFrostOverlay()
	end)
	debugPrint("[IceSkatingEffects] Ice event transition effects activated!")
end

function IceSkatingEffects.RemoveIceEventTransition()
	removeFrostOverlay()

	for _, v12 in ipairs(v11) do
		if v12 and v12.Parent then
			v12:Destroy()
		end
	end

	v11 = {}
	debugPrint("[IceSkatingEffects] Ice event transition effects removed!")
end

local function freezePart(parent)
	if not v4[parent] then
		v4[parent] = {
			material = parent.Material,
			color = parent.Color,
			reflectance = parent.Reflectance
		}
	end

	parent.Material = Enum.Material.Ice
	parent.Color = Color3.fromRGB(200, 230, 255)
	parent.Reflectance = 0.3

	if v6.USE_AMBIENT_SNOW_ONLY or parent:FindFirstChild("FrozenSnowEmitter") then
		return true
	end

	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "FrozenSnowEmitter"
	particleEmitter.Texture = "rbxassetid://243660364"
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(
			1,
			0.2
		) })
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.8, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(3, 5)
	particleEmitter.Rate = 5
	particleEmitter.Speed = NumberRange.new(0.5, 1.5)
	particleEmitter.SpreadAngle = Vector2.new(30, 30)
	particleEmitter.Acceleration = createVector(0, -0.5, 0)
	particleEmitter.RotSpeed = NumberRange.new(-30, 30)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.EmissionDirection = Enum.NormalId.Top
	particleEmitter.Parent = parent
	table.insert(v5, particleEmitter)
	return true
end

function IceSkatingEffects.FreezeLevel()
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		warn("[IceSkatingEffects] No CurrentRoom found")
		return false
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if not model then
		warn("[IceSkatingEffects] No map model found in CurrentRoom")
		return false
	end

	if v6.USE_ICE_TRANSITION_EFFECTS then
		IceSkatingEffects.PlayIceEventTransition()
	end

	if v6.DELETE_RUGS_AND_CARPETS then
		local count = 0

		for _, descendant in pairs(model:GetDescendants()) do
			if not ((descendant:IsA("Model") or descendant:IsA("BasePart")) and isDeleteTarget(descendant.Name:lower())) then
				continue
			end

			local v12 = v8
			local v13 = {
				instance = descendant,
				parent = descendant.Parent,
				cframe = 0
			}
			local cframe

			if descendant:IsA("BasePart") then
				cframe = descendant.CFrame or nil
			end

			v13.cframe = cframe
			table.insert(v12, v13)
			descendant.Parent = nil
			count += 1
		end

		if count > 0 then
			debugPrint("[IceSkatingEffects] DEBUG: Deleted", count, "rug/carpet items")
		end
	end

	local count = 0
	local count2 = 0

	if v6.USE_COLLECTION_SERVICE_TAGS then
		local tagged = CollectionService:GetTagged(v6.FREEZABLE_TAG)
		local parts = {}

		for _, part2 in ipairs(tagged) do
			if part2:IsDescendantOf(model) and part2:IsA("BasePart") then
				table.insert(parts, part2)
			end
		end

		if #parts > 0 then
			debugPrint("[IceSkatingEffects] Using CollectionService tags - found", #parts, "tagged parts")

			for _, v12 in ipairs(parts) do
				freezePart(v12)
				count += 1

				if not v6.USE_BATCHING then
					continue
				end

				count2 += 1

				if not (v6.BATCH_SIZE <= count2) then
					continue
				end

				task.wait()
				count2 = 0
			end

			createAmbientSnow()
			debugPrint(
				"[IceSkatingEffects] Frozen",
				count,
				"tagged floor parts",
				v6.USE_AMBIENT_SNOW_ONLY and "(ambient snow only)" or "(with per-floor emitters)"
			)
			return true
		else
			debugPrint("[IceSkatingEffects] No tagged parts found, falling back to name-based detection")
		end
	end

	for _, part2 in pairs(model:GetDescendants()) do
		if not part2:IsA("BasePart") or CollectionService:HasTag(part2, "NoIce") then
			continue
		end

		local name = part2.Name:lower()
		local name2

		if part2.Parent and part2.Parent:IsA("Model") then
			name2 = part2.Parent.Name:lower()
		end

		if isExcludedName(name) or name2 and isExcludedName(name2) or not (isFloorName(name) or name2 and isFloorName(name2)) then
			continue
		end

		freezePart(part2)
		count += 1

		if not v6.USE_BATCHING then
			continue
		end

		count2 += 1

		if not (v6.BATCH_SIZE <= count2) then
			continue
		end

		task.wait()
		count2 = 0
	end

	createAmbientSnow()
	debugPrint(
		"[IceSkatingEffects] Frozen",
		count,
		"floor parts",
		v6.USE_AMBIENT_SNOW_ONLY and "(ambient snow only)" or "(with per-floor emitters)"
	)
	return true
end

function IceSkatingEffects.UnfreezeLevel()
	IceSkatingEffects.RemoveIceEventTransition()
	fn()

	for k, v12 in pairs(v4) do
		if not (k and k.Parent) then
			continue
		end

		k.Material = v12.material
		k.Color = v12.color
		k.Reflectance = v12.reflectance
	end

	v4 = {}

	for _, v12 in pairs(v5) do
		if v12 and v12.Parent then
			v12:Destroy()
		end
	end

	v5 = {}

	if #v8 > 0 then
		local count = 0

		for _, v12 in ipairs(v8) do
			if not (v12.instance and v12.parent) then
				continue
			end

			v12.instance.Parent = v12.parent
			count += 1
		end

		if count > 0 then
			debugPrint("[IceSkatingEffects] DEBUG: Restored", count, "rug/carpet items")
		end

		v8 = {}
	end

	debugPrint("[IceSkatingEffects] Level unfrozen, snow removed")
	return true
end

function IceSkatingEffects.IsLevelFrozen()
	return next(v4) ~= nil
end

local heartbeatConnection = nil
local value = nil

function IceSkatingEffects.EnableInfiniteStamina()
	if heartbeatConnection then
		return
	end

	local character = v2.character

	if not character then
		warn("[IceSkatingEffects] No character for infinite stamina")
		return false
	end

	local stats = character:FindFirstChild("Stats")

	if not stats then
		return false
	end

	local currentStamina = stats:FindFirstChild("CurrentStamina")
	local stamina = stats:FindFirstChild("Stamina")

	if not (currentStamina and stamina) then
		return false
	end

	value = currentStamina.Value
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if currentStamina and currentStamina.Parent and stamina and stamina.Parent then
			currentStamina.Value = stamina.Value
		end
	end)
	debugPrint("[IceSkatingEffects] Infinite stamina enabled")
	return true
end

function IceSkatingEffects.DisableInfiniteStamina()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	debugPrint("[IceSkatingEffects] Infinite stamina disabled")
	return true
end

function IceSkatingEffects.IsInfiniteStaminaEnabled()
	return heartbeatConnection ~= nil
end

local heartbeatConnection2 = nil

function IceSkatingEffects.EnableAlwaysSprinting()
	if heartbeatConnection2 then
		return
	end

	local character = v2.character

	if not character then
		warn("[IceSkatingEffects] No character for always sprinting")
		return false
	end

	local stats = character:FindFirstChild("Stats")

	if not stats then
		return false
	end

	local holdingSprint = stats:FindFirstChild("HoldingSprint")
	StatModifierManager.RemoveModifiersBySource(character, "DevConsoleSprintDisable")
	character:SetAttribute("DisableSprintAnimations", nil)
	heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		if holdingSprint and holdingSprint.Parent then
			holdingSprint.Value = true
		end
	end)
	debugPrint("[IceSkatingEffects] Always sprinting enabled")
	return true
end

function IceSkatingEffects.DisableAlwaysSprinting()
	if heartbeatConnection2 then
		heartbeatConnection2:Disconnect()
		heartbeatConnection2 = nil
	end

	local character = v2.character

	if character then
		local stats = character:FindFirstChild("Stats")
		local holdingSprint = stats and stats:FindFirstChild("HoldingSprint")

		if holdingSprint then
			holdingSprint.Value = false
		end
	end

	debugPrint("[IceSkatingEffects] Always sprinting disabled")
	return true
end

function IceSkatingEffects.IsAlwaysSprintingEnabled()
	return heartbeatConnection2 ~= nil
end

local v12 = {}
local v13 = {}
local v14 = {}
local v15 = {}
local flag = false
local v16 = {
	particles = true,
	tilt = false,
	maxTiltDegrees = 12
}

function IceSkatingEffects.CreateEffectsOnOtherPlayer(player)
	local character = player.Character

	if not character then
		debugPrint("[IceSkatingEffects] CreateEffectsOnOtherPlayer - No character for", player.Name)
		return
	end

	if player == game.Players.LocalPlayer then
		debugPrint("[IceSkatingEffects] CreateEffectsOnOtherPlayer - Skipping self:", player.Name)
		return
	end

	if v12[player] then
		debugPrint("[IceSkatingEffects] CreateEffectsOnOtherPlayer - Already have effects on", player.Name)
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local leftFoot = character:FindFirstChild("LeftFoot") or character:FindFirstChild("Left Leg")
	local rightFoot = character:FindFirstChild("RightFoot") or character:FindFirstChild("Right Leg")

	if not humanoidRootPart then
		debugPrint("[IceSkatingEffects] CreateEffectsOnOtherPlayer - No HumanoidRootPart on", player.Name)
		return
	end

	debugPrint(
		"[IceSkatingEffects] Creating effects on other player:",
		player.Name,
		"- HRP:",
		humanoidRootPart and "YES" or "NO",
		"- Feet:",
		leftFoot and rightFoot and "YES" or "NO"
	)
	local v17 = {
		trails = {},
		particles = {},
		attachments = {}
	}

	if leftFoot and rightFoot then
		local attachment = Instance.new("Attachment")
		attachment.Name = "IceTrailAtt0_Other"
		attachment.Position = createVector(0, -0.3, 0.3)
		attachment.Parent = leftFoot
		table.insert(v17.attachments, attachment)
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "IceTrailAtt1_Other"
		attachment2.Position = createVector(0, -0.3, -0.3)
		attachment2.Parent = leftFoot
		table.insert(v17.attachments, attachment2)
		local trail = Instance.new("Trail")
		trail.Name = "IceBladeTrail_Other"
		trail.Attachment0 = attachment
		trail.Attachment1 = attachment2
		trail.Lifetime = 0.3
		trail.MinLength = 0.5
		trail.FaceCamera = true
		trail.Color = ColorSequence.new(Color3.fromRGB(200, 230, 255), Color3.fromRGB(150, 200, 240))
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 0.7),
			NumberSequenceKeypoint.new(1, 1)
		})
		trail.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(
				1,
				0.2
			) })
		trail.LightEmission = 0.15
		trail.Enabled = true
		trail.Parent = leftFoot
		table.insert(v17.trails, trail)
		local attachment3 = Instance.new("Attachment")
		attachment3.Name = "IceTrailAtt0_Other"
		attachment3.Position = createVector(0, -0.3, 0.3)
		attachment3.Parent = rightFoot
		table.insert(v17.attachments, attachment3)
		local attachment4 = Instance.new("Attachment")
		attachment4.Name = "IceTrailAtt1_Other"
		attachment4.Position = createVector(0, -0.3, -0.3)
		attachment4.Parent = rightFoot
		table.insert(v17.attachments, attachment4)
		local trail2 = Instance.new("Trail")
		trail2.Name = "IceBladeTrail_Other"
		trail2.Attachment0 = attachment3
		trail2.Attachment1 = attachment4
		trail2.Lifetime = 0.3
		trail2.MinLength = 0.5
		trail2.FaceCamera = true
		trail2.Color = ColorSequence.new(Color3.fromRGB(200, 230, 255), Color3.fromRGB(150, 200, 240))
		trail2.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 0.7),
			NumberSequenceKeypoint.new(1, 1)
		})
		trail2.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.6),
			NumberSequenceKeypoint.new(1, 0.2)
		})
		trail2.LightEmission = 0.15
		trail2.Enabled = true
		trail2.Parent = rightFoot
		table.insert(v17.trails, trail2)
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "SnowAttachment_Other"
	attachment.Position = createVector(0, 2, 0)
	attachment.Parent = humanoidRootPart
	table.insert(v17.attachments, attachment)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "SkatingSnow_Other"
	particleEmitter.Rate = 8
	particleEmitter.Lifetime = NumberRange.new(1.5, 2.5)
	particleEmitter.Speed = NumberRange.new(1, 3)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Texture = "rbxassetid://6490035152"
	particleEmitter.Color = ColorSequence.new(Color3.new(1, 1, 1))
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 0.05)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-30, 30)
	particleEmitter.EmissionDirection = Enum.NormalId.Top
	particleEmitter.Enabled = true
	particleEmitter.Parent = attachment
	table.insert(v17.particles, particleEmitter)
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "IceDustAttachment_Other"
	attachment2.Position = createVector(0, -2.5, 0)
	attachment2.Parent = humanoidRootPart
	table.insert(v17.attachments, attachment2)
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Name = "IceDust_Other"
	particleEmitter2.Rate = 15
	particleEmitter2.Lifetime = NumberRange.new(0.3, 0.6)
	particleEmitter2.Speed = NumberRange.new(2, 5)
	particleEmitter2.SpreadAngle = Vector2.new(60, 60)
	particleEmitter2.Texture = "rbxassetid://243098098"
	particleEmitter2.Color = ColorSequence.new(Color3.fromRGB(200, 230, 255))
	particleEmitter2.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0) })
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.LightEmission = 0.5
	particleEmitter2.EmissionDirection = Enum.NormalId.Top
	particleEmitter2.Enabled = true
	particleEmitter2.Parent = attachment2
	table.insert(v17.particles, particleEmitter2)
	v12[player] = v17
	debugPrint("[IceSkatingEffects] Created effects on", player.Name)
end

function IceSkatingEffects.RemoveEffectsFromOtherPlayer(p)
	local v17 = v12[p]

	if not v17 then
		return
	end

	debugPrint("[IceSkatingEffects] Removing effects from other player:", p.Name)

	for _, trail in ipairs(v17.trails) do
		if trail and trail.Parent then
			trail:Destroy()
		end
	end

	for _, particle in ipairs(v17.particles) do
		if particle and particle.Parent then
			particle:Destroy()
		end
	end

	for _, attachment in ipairs(v17.attachments) do
		if attachment and attachment.Parent then
			attachment:Destroy()
		end
	end

	v12[p] = nil
	debugPrint("[IceSkatingEffects] Removed effects from", p.Name)
end

local function watchPlayerForIceSkating(player)
	if player == v2.player or v13[player] then
		return
	end

	debugPrint("[IceSkatingEffects] Setting up watch for player:", player.Name)
	local v17 = {}

	local function setupCharacterWatch(character)
		if not character then
			debugPrint("[IceSkatingEffects] No character for", player.Name, "- skipping watch setup")
			return
		end

		debugPrint("[IceSkatingEffects] Setting up character watch for", player.Name, "- Character:", character.Name)
		local iceSkatingModeChangedConnection = character:GetAttributeChangedSignal("IceSkatingMode"):Connect(function()
			local iceSkatingMode = character:GetAttribute("IceSkatingMode")
			debugPrint(
				"[IceSkatingEffects] IceSkatingMode changed for",
				player.Name,
				"- Value:",
				(tostring(iceSkatingMode))
			)

			if iceSkatingMode then
				IceSkatingEffects.CreateEffectsOnOtherPlayer(player)
			else
				IceSkatingEffects.RemoveEffectsFromOtherPlayer(player)
			end
		end)
		table.insert(v17, iceSkatingModeChangedConnection)
		local iceSkatingMode = character:GetAttribute("IceSkatingMode")
		debugPrint("[IceSkatingEffects] Initial IceSkatingMode for", player.Name, ":", (tostring(iceSkatingMode)))

		if iceSkatingMode then
			IceSkatingEffects.CreateEffectsOnOtherPlayer(player)
		end
	end

	if player.Character then
		setupCharacterWatch(player.Character)
	else
		debugPrint("[IceSkatingEffects] Player", player.Name, "has no character yet - waiting for CharacterAdded")
	end

	table.insert(v17, (player.CharacterAdded:Connect(function(character)
		debugPrint("[IceSkatingEffects] CharacterAdded for", player.Name)
		IceSkatingEffects.RemoveEffectsFromOtherPlayer(player)
		task.wait(0.5)
		setupCharacterWatch(character)
	end)))
	v13[player] = v17
end

function IceSkatingEffects.StartWatchingOtherPlayers()
	if v13._main then
		debugPrint("[IceSkatingEffects] Already watching other players, skipping duplicate setup")
		return
	end

	local Players = game:GetService("Players")
	local players = Players:GetPlayers()
	debugPrint(
		"[IceSkatingEffects] StartWatchingOtherPlayers - Local player:",
		v2.player and v2.player.Name or "nil",
		"- Total players:",
		#players
	)

	for _, player in ipairs(players) do
		debugPrint("[IceSkatingEffects] Checking player:", player.Name, "- Is self:", (tostring(player == v2.player)))
		watchPlayerForIceSkating(player)
	end

	local main = { Players.PlayerAdded:Connect(function(player)
			debugPrint("[IceSkatingEffects] New player joined:", player.Name)
			watchPlayerForIceSkating(player)
		end), (Players.PlayerRemoving:Connect(function(player)
			IceSkatingEffects.RemoveEffectsFromOtherPlayer(player)
			local v18 = v13[player]

			if v18 then
				for _, connection2 in ipairs(v18) do
					if connection2 and connection2.Connected then
						connection2:Disconnect()
					end
				end

				v13[player] = nil
			end
		end)) }
	v13._main = main
	debugPrint("[IceSkatingEffects] Started watching other players for ice skating effects")
end

function IceSkatingEffects.StopWatchingOtherPlayers()
	for k, _ in pairs(v12) do
		IceSkatingEffects.RemoveEffectsFromOtherPlayer(k)
	end

	for _, v17 in pairs(v13) do
		if type(v17) ~= "table" then
			continue
		end

		for _, connection2 in ipairs(v17) do
			if connection2 and connection2.Connected then
				connection2:Disconnect()
			end
		end
	end

	v13 = {}
	IceSkatingEffects.StopWatchingTwisteds()
	debugPrint("[IceSkatingEffects] Stopped watching other players")
end

function IceSkatingEffects.CreateParticlesOnTwisted(instance)
	if not instance or v14[instance] then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	debugPrint("[IceSkatingEffects] Creating ice effects on Twisted:", instance.Name)
	local v17 = {
		particles = {}
	}
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "IceSparkles_Twisted"
	particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.Rate = 30
	particleEmitter.Lifetime = NumberRange.new(0.5, 1)
	particleEmitter.Speed = NumberRange.new(2, 5)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 240, 255))
	particleEmitter.LightEmission = 1
	particleEmitter.Size = NumberSequence.new(0.15, 0)
	particleEmitter.Enabled = true
	particleEmitter.Parent = humanoidRootPart
	table.insert(v17.particles, particleEmitter)
	debugPrint("[IceSkatingEffects] Ice sparkles created on", humanoidRootPart:GetFullName())
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Name = "IceDust_Twisted"
	particleEmitter2.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter2.Rate = 40
	particleEmitter2.Lifetime = NumberRange.new(0.3, 0.8)
	particleEmitter2.Speed = NumberRange.new(3, 8)
	particleEmitter2.SpreadAngle = Vector2.new(30, 30)
	particleEmitter2.Color = ColorSequence.new(Color3.fromRGB(220, 240, 255))
	particleEmitter2.LightEmission = 0.5
	particleEmitter2.Size = NumberSequence.new(0.3, 0.8)
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.EmissionDirection = Enum.NormalId.Top
	particleEmitter2.Enabled = true
	particleEmitter2.Parent = humanoidRootPart
	table.insert(v17.particles, particleEmitter2)
	debugPrint("[IceSkatingEffects] Ice dust (smoke) created on", humanoidRootPart:GetFullName())
	local particleEmitter3 = Instance.new("ParticleEmitter")
	particleEmitter3.Name = "SkatingSnow_Twisted"
	particleEmitter3.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter3.Rate = 8
	particleEmitter3.Lifetime = NumberRange.new(3, 5)
	particleEmitter3.Speed = NumberRange.new(2, 4)
	particleEmitter3.SpreadAngle = Vector2.new(180, 0)
	particleEmitter3.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	particleEmitter3.LightEmission = 0.8
	particleEmitter3.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0.15),
		NumberSequenceKeypoint.new(1, 0.05)
	})
	particleEmitter3.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter3.Rotation = NumberRange.new(0, 360)
	particleEmitter3.RotSpeed = NumberRange.new(-20, 20)
	particleEmitter3.EmissionDirection = Enum.NormalId.Bottom
	particleEmitter3.Enabled = true
	particleEmitter3.Parent = humanoidRootPart
	table.insert(v17.particles, particleEmitter3)
	debugPrint("[IceSkatingEffects] Snow particles created on", humanoidRootPart:GetFullName())
	v14[instance] = v17
	debugPrint("[IceSkatingEffects] Created ice effects on Twisted:", instance.Name, "- Particles:", #v17.particles)
end

local function findTwistedRootJoint(folder, instance)
	for _, motor6D in ipairs(folder:GetDescendants()) do
		if motor6D:IsA("Motor6D") and motor6D.Part0 == instance then
			return motor6D
		end
	end

	return nil
end

local function setupTwistedTilt(instance, humanoidRootPart)
	local twistedRootJoint = findTwistedRootJoint(instance, humanoidRootPart)

	if not twistedRootJoint then
		debugPrint("[IceSkatingEffects] No root Motor6D on", instance.Name, "- twisted tilt skipped")
		return
	end

	local v17 = v14[instance]

	if not v17 then
		v17 = {
			particles = {}
		}
		v14[instance] = v17
	end

	local C0 = twistedRootJoint.C0
	local maxTiltDegrees = v16.maxTiltDegrees or 12
	v17.rootJoint = twistedRootJoint
	v17.baseC0 = C0
	v17.tiltConn = RunService.RenderStepped:Connect(function()
		if not (twistedRootJoint.Parent and humanoidRootPart.Parent) then
			return
		end

		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		local vector2 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)

		if not (vector2.Magnitude > 5) then
			twistedRootJoint.C0 = twistedRootJoint.C0:Lerp(C0, 0.1)
			return
		end

		local lookVector = humanoidRootPart.CFrame.LookVector
		local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)

		if vector3.Magnitude < 0.01 then
			return
		end

		local v18 = math.clamp(
			-vector3.Unit:Cross(vector2.Unit).Y * maxTiltDegrees,
			-math.abs(maxTiltDegrees),
			(math.abs(maxTiltDegrees))
		)
		twistedRootJoint.C0 = twistedRootJoint.C0:Lerp(CFrame.Angles(0, 0, (math.rad(v18))) * C0, 0.15)
	end)
end

function IceSkatingEffects.RemoveParticlesFromTwisted(p)
	local v17 = v14[p]

	if not v17 then
		return
	end

	debugPrint("[IceSkatingEffects] Removing ice effects from Twisted:", p.Name)

	if v17.tiltConn then
		v17.tiltConn:Disconnect()
	end

	if v17.rootJoint and v17.rootJoint.Parent and v17.baseC0 then
		v17.rootJoint.C0 = v17.baseC0
	end

	if v17.trails then
		for _, trail in ipairs(v17.trails) do
			if trail and trail.Parent then
				trail:Destroy()
			end
		end
	end

	for _, particle in ipairs(v17.particles) do
		if particle and particle.Parent then
			particle:Destroy()
		end
	end

	if v17.attachments then
		for _, attachment in ipairs(v17.attachments) do
			if attachment and attachment.Parent then
				attachment:Destroy()
			end
		end
	end

	v14[p] = nil
	debugPrint("[IceSkatingEffects] Removed ice effects from Twisted:", p.Name)
end

local function setupTwistedParticles(instance)
	if v14[instance] then
		debugPrint("[IceSkatingEffects] setupTwistedParticles - Already have effects on", instance.Name)
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		debugPrint("[IceSkatingEffects] setupTwistedParticles - No HumanoidRootPart on", instance.Name)
		return
	end

	debugPrint("[IceSkatingEffects] setupTwistedParticles - Setting up effects on Twisted:", instance.Name)

	if v16.particles then
		IceSkatingEffects.CreateParticlesOnTwisted(instance)
	end

	if v16.tilt then
		setupTwistedTilt(instance, humanoidRootPart)
	end

	if not v14[instance] then
		return
	end

	local destroyingConnection = instance.Destroying:Connect(function()
		IceSkatingEffects.RemoveParticlesFromTwisted(instance)

		if v15[instance] then
			v15[instance]:Disconnect()
			v15[instance] = nil
		end
	end)
	v15[instance] = destroyingConnection
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getMonstersFolder()
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		return nil
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if model then
		return model:FindFirstChild("Monsters")
	end

	return nil
end

function IceSkatingEffects.StartWatchingTwisteds(p)
	if type(p) == "table" then
		v16 = p
	end

	if flag then
		debugPrint("[IceSkatingEffects] StartWatchingTwisteds - Already watching, skipping")
		return
	end

	flag = true
	debugPrint("[IceSkatingEffects] Starting to watch for Twisteds")
	local monstersFolder = getMonstersFolder() -- equivalent call inferred; original call site unknown

	if monstersFolder then
		debugPrint("[IceSkatingEffects] Found Monsters folder with", #monstersFolder:GetChildren(), "children")

		for _, model in ipairs(monstersFolder:GetChildren()) do
			if not model:IsA("Model") then
				continue
			end

			debugPrint("[IceSkatingEffects] Processing monster from folder:", model.Name)
			setupTwistedParticles(model)
		end

		local childAddedConnection = monstersFolder.ChildAdded:Connect(function(model)
			if model:IsA("Model") then
				debugPrint("[IceSkatingEffects] New monster added to folder:", model.Name)
				task.wait(0.2)
				setupTwistedParticles(model)
			end
		end)
		v15._folderAdded = childAddedConnection
	else
		debugPrint("[IceSkatingEffects] No Monsters folder found - will rely on CollectionService")
	end

	local tagged = CollectionService:GetTagged("Twisted")
	debugPrint("[IceSkatingEffects] Found", #tagged, "Twisteds via CollectionService tag")

	for _, v17 in ipairs(tagged) do
		debugPrint(
			"[IceSkatingEffects] Processing tagged Twisted:",
			v17.Name,
			"- Parent:",
			not v17.Parent and "nil" or v17.Parent.Name or "nil"
		)
		setupTwistedParticles(v17)
	end

	local connection2 = CollectionService:GetInstanceAddedSignal("Twisted"):Connect(function(p2)
		debugPrint("[IceSkatingEffects] New Twisted tagged via CollectionService:", p2.Name)
		setupTwistedParticles(p2)
	end)
	v15._tagAdded = connection2
	debugPrint("[IceSkatingEffects] Started watching for Twisteds - monitoring for new tags")
end

function IceSkatingEffects.StopWatchingTwisteds()
	if not flag then
		return
	end

	flag = false

	for k, _ in pairs(v14) do
		IceSkatingEffects.RemoveParticlesFromTwisted(k)
	end

	for _, connection2 in pairs(v15) do
		if connection2 and typeof(connection2) == "RBXScriptConnection" and connection2.Connected then
			connection2:Disconnect()
		end
	end

	v15 = {}
	debugPrint("[IceSkatingEffects] Stopped watching Twisteds")
end

local v17 = {
	active = false,
	leftIK = nil,
	rightIK = nil,
	connections = {}
}

function IceSkatingEffects.EnableArmsOut()
	if v17.active then
		debugPrint("[IceSkatingEffects] Arms Out already active")
		return true
	end

	if v2.armBalanceState then
		debugPrint("[IceSkatingEffects] Arm Balancing detected, disabling to enable Arms Out")
		IceSkatingEffects.SetArmBalancing(false)
	end

	local localPlayer = game.Players.LocalPlayer
	local character = localPlayer and localPlayer.Character

	if not character then
		warn("[IceSkatingEffects] EnableArmsOut: No character found")
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart) then
		warn("[IceSkatingEffects] EnableArmsOut: Missing humanoid or rootPart")
		return false
	end

	local bones = {}

	for _, bone in pairs(character:GetDescendants()) do
		if bone:IsA("Bone") then
			table.insert(bones, bone)
		end
	end

	local bone = nil
	local bone2 = nil

	for _, v18 in pairs(bones) do
		local name = v18.Name:lower()

		if bone or name ~= "lefthand" and name ~= "left_hand" and name ~= "l_hand" and name ~= "hand.l" then
			if not bone and name:find("left") and name:find("hand") then
				bone = v18
			end
		else
			bone = v18
		end

		if bone2 or name ~= "righthand" and name ~= "right_hand" and name ~= "r_hand" and name ~= "hand.r" then
			if not bone2 and name:find("right") and name:find("hand") then
				bone2 = v18
			end
		else
			bone2 = v18
		end
	end

	if not (bone and bone2) then
		warn("[IceSkatingEffects] EnableArmsOut: Could not find hand bones")
		return false
	end

	local function getParentOfParentBone(bone3)
		if not (bone3 and bone3:IsA("Bone")) then
			return nil
		end

		local parent = bone3.Parent

		if not (parent and parent:IsA("Bone")) then
			return nil
		end

		local parent2 = parent.Parent

		if parent2 and parent2:IsA("Bone") then
			return parent2
		end

		return nil
	end

	local parent

	if bone and bone:IsA("Bone") then
		local parent2 = bone.Parent

		if parent2 and parent2:IsA("Bone") then
			parent = parent2.Parent

			if not (parent and parent:IsA("Bone")) then
				parent = nil
			end
		end
	end

	local parent2

	if bone2 and bone2:IsA("Bone") then
		local parent3 = bone2.Parent

		if parent3 and parent3:IsA("Bone") then
			parent2 = parent3.Parent

			if not (parent2 and parent2:IsA("Bone")) then
				parent2 = nil
			end
		end
	end

	if not (parent and parent2) then
		warn("[IceSkatingEffects] EnableArmsOut: Could not find chain root bones")
		return false
	end

	local pointToObjectSpace = humanoidRootPart.CFrame:PointToObjectSpace(parent.WorldPosition)
	local pointToObjectSpace2 = humanoidRootPart.CFrame:PointToObjectSpace(parent2.WorldPosition)
	local magnitude = (bone.WorldPosition - parent.WorldPosition).Magnitude
	local magnitude2 = (bone2.WorldPosition - parent2.WorldPosition).Magnitude

	local function createArmIK(parent3, bone3, p, pointToObjectSpace3, magnitude3)
		local sideDir = p == "Left" and -1 or 1
		local attachment = Instance.new("Attachment")
		attachment.Name = "ArmsOutTarget_" .. p
		attachment.Parent = humanoidRootPart
		attachment.Position = pointToObjectSpace3 + Vector3.new(sideDir * magnitude3 * 0.4, magnitude3 * -0.05, 0)
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "ArmsOutPole_" .. p
		attachment2.Parent = humanoidRootPart
		attachment2.Position = pointToObjectSpace3 + Vector3.new(sideDir * 0.3, -0.3, -1)
		local iKControl = Instance.new("IKControl")
		iKControl.Name = "ArmsOutIK_" .. p
		iKControl.Type = Enum.IKControlType.Position
		iKControl.EndEffector = bone3
		iKControl.Target = attachment
		iKControl.ChainRoot = parent3
		iKControl.Pole = attachment2
		iKControl.Weight = 1
		iKControl.SmoothTime = 0.2
		iKControl.Enabled = true
		iKControl.Parent = humanoid
		return {
			ikControl = iKControl,
			targetAttachment = attachment,
			poleAttachment = attachment2,
			shoulderOffset = pointToObjectSpace3,
			armLength = magnitude3,
			sideDir = sideDir
		}
	end

	v17.leftIK = createArmIK(parent, bone, "Left", pointToObjectSpace, magnitude)
	v17.rightIK = createArmIK(parent2, bone2, "Right", pointToObjectSpace2, magnitude2)
	local lastTime = tick()
	local heartbeatConnection3 = RunService.Heartbeat:Connect(function(_)
		if not (v17.active and (humanoidRootPart and humanoidRootPart.Parent)) then
			return
		end

		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		local v18 = math.clamp(Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude / 20, 0, 1)
		local v19 = v18 * v18 * (3 - v18 * 2)
		local v20 = v19 * 0.5499999999999999 + 0.4
		local v21 = v19 * 0.3 + -0.05
		local v22 = tick() - lastTime
		local v23 = 1 - v19
		local v24 = (math.sin(v22 * 0.8) * 0.015 + math.sin(v22 * 1.4) * 0.01) * v23

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateArm(leftIK, p)
			if not (leftIK and leftIK.targetAttachment) then
				return
			end

			local shoulderOffset = leftIK.shoulderOffset
			local armLength = leftIK.armLength
			local sideDir = leftIK.sideDir
			leftIK.targetAttachment.Position = shoulderOffset + Vector3.new(
				sideDir * armLength * v20,
				armLength * v21 + v24 * p,
				0
			)
		end

		updateArm(v17.leftIK, 1) -- equivalent call inferred; original call site unknown
		local rightIK = v17.rightIK

		if rightIK then
			if not rightIK.targetAttachment then
				return
			end

			local shoulderOffset = rightIK.shoulderOffset
			local armLength = rightIK.armLength
			local sideDir = rightIK.sideDir
			rightIK.targetAttachment.Position = shoulderOffset + Vector3.new(
				sideDir * armLength * v20,
				armLength * v21 + v24 * 0.85,
				0
			)
		end
	end)
	table.insert(v17.connections, heartbeatConnection3)
	v17.active = true
	debugPrint("[IceSkatingEffects] Arms Out enabled - shoulder-relative IK")
	return true
end

function IceSkatingEffects.DisableArmsOut()
	if not v17.active then
		debugPrint("[IceSkatingEffects] Arms Out not active")
		return
	end

	for _, connection2 in ipairs(v17.connections) do
		if connection2 and connection2.Connected then
			connection2:Disconnect()
		end
	end

	v17.connections = {}

	if v17.leftIK then
		if v17.leftIK.ikControl then
			v17.leftIK.ikControl:Destroy()
		end

		if v17.leftIK.targetAttachment then
			v17.leftIK.targetAttachment:Destroy()
		end

		if v17.leftIK.poleAttachment then
			v17.leftIK.poleAttachment:Destroy()
		end

		v17.leftIK = nil
	end

	if v17.rightIK then
		if v17.rightIK.ikControl then
			v17.rightIK.ikControl:Destroy()
		end

		if v17.rightIK.targetAttachment then
			v17.rightIK.targetAttachment:Destroy()
		end

		if v17.rightIK.poleAttachment then
			v17.rightIK.poleAttachment:Destroy()
		end

		v17.rightIK = nil
	end

	v17.active = false
	debugPrint("[IceSkatingEffects] Arms Out disabled")
end

function IceSkatingEffects.IsArmsOutActive()
	return v17.active
end

function IceSkatingEffects.ToggleArmsOut()
	if not v17.active then
		return IceSkatingEffects.EnableArmsOut()
	end

	IceSkatingEffects.DisableArmsOut()
	return false
end

function IceSkatingEffects.SetVelocityEffects(velocityEffectsEnabled)
	if not v2.active then
		debugPrint("[IceSkatingEffects] Velocity effects toggle ignored - skating not active")
		return
	end

	v2.velocityEffectsEnabled = velocityEffectsEnabled

	if velocityEffectsEnabled then
		if not v2.velocityTrailConnection then
			local velocityTrailThreshold = v2.velocityTrailThreshold or 3
			local heartbeatConnection3 = RunService.Heartbeat:Connect(function()
				if not (v2.active and v2.rootPart) then
					return
				end

				local assemblyLinearVelocity = v2.rootPart.AssemblyLinearVelocity
				local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude
				local enabled = velocityTrailThreshold < magnitude

				for _, v19 in ipairs(v2.trails or {}) do
					if v19.leftTrail then
						v19.leftTrail.Enabled = enabled
					end

					if v19.rightTrail then
						v19.rightTrail.Enabled = enabled
					end

					if v19.sparkles then
						v19.sparkles.Enabled = enabled
					end

					if not v19.iceDust then
						continue
					end

					v19.iceDust.Enabled = enabled

					if enabled then
						v19.iceDust.Rate = math.min(60, magnitude * 3)
					end
				end
			end)
			v2.velocityTrailConnection = heartbeatConnection3
			table.insert(v2.connections, heartbeatConnection3)
			debugPrint("[IceSkatingEffects] Velocity Effects ENABLED - trails appear when moving")
		end
	else
		if v2.velocityTrailConnection then
			v2.velocityTrailConnection:Disconnect()
			v2.velocityTrailConnection = nil
		end

		for _, v18 in ipairs(v2.trails or {}) do
			if v18.leftTrail then
				v18.leftTrail.Enabled = true
			end

			if v18.rightTrail then
				v18.rightTrail.Enabled = true
			end

			if v18.sparkles then
				v18.sparkles.Enabled = true
			end

			if not v18.iceDust then
				continue
			end

			v18.iceDust.Enabled = true
			v18.iceDust.Rate = 40
		end

		debugPrint("[IceSkatingEffects] Velocity Effects DISABLED - trails always visible")
	end
end

function IceSkatingEffects.GetVelocityEffects()
	return v2.velocityEffectsEnabled or false
end

function IceSkatingEffects.SetVelocityTrailThreshold(velocityTrailThreshold)
	v2.velocityTrailThreshold = velocityTrailThreshold
	debugPrint("[IceSkatingEffects] Velocity trail threshold set to:", velocityTrailThreshold)
end

function IceSkatingEffects.GetVelocityTrailThreshold()
	return v2.velocityTrailThreshold or 3
end

return IceSkatingEffects