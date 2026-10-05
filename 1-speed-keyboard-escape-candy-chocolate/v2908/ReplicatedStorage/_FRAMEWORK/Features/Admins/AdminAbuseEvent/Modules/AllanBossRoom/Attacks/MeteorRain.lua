local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)
require(script.Parent)
local Config = require(script.Parent.Parent.Config)
local color = Color3.fromRGB(120, 90, 200)
local color2 = Color3.fromRGB(255, 45, 45)
local color3 = Color3.fromRGB(201, 94, 36)
local color4 = Color3.fromRGB(150, 95, 235)
local color5 = Color3.fromRGB(201, 94, 36)

local function getRandomPositionInZone(instance)
	local v = instance.Size * 0.5
	local v2 = (math.random() * 2 - 1) * math.max(0, v.X - 4)
	local v3 = (math.random() * 2 - 1) * math.max(0, v.Z - 4)
	return (instance.CFrame * CFrame.new(v2, -v.Y, v3)).Position
end

local function isLocalPlayerHit(position: Vector3, impactRadius: number)
	local localPlayer = Players.LocalPlayer
	local character

	if localPlayer then
		character = localPlayer.Character
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
		return false
	end

	local v = humanoidRootPart.Position - position
	return Vector2.new(v.X, v.Z).Magnitude <= impactRadius
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeTrackedVisual(instance, list)
	local index = table.find(list, instance)

	if index then
		table.remove(list, index)
	end

	instance:Destroy()
end

