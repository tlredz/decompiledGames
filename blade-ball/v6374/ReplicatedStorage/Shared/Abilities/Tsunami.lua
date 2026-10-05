local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local Debris = game:GetService("Debris")
game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Shared.SpeedModifiers)
local v2

if RunService:IsServer() then
	v2 = require3(game.ServerScriptService.Game.CoreGameModules.MapManager)
else
	v2 = nil
end

local tsunamiHit = script:WaitForChild("TsunamiHit")
local color = Color3.fromRGB(36, 172, 255)
local color2 = Color3.fromRGB(95, 218, 255)
local v3 = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = {
	workspace.Alive,
	workspace.Balls,
	workspace.Dead,
	workspace.TrainingBalls,
	workspace.Runtime
}

local function getConfig(upgradeLevel: number)
	local v4 = upgradeLevel >= 1
	return {
		duration = v4 and 16 or 14,
		baseRadius = 18,
		maxRadius = v4 and 88 or 70,
		waveRadius = v4 and 22 or 18,
		waveRange = v4 and 150 or 95,
		waveStep = 14,
		waveDelay = 0.052,
		playerSlowMultiplier = v4 and 0.42 or 0.52,
		playerSlowDuration = v4 and 2.8 or 2.2,
		ownerSpeedMultiplier = v4 and 1 or 0.82,
		passiveBallSlowMultiplier = v4 and 0.72 or 0.82,
		waveBallSlowMultiplier = v4 and 0.55 or 0.68,
		ballReboundMinSpeed = v4 and 400 or 200,
		ballReboundMultiplier = v4 and 4 or 2,
		ballReboundDuration = v4 and 1 or 1.5
	}
end

local function getMaxUses(p: number)
	return (p >= 1 and 1 or 0) + 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getFlatDirection(vector2: Vector3)
	local vector3 = Vector3.new(vector2.X, 0, vector2.Z)

	if vector3.Magnitude < 0.001 then
		return createVector(0, 0, 1)
	end

	return vector3.Unit
end

local function unpackDirection(list)
	if typeof(list) ~= "table" then
		return nil
	end

	local v4 = list[1]
	local v5 = list[2]

	if type(v4) ~= "number" or type(v5) ~= "number" then
		return nil
	end

	local vector2 = Vector3.new(v4, 0, v5)
	local vector3 = Vector3.new(vector2.X, 0, vector2.Z)

	if vector3.Magnitude < 0.001 then
		return createVector(0, 0, 1)
	end

	return vector3.Unit
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getGroundPosition(vector2: Vector3)
	local raycastResult = workspace:Raycast(vector2 + createVector(0, 8, 0), createVector(-0, -80, -0), raycastParams)

	if raycastResult then
		return raycastResult.Position + createVector(0, 0.12, 0)
	end

	return vector2 - createVector(0, 2.8, 0)
end

local function getBoundsFrom(folder)
	local vector2 = nil
	local vector3 = nil

	local function includePart(part)
		if not part:IsA("BasePart") then
			return
		end

		local v4 = part.Size * 0.5
		local v5 = part.Position - v4
		local v6 = part.Position + v4

		if vector2 and vector3 then
			vector2 = Vector3.new(math.min(vector2.X, v5.X), math.min(vector2.Y, v5.Y), (math.min(vector2.Z, v5.Z)))
			vector3 = Vector3.new(math.max(vector3.X, v6.X), math.max(vector3.Y, v6.Y), (math.max(vector3.Z, v6.Z)))
		else
			vector2 = v5
			vector3 = v6
		end
	end

	includePart(folder)

	for _, descendant in folder:GetDescendants() do
		includePart(descendant)
	end

	return vector2, vector3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getMapBorders()
	local map = workspace:FindFirstChild("Map")

	if map then
		return map:FindFirstChild("Borders", true) or map:FindFirstChild("Border", true)
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isFloorPart(part)
	if part:IsA("BasePart") then
		return part.Name == "FLOOR" or part.Name == "BallFloor" or part.CollisionGroup == "MapFloor" or part.CollisionGroup == "BallFloor"
	end

	return false
end

