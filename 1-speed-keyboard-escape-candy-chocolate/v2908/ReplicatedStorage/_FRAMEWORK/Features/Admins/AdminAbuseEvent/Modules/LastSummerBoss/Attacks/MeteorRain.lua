local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)
local Config = require(script.Parent.Parent.Config)
local color = Color3.fromRGB(255, 140, 40)
local color2 = Color3.fromRGB(255, 45, 45)

local function getRandomSurfacePosition(instance)
	local v = {
		{
			direction = instance.CFrame.RightVector,
			size = instance.Size.X
		},
		{
			direction = instance.CFrame.UpVector,
			size = instance.Size.Y
		},
		{
			direction = instance.CFrame.LookVector,
			size = instance.Size.Z
		}
	}
	table.sort(v, function(a, b)
		return math.abs(a.direction.Y) < math.abs(b.direction.Y)
	end)
	local v2 = v[1]
	local v3 = v[2]
	local v4 = v[3]
	local v5 = v2.size * 0.5
	local v6 = v3.size * 0.5
	local v7 = math.max(0, (math.min(4, v5 - 1, v6 - 1)))
	local v8 = (math.random() * 2 - 1) * (v5 - v7)
	local v9 = (math.random() * 2 - 1) * (v6 - v7)
	local v10

	if v4.direction.Y >= 0 then
		v10 = v4.direction
	else
		v10 = -v4.direction
	end

	return instance.Position + v2.direction * v8 + v3.direction * v9 + v10 * (v4.size * 0.5)
end

local function setProjectileCFrame(instance, cframe: CFrame)
	instance:PivotTo(cframe)
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
	part.Name = "LastSummerBossMeteorSplashFx"
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

local function playGroundImpact(position: Vector3, clones)
	local potentialInstance = InstanceUtils.getPotentialInstance(
		ReplicatedStorage,
		"AdminAbuse/LastSummerBoss/SFX/MeteorImpact"
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
	new = function(configIndex: number, callback)
		local meteorRainAttackConfig = Config.meteorRainAttackConfigs[configIndex]
		assert(meteorRainAttackConfig, (`MeteorRain config index {configIndex} does not exist`))
		local v

		if meteorRainAttackConfig.dropCount > 0 then
			v = meteorRainAttackConfig.dropCount % 1 == 0
		else
			v = false
		end

		assert(v, "MeteorRain dropCount must be a positive integer")
		assert(meteorRainAttackConfig.dropIntervalSeconds > 0, "MeteorRain dropIntervalSeconds must be positive")
		assert(meteorRainAttackConfig.fallHeight > 0, "MeteorRain fallHeight must be positive")
		assert(meteorRainAttackConfig.fallDurationSeconds > 0, "MeteorRain fallDurationSeconds must be positive")
		assert(meteorRainAttackConfig.impactRadius > 0, "MeteorRain impactRadius must be positive")
		assert(meteorRainAttackConfig.recoverySeconds >= 0, "MeteorRain recoverySeconds must be non-negative")
		assert(type(callback) == "function", "MeteorRain requires an onLocalHit callback")
		local count = 0
		local clones = {}
		local v3 = false
		return {
			name = "MeteorRain",
			durationSeconds = (meteorRainAttackConfig.dropCount - 1) * meteorRainAttackConfig.dropIntervalSeconds + meteorRainAttackConfig.fallDurationSeconds + meteorRainAttackConfig.recoverySeconds,
			startServer = function(_, _)
				count = 0
			end,
			updateServer = function(p2: number, p3, callback2)
				local v4 = math.min(
					meteorRainAttackConfig.dropCount,
					math.floor(p2 / meteorRainAttackConfig.dropIntervalSeconds) + 1
				)

				while count < v4 do
					count += 1
					callback2({
						kind = "BossAttack",
						attack = "MeteorRain",
						action = "Drop",
						position = getRandomSurfacePosition(p3),
						configIndex = configIndex
					})
				end
			end,
			handleServerEvent = function(data)
				if v3 or typeof(data) ~= "table" then
					return
				end

				if data.kind ~= "BossAttack" or data.attack ~= "MeteorRain" or data.action ~= "Drop" or typeof(data.position) ~= "Vector3" or type(data.configIndex) ~= "number" then
					return
				end

				local meteorRainAttackConfig2 = Config.meteorRainAttackConfigs[data.configIndex]

				if not meteorRainAttackConfig2 then
					return
				end

				local potentialInstance = InstanceUtils.getPotentialInstance(
					ReplicatedStorage,
					"AdminAbuse/LastSummerBoss/Assets/Attacks/MeteorRain/Projectile"
				)

				if not potentialInstance then
					warn("[LastSummerBoss] MeteorRain: projectile template not found at 'AdminAbuse/LastSummerBoss/Assets/Attacks/MeteorRain/Projectile'")
					return
				end

				local clone = potentialInstance:Clone()
				clone.PrimaryPart = InstanceUtils.getPotentialInstance(clone, "Root")
				local cframe = CFrame.new(data.position)
				local v4 = cframe + Vector3.new(0, meteorRainAttackConfig2.fallHeight, 0)
				clone:PivotTo(v4)
				clone.Parent = Workspace
				table.insert(clones, clone)
				local impactTelegraph = createImpactTelegraph(
					data.position,
					meteorRainAttackConfig2.impactRadius,
					meteorRainAttackConfig2.fallDurationSeconds,
					clones
				)
				local cFrameValue = Instance.new("CFrameValue")
				cFrameValue.Value = v4
				cFrameValue.Parent = clone
				local valueChangedConnection = cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
					if clone.Parent then
						clone:PivotTo(cFrameValue.Value)
					end
				end)
				local tween = TweenService:Create(
					cFrameValue,
					TweenInfo.new(
						meteorRainAttackConfig2.fallDurationSeconds,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.In
					),
					{
						Value = cframe
					}
				)
				tween.Completed:Once(function()
					valueChangedConnection:Disconnect()
					local v5 = clones

					for _, v6 in impactTelegraph do
						removeTrackedVisual(v6, v5) -- equivalent call inferred; original call site unknown
					end

					if not v3 and isLocalPlayerHit(data.position, meteorRainAttackConfig2.impactRadius) then
						callback()
					end

					removeTrackedVisual(clone, clones) -- equivalent call inferred; original call site unknown

					if not v3 then
						createImpact(data.position, meteorRainAttackConfig2.impactRadius, clones)
						playGroundImpact(data.position, clones)
					end
				end)
				tween:Play()
			end,
			cleanup = function()
				v3 = true
				local clone = table.clone(clones)
				table.clear(clones)

				for _, v4 in clone do
					v4:Destroy()
				end
			end
		}
	end
}