local function createTelegraphPart(name: string, vector2: Vector3, p: number, transparency: number, p2: number, list)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color2
	part.Transparency = transparency
	part.Size = Vector3.new(0.1, p, p)
	part.CFrame = CFrame.new(vector2 + Vector3.new(0, p2, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Parent = Workspace
	table.insert(list, part)
	return part
end

local function createImpactTelegraph(position: Vector3, impactRadius: number, fallDurationSeconds: number, clones)
	local v = impactRadius * 2
	local telegraphPart = createTelegraphPart("MeteorRainImpactBoundary", position, v, 0.82, 0.58, clones)
	local telegraphPart2 = createTelegraphPart("MeteorRainImpactFill", position, 0.1, 0.35, 0.62, clones)
	TweenService:Create(telegraphPart2, TweenInfo.new(fallDurationSeconds, Enum.EasingStyle.Linear), {
		Size = Vector3.new(0.1, v, v)
	}):Play()
	return { telegraphPart, telegraphPart2 }
end

local function destroyImpactTelegraph(items, list)
	for _, item in items do
		removeTrackedVisual(item, list) -- equivalent call inferred; original call site unknown
	end
end

local function createImpact(position: Vector3, impactRadius: number, clones)
	local part = Instance.new("Part")
	part.Name = "AllanBossRoomMeteorSplashFx"
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.35
	part.Size = createVector(0.15, 0.6, 0.6)
	part.CFrame = CFrame.new(position + createVector(0, 0.1, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Parent = Workspace
	table.insert(clones, part)
	local tween = TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.15, impactRadius * 1.6, impactRadius * 1.6),
		Transparency = 1
	})
	tween.Completed:Once(function()
		removeTrackedVisual(part, clones) -- equivalent call inferred; original call site unknown
	end)
	tween:Play()
end

local function createExplosion(position: Vector3, impactRadius: number, clones)
	local part = Instance.new("Part")
	part.Name = "AllanBossRoomMeteorExplosionFx"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(position + createVector(0, 1, 0))
	part.Parent = Workspace
	table.insert(clones, part)
	local part2 = Instance.new("Part")
	part2.Name = "Flash"
	part2.Shape = Enum.PartType.Ball
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.CastShadow = false
	part2.Material = Enum.Material.Neon
	part2.Color = color3
	part2.Transparency = 0.05
	part2.Size = Vector3.new(impactRadius * 0.4, impactRadius * 0.4, impactRadius * 0.4)
	part2.CFrame = part.CFrame
	part2.Parent = part
	TweenService:Create(part2, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = Vector3.new(impactRadius * 1.6, impactRadius * 1.6, impactRadius * 1.6),
		Transparency = 1
	}):Play()
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color3
	pointLight.Brightness = 8
	pointLight.Range = impactRadius * 2.5
	pointLight.Shadows = false
	pointLight.Parent = part2
	TweenService:Create(pointLight, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		Brightness = 0
	}):Play()
	local part3 = Instance.new("Part")
	part3.Name = "Shockwave"
	part3.Shape = Enum.PartType.Cylinder
	part3.Anchored = true
	part3.CanCollide = false
	part3.CanQuery = false
	part3.CanTouch = false
	part3.CastShadow = false
	part3.Material = Enum.Material.Neon
	part3.Color = color3
	part3.Transparency = 0.2
	part3.Size = Vector3.new(0.1, impactRadius * 0.3, impactRadius * 0.3)
	part3.CFrame = CFrame.new(position + createVector(0, 0.3, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
	part3.Parent = part
	TweenService:Create(part3, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.1, impactRadius * 2.6, impactRadius * 2.6),
		Transparency = 1
	}):Play()
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "Embers"
	particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.Color = ColorSequence.new(color4)
	particleEmitter.LightEmission = 0.8
	particleEmitter.LightInfluence = 0
	particleEmitter.Orientation = Enum.ParticleOrientation.FacingCamera
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, impactRadius * 0.12),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.35, 0.7)
	particleEmitter.Speed = NumberRange.new(impactRadius * 1.5, impactRadius * 3.5)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Drag = 5
	particleEmitter.Acceleration = createVector(0, -70, 0)
	particleEmitter.Rate = 0
	particleEmitter.Enabled = false
	particleEmitter.Parent = part
	particleEmitter:Emit(50)
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Name = "Smoke"
	particleEmitter2.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter2.Color = ColorSequence.new(color5)
	particleEmitter2.LightInfluence = 1
	particleEmitter2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, impactRadius * 0.4),
		NumberSequenceKeypoint.new(1, impactRadius * 1.1)
	})
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(0.2, 0.55),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.Lifetime = NumberRange.new(0.7, 1.3)
	particleEmitter2.Speed = NumberRange.new(impactRadius * 0.4, impactRadius * 1.1)
	particleEmitter2.SpreadAngle = Vector2.new(90, 90)
	particleEmitter2.Drag = 3
	particleEmitter2.Acceleration = createVector(0, 8, 0)
	particleEmitter2.Rate = 0
	particleEmitter2.Enabled = false
	particleEmitter2.Parent = part
	particleEmitter2:Emit(14)
	task.delay(2.5, function()
		removeTrackedVisual(part, clones) -- equivalent call inferred; original call site unknown
	end)
end

local function playGroundImpact(position: Vector3, clones)
	local potentialInstance = InstanceUtils.getPotentialInstance(
		ReplicatedStorage,
		"AdminAbuse/AllanBossRoom/SFX/MeteorImpact"
	)

	if not potentialInstance then
		return
	end

	local part = Instance.new("Part")
	part.Name = "MeteorRainGroundImpactSound"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.CFrame = CFrame.new(position)
	part.Parent = Workspace
	table.insert(clones, part)
	local clone = potentialInstance:Clone()
	clone.Looped = false
	clone.Parent = part
	clone.Ended:Once(function()
		removeTrackedVisual(part, clones) -- equivalent call inferred; original call site unknown
	end)
	clone:Play()
end