local function getBorderRaycastInstances()
	local mapBorders = getMapBorders() -- equivalent call inferred; original call site unknown

	if not mapBorders then
		return {}
	end

	local result = {}

	if mapBorders:IsA("BasePart") then
		-- equivalent call inferred; original call site unknown
		if not isFloorPart(mapBorders) then
			table.insert(result, mapBorders)
			return result
		end
	else
		for _, part in mapBorders:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			-- equivalent call inferred; original call site unknown
			if not isFloorPart(part) then
				table.insert(result, part)
			end
		end
	end

	return result
end

local function getMapBounds()
	local map = workspace:FindFirstChild("Map")

	if not map then
		return nil, nil
	end

	local mapBorders = getMapBorders() -- equivalent call inferred; original call site unknown

	if mapBorders then
		local boundsFrom, v4 = getBoundsFrom(mapBorders)

		if boundsFrom and v4 then
			return boundsFrom, v4
		end
	end

	return getBoundsFrom(map)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function raycastToMapBorder(vector2: Vector3, vector3: Vector3, p: number)
	local borderRaycastInstances = getBorderRaycastInstances()

	if #borderRaycastInstances <= 0 then
		return nil
	end

	local raycastParams2 = RaycastParams.new()
	raycastParams2.FilterType = Enum.RaycastFilterType.Include
	raycastParams2.FilterDescendantsInstances = borderRaycastInstances
	raycastParams2.IgnoreWater = true
	raycastParams2.RespectCanCollide = true
	return workspace:Raycast(vector2, vector3 * p, raycastParams2)
end

local function getWaveTravelRange(position: Vector3, vector2: Vector3, waveRange: number)
	local raycastResult = raycastToMapBorder(position, vector2, waveRange) -- equivalent call inferred; original call site unknown

	if raycastResult then
		return (math.max(0, raycastResult.Distance))
	end

	local map = workspace:FindFirstChild("Map")
	local v4, v5

	if map then
		local mapBorders = getMapBorders() -- equivalent call inferred; original call site unknown

		if mapBorders then
			v4, v5 = getBoundsFrom(mapBorders)

			if not (v4 and v5) then
				v4, v5 = getBoundsFrom(map)
			end
		else
			v4, v5 = getBoundsFrom(map)
		end
	end

	if not (v4 and v5) then
		return waveRange
	end

	local v6 = 1e999

	if math.abs(vector2.X) > 0.001 then
		local v7

		if vector2.X > 0 then
			v7 = v5.X
		else
			v7 = v4.X
		end

		local v8 = (v7 - position.X) / vector2.X

		if v8 > 0 then
			v6 = math.min(v6, v8)
		end
	end

	if math.abs(vector2.Z) > 0.001 then
		local v7

		if vector2.Z > 0 then
			v7 = v5.Z
		else
			v7 = v4.Z
		end

		local v8 = (v7 - position.Z) / vector2.Z

		if v8 > 0 then
			v6 = math.min(v6, v8)
		end
	end

	if v6 == 1e999 then
		return waveRange
	end

	return (math.max(0, v6))
end

local function createWaveRing(vector2: Vector3, p: number, duration: number, color3: Color3)
	local clone = ReplicatedStorage2.Misc.Wave:Clone()
	clone.Name = "TsunamiWave"
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.Color = color3
	clone.Transparency = 0.12
	clone.Size = createVector(0.01, 0.5, 0.01)
	local groundPosition = getGroundPosition(vector2) -- equivalent call inferred; original call site unknown
	clone.CFrame = CFrame.new(groundPosition)
	clone.Parent = workspace.Runtime
	TweenService:Create(clone, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(p, 0.5, p),
		Transparency = 1
	}):Play()
	Debris:AddItem(clone, duration + 0.2)
end

local function getCurrentBalls()
	if RunService:IsServer() and v2 then
		return v2.getCurrentBalls()
	end

	return workspace.Balls:GetChildren()
end

local function isBallAlive(value)
	if typeof(value) == "Instance" then
		return value.Parent ~= nil
	end

	return type(value) == "table" and value._physical ~= nil and value._physical.Parent ~= nil
end

local function getBallPrimaryPart(part)
	if typeof(part) == "Instance" then
		local primaryPart = part.PrimaryPart

		if primaryPart and primaryPart:IsA("BasePart") then
			return primaryPart
		end

		local body = part:FindFirstChild("Body")

		if body and body:IsA("BasePart") then
			return body
		end

		local collider = part:FindFirstChild("Collider")

		if collider and collider:IsA("BasePart") then
			return collider
		end

		if part:IsA("BasePart") then
			return part
		end

		return part:FindFirstChildWhichIsA("BasePart", true)
	elseif type(part) == "table" and typeof(part._physical) == "Instance" and part._physical:IsA("BasePart") then
		return part._physical
	else
		return nil
	end
end

local function getBallSpeed(value)
	if typeof(value) == "Instance" then
		if not value:FindFirstChild("GetSpeed") then
			return nil
		end

		local success, result = pcall(function()
			return value.GetSpeed:Invoke()
		end)

		if success and type(result) == "number" then
			return result
		end

		return nil
	elseif type(value) == "table" then
		return value.temporarySpeedOverride or value.currentSpeed
	else
		return nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setBallSpeed(value, temporarySpeedOverride: number)
	if typeof(value) == "Instance" then
		if value:FindFirstChild("SetSpeed") then
			value.SetSpeed:Invoke(temporarySpeedOverride)
		end
	elseif type(value) == "table" then
		value.temporarySpeedOverride = temporarySpeedOverride
		value.tempSlow = 0
	end
end

local function slowBall(value, p: number, p2: number?)
	local v4

	if typeof(value) == "Instance" then
		v4 = value.Parent ~= nil
	elseif type(value) == "table" and value._physical ~= nil then
		v4 = value._physical.Parent ~= nil
	else
		v4 = false
	end

	if not v4 then
		return
	end

	local ballSpeed = getBallSpeed(value)

	if type(ballSpeed) ~= "number" then
		return
	end

	if typeof(value) == "Instance" or type(value) ~= "table" then
		local v5 = ballSpeed * p

		if p2 then
			v5 = math.max(v5, p2)
		end

		setBallSpeed(value, v5) -- equivalent call inferred; original call site unknown
	else
		local temporarySpeedOverride = (value.currentSpeed or ballSpeed) * p

		if p2 then
			temporarySpeedOverride = math.max(temporarySpeedOverride, p2)
		end

		value.temporarySpeedOverride = temporarySpeedOverride
		value.tempSlow = 0
		local tsunamiSlowToken = (value._tsunamiSlowToken or 0) + 1
		value._tsunamiSlowToken = tsunamiSlowToken
		task.delay(0.9, function()
			if value._tsunamiSlowToken == tsunamiSlowToken and value.temporarySpeedOverride == temporarySpeedOverride then
				value.temporarySpeedOverride = nil
			end
		end)
	end
end

local function getBarrierTurnDelay(vector2: Vector3, vector3: Vector3, p: number, p2: number)
	local raycastResult = raycastToMapBorder(vector2, vector3, 4096) -- equivalent call inferred; original call site unknown

	if raycastResult and not (p <= 0) then
		return (math.clamp(raycastResult.Distance / p, 0.06, p2 * 0.7))
	end

	return p2 * 0.45
end

local function reboundLegacyBallTowardCaster(state, p, vector2: Vector3, temporarySpeedOverride: number, data)
	local ballPrimaryPart = getBallPrimaryPart(state)

	if not ballPrimaryPart then
		return
	end

	local returnSpeed = temporarySpeedOverride * 0.55
	local raycastResult = raycastToMapBorder(ballPrimaryPart.Position, vector2, 4096) -- equivalent call inferred; original call site unknown
	local position2

	if raycastResult then
		position2 = raycastResult.Position
	else
		position2 = ballPrimaryPart.Position + vector2 * data.waveRange
	end

	local magnitude = (position2 - ballPrimaryPart.Position).Magnitude
	local v5 = math.clamp(magnitude / math.max(temporarySpeedOverride, 1) * 2, 0.2, data.ballReboundDuration * 3) + 0.35
	state.From = p.player
	state.Target = nil
	state.TsunamiOriginalSpeed = state.TsunamiOriginalSpeed or state.currentSpeed
	state.temporarySpeedOverride = temporarySpeedOverride
	state.tempSlow = 0
	state.targetCFrame = CFrame.lookAt(ballPrimaryPart.Position, ballPrimaryPart.Position + vector2)
	state.LastReflectTick = tick()
	state.TsunamiBlockFury = true
	state.TsunamiWallRebound = {
		wallUntil = workspace:GetServerTimeNow() + v5,
		wallStartedAt = workspace:GetServerTimeNow(),
		wallStartPosition = ballPrimaryPart.Position,
		wallDirection = vector2,
		wallSpeed = temporarySpeedOverride,
		wallTargetPosition = position2,
		wallBlockDistance = math.clamp(magnitude * 0.18, 8, 22),
		overshoot = data.ballReboundOvershoot or 8,
		returnTarget = p.player,
		returnSpeed = returnSpeed,
		originalSpeed = state.TsunamiOriginalSpeed
	}
	local zoomies = ballPrimaryPart:FindFirstChild("zoomies")

	if zoomies and zoomies:IsA("LinearVelocity") then
		zoomies.VectorVelocity = vector2 * temporarySpeedOverride
	end