return {
	new = function(configIndex: number, callback, callback2, callback3, callback4)
		local v = assert(
			Config.meteorRainAttackConfigs[configIndex],
			"AllanBossRoom MeteorRain: no attack config for this phase index"
		)
		local durationSeconds = (v.dropCount - 1) * v.dropIntervalSeconds + v.fallDurationSeconds + v.recoverySeconds
		local count = 0
		local v3 = false
		local clones = {}
		local v4 = {}

		local function resolveMaturedImpacts(p2: number)
			local v5 = 1

			while v5 <= #v4 do
				local v6 = v4[v5]

				if v6.dueAt <= p2 then
					table.remove(v4, v5)

					if not v3 then
						callback2(v6.position)
					end
				else
					v5 += 1
				end
			end
		end

		return {
			name = "MeteorRain",
			durationSeconds = durationSeconds,
			startServer = function(_, _)
				count = 0
				table.clear(v4)
			end,
			updateServer = function(p2: number, p3, callback5)
				local v5 = math.min(v.dropCount, math.floor(p2 / v.dropIntervalSeconds) + 1)

				while count < v5 do
					count += 1
					local v6

					if math.random() < v.bridgeHitChance then
						v6 = callback4()
					end

					local position = v6 or getRandomPositionInZone(callback3() or p3)
					table.insert(v4, {
						dueAt = p2 + v.fallDurationSeconds,
						position = position
					})
					callback5({
						kind = "BossAttack",
						attack = "MeteorRain",
						action = "Drop",
						position = position,
						configIndex = configIndex
					})
				end

				resolveMaturedImpacts(p2)
			end,
			handleServerEvent = function(data)
				if v3 or typeof(data) ~= "table" or (data.action ~= "Drop" or typeof(data.position) ~= "Vector3") then
					return
				end

				local meteorRainAttackConfig = Config.meteorRainAttackConfigs[data.configIndex]

				if not meteorRainAttackConfig then
					return
				end

				local potentialInstance = InstanceUtils.getPotentialInstance(
					ReplicatedStorage,
					"AdminAbuse/AllanBossRoom/Assets/Attacks/MeteorRain/Projectile"
				)

				if not potentialInstance then
					warn("[AllanBossRoom] MeteorRain: projectile template not found at 'AdminAbuse/AllanBossRoom/Assets/Attacks/MeteorRain/Projectile'")
					return
				end

				local clone = potentialInstance:Clone()
				clone.PrimaryPart = InstanceUtils.getPotentialInstance(clone, "Root")
				local cframe = CFrame.new(data.position)
				local v5 = cframe + Vector3.new(0, meteorRainAttackConfig.fallHeight, 0)
				clone:PivotTo(v5)
				clone.Parent = Workspace
				table.insert(clones, clone)
				local impactTelegraph = createImpactTelegraph(
					data.position,
					meteorRainAttackConfig.impactRadius,
					meteorRainAttackConfig.fallDurationSeconds,
					clones
				)
				local cFrameValue = Instance.new("CFrameValue")
				cFrameValue.Value = v5
				cFrameValue.Parent = clone
				local valueChangedConnection = cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
					if clone.Parent then
						clone:PivotTo(cFrameValue.Value)
					end
				end)
				local tween = TweenService:Create(
					cFrameValue,
					TweenInfo.new(
						meteorRainAttackConfig.fallDurationSeconds,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.In
					),
					{
						Value = cframe
					}
				)
				tween.Completed:Once(function()
					valueChangedConnection:Disconnect()
					local v6 = clones

					for _, v7 in impactTelegraph do
						removeTrackedVisual(v7, v6) -- equivalent call inferred; original call site unknown
					end

					if not v3 and isLocalPlayerHit(data.position, meteorRainAttackConfig.impactRadius) then
						callback()
					end

					removeTrackedVisual(clone, clones) -- equivalent call inferred; original call site unknown

					if not v3 then
						createImpact(data.position, meteorRainAttackConfig.impactRadius, clones)
						createExplosion(data.position, meteorRainAttackConfig.impactRadius, clones)
						playGroundImpact(data.position, clones)
					end
				end)
				tween:Play()
			end,
			cleanup = function()
				v3 = true
				table.clear(v4)
				local clone = table.clone(clones)
				table.clear(clones)

				for _, v5 in clone do
					v5:Destroy()
				end
			end
		}
	end
}