end

local function reboundBallTowardCaster(value, p, vector2: Vector3, data)
	local v4

	if typeof(value) == "Instance" then
		v4 = value.Parent ~= nil
	elseif type(value) == "table" and value._physical ~= nil then
		v4 = value._physical.Parent ~= nil
	else
		v4 = false
	end

	if not v4 then
		return
	end

	local ballSpeed = getBallSpeed(value)

	if type(ballSpeed) ~= "number" then
		return
	end

	local v5 = math.max(ballSpeed * data.ballReboundMultiplier, data.ballReboundMinSpeed)
	local ballPrimaryPart = getBallPrimaryPart(value)
	local v6

	if ballPrimaryPart then
		v6 = ballPrimaryPart.Position
	else
		v6 = p.rootPart.Position
	end

	local v7 = v6 - p.rootPart.Position

	if v7.Magnitude > 1 then
		vector2 = getFlatDirection(v7)
	end

	if typeof(value) ~= "Instance" then
		reboundLegacyBallTowardCaster(value, p, vector2, v5, data)
		return
	end

	local targetCharacter = value:FindFirstChild("TargetCharacter")
	local addTargetModifier = value:FindFirstChild("AddTargetModifier")

	if not (targetCharacter and addTargetModifier) then
		slowBall(value, data.waveBallSlowMultiplier, 30)
		return
	end

	value.SetSpeed:Invoke(v5)
	value.TargetCharacter:Invoke(nil)
	local rootPart = p.rootPart
	local position

	if ballPrimaryPart then
		local raycastResult = raycastToMapBorder(ballPrimaryPart.Position, vector2, 4096) -- equivalent call inferred; original call site unknown

		if raycastResult then
			position = raycastResult.Position
		else
			position = ballPrimaryPart.Position + vector2 * data.waveRange
		end
	else
		position = nil
	end

	local ballReboundDuration = data.ballReboundDuration
	local flag = false
	value.AddTargetModifier:Invoke(function(p2: number)
		if not value.Parent then
			return {}
		end

		local position2 = value:GetPivot().Position
		local v8

		if position == nil then
			v8 = false
		else
			v8 = (position - position2):Dot(vector2) <= 2
		end

		if p2 < ballReboundDuration and not v8 then
			return {
				desiredVelocity = vector2 * v5
			}
		end

		if not rootPart.Parent then
			return {}
		end

		if not flag then
			flag = true
			value.TargetCharacter:Invoke(p.character)
		end

		local position3 = value:GetPivot().Position
		local v9 = rootPart.Position - position3

		if v9.Magnitude < 0.001 then
			return {}
		end

		return {
			desiredVelocity = v9.Unit * (v5 * 0.55)
		}
	end, 90, data.ballReboundDuration, true, `TsunamiRebound_{p.character.Name}`, true)
end

local function affectPlayer(model, p, p2, vector2: Vector3)
	if model == p.character then
		return
	end

	local humanoid = model:FindFirstChildWhichIsA("Humanoid")
	local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

	if not humanoid or humanoid.Health <= 0 or not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	local v4 = v:SetModifierFor(model, `Tsunami_{p.character.Name}`, function(p3: number)
		return (math.max(8, p3 * p2.playerSlowMultiplier))
	end, v.Priority.DEBUFF)
	task.delay(p2.playerSlowDuration, v4)
	model:SetAttribute("TsunamiDisoriented", true)
	task.delay(p2.playerSlowDuration, function()
		if model.Parent then
			model:SetAttribute("TsunamiDisoriented", nil)
		end
	end)
	local v5 = (model:GetAttribute("TsunamiAutoRotateToken") or 0) + 1

	if model:GetAttribute("TsunamiAutoRotateOriginal") == nil then
		model:SetAttribute("TsunamiAutoRotateOriginal", humanoid.AutoRotate)
	end

	model:SetAttribute("TsunamiAutoRotateToken", v5)
	humanoid.AutoRotate = false
	humanoidRootPart.AssemblyAngularVelocity += Vector3.new(0, math.random(-7, 7), 0)
	task.delay(0.35, function()
		if not humanoid.Parent or model:GetAttribute("TsunamiAutoRotateToken") ~= v5 then
			return
		end

		local tsunamiAutoRotateOriginal = model:GetAttribute("TsunamiAutoRotateOriginal")
		humanoid.AutoRotate = type(tsunamiAutoRotateOriginal) ~= "boolean" or tsunamiAutoRotateOriginal
		model:SetAttribute("TsunamiAutoRotateOriginal", nil)
		model:SetAttribute("TsunamiAutoRotateToken", nil)
	end)
	local tsunamiPush = humanoidRootPart:FindFirstChild("TsunamiPush")

	if tsunamiPush then
		tsunamiPush:Destroy()
	end

	local v6 = humanoidRootPart.Position - p.rootPart.Position
	local flatDirection = getFlatDirection(vector2) -- equivalent call inferred; original call site unknown
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "TsunamiPush"
	bodyVelocity.MaxForce = createVector(35000, 0, 35000)
	bodyVelocity.Velocity = flatDirection * math.max(85, 130 - v6.Magnitude * 0.35)
	bodyVelocity.Parent = humanoidRootPart
	TweenService:Create(bodyVelocity, TweenInfo.new(0.72, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Velocity = flatDirection * 18
	}):Play()
	Debris:AddItem(bodyVelocity, 0.82)
	local playerFromCharacter = Players:GetPlayerFromCharacter(model)

	if playerFromCharacter then
		tsunamiHit:FireClient(playerFromCharacter, false, p2.playerSlowDuration)
	end
end

local function affectWaveArea(p, vector2: Vector3, p2: number, vector3: Vector3, p3, p4, data, flag: boolean)
	for _, model in workspace.Alive:GetChildren() do
		if not model:IsA("Model") or p3[model] or not ((model:GetPivot().Position - vector2).Magnitude <= p2) then
			continue
		end

		p3[model] = true
		affectPlayer(model, p, data, vector3)
	end

	local children, v4, v5

	if RunService:IsServer() and v2 then
		children, v4, v5 = v2.getCurrentBalls()
	else
		children, v4, v5 = workspace.Balls:GetChildren()
	end

	for _, v6 in children, v4, v5 do
		if p4[v6] or not (type(v6) ~= "table" or not (v6.isSingularity or v6.isFury)) then
			continue
		end

		local tsunamiWallRebound

		if type(v6) == "table" then
			tsunamiWallRebound = v6.TsunamiWallRebound
		end

		if not (not tsunamiWallRebound or tsunamiWallRebound.returnTarget == p.player) then
			continue
		end

		local ballPrimaryPart = getBallPrimaryPart(v6)

		if not (ballPrimaryPart and (ballPrimaryPart.Position - vector2).Magnitude <= p2) then
			continue
		end

		p4[v6] = true

		if flag then
			reboundBallTowardCaster(v6, p, vector3, data)
		else
			slowBall(v6, data.waveBallSlowMultiplier, 35)
		end
	end
end

local function emitWave(p, vector2: Vector3, data, flag: boolean)
	local position = p.rootPart.Position
	local waveRange

	if p.upgradeLevel >= 1 then
		waveRange = getWaveTravelRange(position, vector2, data.waveRange)
	else
		waveRange = data.waveRange
	end

	local v4 = 0
	local v5 = {}
	local v6 = {}
	local v7

	if p.upgradeLevel >= 1 then
		v7 = color2
	else
		v7 = color
	end

	while v4 <= waveRange do
		local v8 = v4 + data.waveStep
		local raycastResult = raycastToMapBorder(position + vector2 * v4, vector2, data.waveStep) -- equivalent call inferred; original call site unknown

		if raycastResult then
			v8 = v4 + raycastResult.Distance
		end

		local v10 = position + vector2 * v8
		createWaveRing(v10, data.waveRadius * 2, 0.38, v7)
		affectWaveArea(p, v10, data.waveRadius, vector2, v5, v6, data, flag)

		if raycastResult then
			v4 = v8
			break
		else
			task.wait(data.waveDelay)
			v4 = v8
		end
	end

	if p.upgradeLevel >= 1 then
		for i = v4, 0, -data.waveStep do
			local v8 = position + vector2 * i
			createWaveRing(v8, data.waveRadius * 1.65, 0.3, color2)
			affectWaveArea(p, v8, data.waveRadius * 0.9, -vector2, v5, v6, data, true)
			task.wait(data.waveDelay * 0.75)
		end
	end
end

local function applyPassiveBallSlow(_, vector2: Vector3, p: number, p2)
	local serverTimeNow = workspace:GetServerTimeNow()
	local children, v4, v5

	if RunService:IsServer() and v2 then
		children, v4, v5 = v2.getCurrentBalls()
	else
		children, v4, v5 = workspace.Balls:GetChildren()
	end

	for _, v6 in children, v4, v5 do
		local ballPrimaryPart = getBallPrimaryPart(v6)

		if not ballPrimaryPart or p < (ballPrimaryPart.Position - vector2).Magnitude then
			continue
		end

		local tsunamiPassiveSlowUntil

		if typeof(v6) == "Instance" then
			tsunamiPassiveSlowUntil = v6:GetAttribute("TsunamiPassiveSlowUntil")
		else
			tsunamiPassiveSlowUntil = v3[v6]
		end

		if not (type(tsunamiPassiveSlowUntil) ~= "number" or not (serverTimeNow < tsunamiPassiveSlowUntil)) then
			continue
		end

		if typeof(v6) == "Instance" then
			v6:SetAttribute("TsunamiPassiveSlowUntil", serverTimeNow + 1.1)
		else
			v3[v6] = serverTimeNow + 1.1
		end

		slowBall(v6, p2.passiveBallSlowMultiplier, 45)
	end
end

local function startTsunami(data, p, config, vector2: Vector3)
	local character = data.character

	if character:GetAttribute("TsunamiActive") then
		return
	end

	local v4 = workspace:GetServerTimeNow() + config.duration
	character:SetAttribute("TsunamiActive", true)
	character:SetAttribute("TsunamiCharges", (data.upgradeLevel >= 1 and 1 or 0) + 2 - 1)
	character:SetAttribute("TsunamiStartedAt", workspace:GetServerTimeNow())
	task.spawn(emitWave, data, vector2, config, true)
	local v5

	if config.ownerSpeedMultiplier < 1 then
		v5 = v:SetModifierFor(character, "TsunamiOwnerPenalty", function(p2: number)
			return (math.max(12, p2 * config.ownerSpeedMultiplier))
		end, v.Priority.DEBUFF)
	else
		v5 = nil
	end

	local function cleanup()
		if v5 then
			v5()
			v5 = nil
		end

		if character.Parent then
			character:SetAttribute("TsunamiActive", nil)
			character:SetAttribute("TsunamiCharges", nil)
			character:SetAttribute("TsunamiRadius", nil)
			character:SetAttribute("TsunamiStartedAt", nil)
		end
	end

	p.addCleaner(cleanup)
	task.delay(config.duration, cleanup)

	while character.Parent == workspace.Alive and workspace:GetServerTimeNow() < v4 and character:GetAttribute("TsunamiActive") and not ((character:GetAttribute("TsunamiCharges") or 0) <= 0) do
		task.wait(0.15)
	end

	cleanup()
end

local function createPoolVisual(data, p)
	local character = data.character
	local rootPart = data.rootPart
	local serverTimeNow = workspace:GetServerTimeNow()
	local part = Instance.new("Part")
	part.Name = "TsunamiFloodedArea"
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	local color3

	if data.upgradeLevel >= 1 then
		color3 = color2
	else
		color3 = color
	end

	part.Color = color3
	part.Transparency = 0.72
	part.Size = Vector3.new(p.baseRadius * 2, 0.08, p.baseRadius * 2)
	part.Parent = workspace.Runtime
	Debris:AddItem(part, p.duration + 1)
	local total = 0
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if character.Parent and rootPart.Parent and not (workspace:GetServerTimeNow() - serverTimeNow > p.duration) then
			local tsunamiRadius = character:GetAttribute("TsunamiRadius") or p.baseRadius
			part.Size = Vector3.new(tsunamiRadius * 2, 0.08, tsunamiRadius * 2)
			local v5 = part
			local groundPosition = getGroundPosition(rootPart.Position) -- equivalent call inferred; original call site unknown
			v5.CFrame = CFrame.new(groundPosition)
			total += dt

			if total >= 0.75 then
				total = 0
				createWaveRing(rootPart.Position, tsunamiRadius * 2, 0.8, part.Color)
			end
		else
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			TweenService:Create(part, TweenInfo.new(0.25), {
				Transparency = 1
			}):Play()
			Debris:AddItem(part, 0.3)
		end
	end)
end

local function showHitFeedback(_: boolean, duration: number)
	if not Players.LocalPlayer then
		return
	end

	local highlights = {}

	for _, highlight in workspace:GetDescendants() do
		if not (highlight:IsA("Highlight") and highlight.Enabled) then
			continue
		end

		highlight.Enabled = false
		table.insert(highlights, highlight)
	end

	task.delay(duration, function()
		for _, v4 in highlights do
			if v4.Parent then
				v4.Enabled = true
			end
		end
	end)
end

if RunService:IsClient() then
	tsunamiHit.OnClientEvent:Connect(showHitFeedback)
end

local Tsunami = {}
Tsunami.cooldown = 40
Tsunami.cooldownReductionPerUpgrade = 14
Tsunami.uses = 2
Tsunami.iconId = "rbxassetid://0"

function Tsunami.overrideCondition(p)
	return p.character:GetAttribute("TsunamiActive") == true and (p.character:GetAttribute("TsunamiCharges") or 0) > 0
end

function Tsunami.validateArguments(p)
	if p == nil then
		return
	end

	assert(typeof(p) == "table", "Bad arguments")
	assert(p.kind == nil or p.kind == "start" or p.kind == "wave", "Bad kind")
	assert(p.waveDirection == nil or typeof(p.waveDirection) == "table", "Bad waveDirection")
end

function Tsunami.localOwnerActivation(p)
	local v4

	if RunService:IsClient() and workspace.CurrentCamera then
		v4 = workspace.CurrentCamera.CFrame.LookVector
	else
		v4 = p.rootPart.CFrame.LookVector
	end

	local flatDirection = getFlatDirection(v4) -- equivalent call inferred; original call site unknown
	return {
		kind = p.character:GetAttribute("TsunamiActive") and "wave" or "start",
		waveDirection = { flatDirection.X, flatDirection.Z }
	}
end

function Tsunami.anyClientActivationAsync(p, _, p2)
	local config = getConfig(p.upgradeLevel)
	local v4

	if p2 then
		local waveDirection = p2.waveDirection

		if typeof(waveDirection) == "table" then
			local v5 = waveDirection[1]
			local v6 = waveDirection[2]

			if type(v5) == "number" and type(v6) == "number" then
				v4 = getFlatDirection(Vector3.new(v5, 0, v6))
			end
		end
	end

	if p2 and (p2.kind == "wave" or p2.kind == "start") then
		if not v4 then
			v4 = getFlatDirection(p.rootPart.CFrame.LookVector)
		end

		local v6 = p.rootPart.Position + v4 * config.waveRadius
		local v7 = config.waveRadius * 2
		local v9

		if p.upgradeLevel >= 2 then
			v9 = color2
		else
			v9 = color
		end

		createWaveRing(v6, v7, 0.35, v9)
	end
end

function Tsunami.serverActivationAsync(data, p, p2)
	local config = getConfig(data.upgradeLevel)
	local waveDirection = p2 and p2.waveDirection
	local v4

	if typeof(waveDirection) == "table" then
		local v5 = waveDirection[1]
		local v6 = waveDirection[2]

		if type(v5) == "number" and type(v6) == "number" then
			v4 = getFlatDirection(Vector3.new(v5, 0, v6))
		end
	end

	if not v4 then
		v4 = getFlatDirection(data.rootPart.CFrame.LookVector)
	end

	if p2 and p2.kind == "wave" then
		task.spawn(emitWave, data, v4, config, true)
		return
	end

	if not data.character:GetAttribute("TsunamiActive") then
		startTsunami(data, p, config, v4)
		return
	end

	local tsunamiCharges = data.character:GetAttribute("TsunamiCharges") or 0

	if tsunamiCharges <= 0 then
		return
	end

	data.character:SetAttribute("TsunamiCharges", tsunamiCharges - 1)
	task.spawn(emitWave, data, v4, config, true)
end

return Tsunami