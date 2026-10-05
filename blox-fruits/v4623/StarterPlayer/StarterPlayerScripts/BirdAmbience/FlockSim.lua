local createVector = vector.create
local v = {
	{
		weight = 0.35,
		distMin = 150,
		distMax = 350,
		passWithin = 120,
		altMin = 25,
		altMax = 65,
		scale = 1,
		despawnMin = 450,
		despawnMax = 700,
		coneMin = 0.7853981633974483,
		coneMax = 1.4835298641951802
	},
	{
		weight = 0.35,
		distMin = 350,
		distMax = 650,
		passWithin = 300,
		altMin = 35,
		altMax = 90,
		scale = 1.25,
		despawnMin = 800,
		despawnMax = 1100,
		coneMin = 0,
		coneMax = 1.2217304763960306
	},
	{
		weight = 0.3,
		distMin = 650,
		distMax = 1000,
		passWithin = 500,
		altMin = 50,
		altMax = 120,
		scale = 1.75,
		despawnMin = 1250,
		despawnMax = 1600,
		coneMin = 0,
		coneMax = 1.1344640137963142
	}
}
local FlockSim = {}
FlockSim.__index = FlockSim

local function clampMagnitude(vector2: Vector3, p: number)
	local magnitude = vector2.Magnitude

	if p < magnitude and magnitude > 0.0001 then
		return vector2 * (p / magnitude)
	end

	return vector2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function horizontalOffset(vector2: Vector3, vector3: Vector3)
	return (Vector3.new(vector2.X - vector3.X, 0, vector2.Z - vector3.Z))
end

local function safeForward(vector2: Vector3, vector3: Vector3)
	if vector2.X * vector2.X + vector2.Z * vector2.Z < 0.0001 then
		return vector3
	end

	return vector2.Unit
end

local function coneHalfAngle(p, p2: number)
	return (math.min(p.halfAngle + p2 + 0.20943951023931956, 3.141592653589793))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pointVisible(vector2: Vector3, data, p: number)
	if not data then
		return true
	end

	local vector3 = vector2 - data.position
	local magnitude = vector3.Magnitude

	if magnitude < 0.0001 then
		return true
	end

	return vector3:Dot(data.look) > magnitude * math.cos((math.min(
		data.halfAngle + p + 0.20943951023931956,
		3.141592653589793
	)))
end

local function flockVisible(p, data)
	if not data then
		return true
	end

	local vector2 = p.leader.position - data.position
	local magnitude = vector2.Magnitude

	if magnitude < 0.0001 then
		return true
	end

	local v2 = math.atan(p.scale * 18 / magnitude)
	return vector2:Dot(data.look) > magnitude * math.cos((math.min(
		data.halfAngle + v2 + 0.20943951023931956,
		3.141592653589793
	)))
end

local function newBird(random, i: number)
	local number = random:NextNumber(0.85, 1.15)
	return {
		rng = Random.new(random:NextInteger(1, 2147483646)),
		position = createVector(0, 0, 0),
		velocity = createVector(0, 0, -30),
		rotation = CFrame.identity,
		cframe = CFrame.identity,
		bank = 0,
		flapPhase = random:NextNumber() * 6.283185307179586,
		flapWeight = random:NextNumber(),
		flapping = true,
		boutTimer = random:NextNumber(1.5, 4),
		fade = 0,
		sizeJitter = number,
		scale = number,
		paletteIndex = 1,
		speedMin = 22,
		speedMax = 40,
		maxAccel = 18,
		heightAlpha = 0.5,
		lowFlier = false,
		stationBack = 0,
		stationSide = 0,
		orbitRadius = 14,
		orbitSpeed = 13,
		orbitSign = 1,
		slotSide = i % 2 == 0 and 1 or -1,
		slotRank = math.ceil((i - 1) / 2),
		wanderMainAmp = random:NextNumber(0.6, 1) * 9,
		wanderMainFreq = random:NextNumber(0.05, 0.14) * 6.283185307179586,
		wanderMainPhase = random:NextNumber() * 6.283185307179586,
		wanderFineAmp = random:NextNumber(0.3, 0.7) * 4,
		wanderFineFreq = random:NextNumber(0.22, 0.5) * 6.283185307179586,
		wanderFinePhase = random:NextNumber() * 6.283185307179586,
		wanderVerticalAmp = random:NextNumber(0.5, 1) * 3,
		wanderVerticalFreq = random:NextNumber(0.04, 0.11) * 6.283185307179586,
		wanderVerticalPhase = random:NextNumber() * 6.283185307179586,
		breatheFreqX = random:NextNumber(0.1, 0.35) * 6.283185307179586,
		breatheFreqY = random:NextNumber(0.1, 0.35) * 6.283185307179586,
		breatheFreqZ = random:NextNumber(0.1, 0.35) * 6.283185307179586,
		breathePhaseX = random:NextNumber() * 6.283185307179586,
		breathePhaseY = random:NextNumber() * 6.283185307179586,
		breathePhaseZ = random:NextNumber() * 6.283185307179586
	}
end

local function slotOffset(data, elapsed: number)
	local slotRank = data.slotRank
	local v2 = Vector3.new(
		math.sin(elapsed * data.breatheFreqX + data.breathePhaseX),
		math.sin(elapsed * data.breatheFreqY + data.breathePhaseY),
		(math.sin(elapsed * data.breatheFreqZ + data.breathePhaseZ))
	) * 1.6
	return Vector3.new(data.slotSide * 4 * slotRank, slotRank * -0.6, slotRank * 5) + v2
end

local function biasForward(p)
	local cameraForward = p.cameraForward

	if cameraForward then
		return cameraForward
	end

	local anchorTravel = p.anchorTravel

	if anchorTravel.Magnitude >= 15 then
		return anchorTravel.Unit
	end

	return nil
end

local function forwardOccupancy(state, lastAnchorPosition: Vector3, p: number)
	local cameraForward = state.cameraForward

	if not cameraForward then
		return 1
	end

	local v2 = math.cos(p)
	local count = 0

	for _, flock in state.flocks do
		if flock.escort or flock.fade <= 0.5 then
			continue
		end

		local v3 = horizontalOffset(flock.leader.position, lastAnchorPosition) -- equivalent call inferred; original call site unknown
		local magnitude = v3.Magnitude

		if magnitude > 900 or not (magnitude < 0.0001 or v2 < v3.Unit:Dot(cameraForward)) then
			continue
		end

		count += 1
	end

	return count
end

local function chooseLayer(state, flag: boolean)
	local rng = state.rng

	if flag then
		if rng:NextInteger(0, 1) == 0 then
			return 2
		end

		return 3
	else
		local v2 = false

		for _, flock in state.flocks do
			if not (flock.layerIndex == 3 and flock.state ~= "Waiting") then
				continue
			end

			v2 = true
			break
		end

		if not v2 then
			return 3
		end

		local number = rng:NextNumber()
		local total = 0

		for k, v4 in v do
			total += v4.weight

			if number <= total then
				return k
			end
		end

		return 1
	end
end

local function coneOffset(state, p, flag: boolean)
	local rng = state.rng
	local coneMin = p.coneMin
	local coneMax

	if flag then
		coneMax = coneMin + (p.coneMax - coneMin) * 0.5
	else
		coneMax = p.coneMax
	end

	local v2

	if coneMin > 0 then
		v2 = rng:NextNumber(coneMin, coneMax)
	else
		v2 = coneMax * rng:NextNumber() ^ 1.6
	end

	return (rng:NextInteger(0, 1) == 0 and 1 or -1) * v2
end

local function spawnHeight(p, vector2: Vector3, p2, p3, p4: number)
	local rng = p.rng
	local v2 = math.max(p.smoothedAnchorY, vector2.Y)
	local v3 = v2 + p3.altMin
	local v4 = v2 + p3.altMax
	local v5

	if p2 then
		v5 = p2.position.Y
	else
		v5 = vector2.Y
	end

	return (math.clamp(v5 + math.tan((rng:NextNumber(0.017453292519943295, 0.24434609527920614))) * p4, v3, v4))
end

local function courseDirection(data, vector2: Vector3, vector3: Vector3, p)
	local DISTANCE_EPSILON = 0.0001
	local rng = data.rng
	local cameraForward = data.cameraForward

	if not cameraForward then
		local anchorTravel = data.anchorTravel

		if anchorTravel.Magnitude >= 15 then
			cameraForward = anchorTravel.Unit
		else
			cameraForward = nil
		end
	end

	local v2 = horizontalOffset(vector3, vector2) -- equivalent call inferred; original call site unknown
	local selected = v2.Magnitude < DISTANCE_EPSILON and createVector(1, 0, 0) or v2.Unit

	if not cameraForward then
		return selected
	end

	local cross = cameraForward:Cross(createVector(0, 1, 0))

	if cross.Magnitude < DISTANCE_EPSILON then
		return selected
	end

	local unit = cross.Unit
	local v4 = rng:NextInteger(0, 1) == 0 and 1 or -1
	local v5 = rng:NextNumber(0.35, 1) * p.passWithin * v4
	local v6 = rng:NextNumber(-0.3, 0.3) * p.passWithin
	local v7 = Vector3.new(vector3.X, 0, vector3.Z) + unit * v5 + cameraForward * v6 - Vector3.new(
		vector2.X,
		0,
		vector2.Z
	)

	if v7.Magnitude < DISTANCE_EPSILON then
		return selected
	end

	return v7.Unit
end

local function spawnFlock(state, state2, vector2: Vector3, data, flag: boolean)
	local rng = state.rng
	local v2 = chooseLayer(state, flag)
	local v3 = v[v2]
	local cameraForward = state.cameraForward

	if not cameraForward then
		local anchorTravel = state.anchorTravel

		if anchorTravel.Magnitude >= 15 then
			cameraForward = anchorTravel.Unit
		else
			cameraForward = nil
		end
	end

	local spawnFromCone

	if cameraForward == nil then
		spawnFromCone = false
	else
		spawnFromCone = flag or rng:NextNumber() <= 0.8
	end

	local v5 = 0
	local v6

	if spawnFromCone and cameraForward then
		v5 = coneOffset(state, v3, flag)
		v6 = math.atan2(cameraForward.Z, cameraForward.X) + v5
	else
		v6 = rng:NextNumber() * 6.283185307179586
	end

	local distMax

	if flag then
		distMax = math.min(v3.distMax, 765)
	else
		distMax = v3.distMax
	end

	local number = rng:NextNumber(v3.distMin, (math.max(distMax, v3.distMin)))

	local function spawnPoint(p: number, p2: number)
		local v7 = vector2.X + math.cos(p) * p2
		local v8 = state
		local v9 = vector2
		local v10 = data
		local v11 = v3
		local rng2 = v8.rng
		local v12 = math.max(v8.smoothedAnchorY, v9.Y)
		local v13 = v12 + v11.altMin
		local v14 = v12 + v11.altMax
		local v15

		if v10 then
			v15 = v10.position.Y
		else
			v15 = v9.Y
		end

		return (Vector3.new(
			v7,
			math.clamp(v15 + math.tan((rng2:NextNumber(0.017453292519943295, 0.24434609527920614))) * p2, v13, v14),
			vector2.Z + math.sin(p) * p2
		))
	end

	local v7 = vector2.X + math.cos(v6) * number
	local rng2 = state.rng
	local v8 = math.max(state.smoothedAnchorY, vector2.Y)
	local v9 = v8 + v3.altMin
	local v10 = v8 + v3.altMax
	local v11

	if data then
		v11 = data.position.Y
	else
		v11 = vector2.Y
	end

	local vector3 = Vector3.new(
		v7,
		math.clamp(v11 + math.tan((rng2:NextNumber(0.017453292519943295, 0.24434609527920614))) * number, v9, v10),
		vector2.Z + math.sin(v6) * number
	)

	if data then
		if v2 == 1 then
			local count = 0

			while count < 4 do
				local v12 = pointVisible(vector3, data, 0) -- equivalent call inferred; original call site unknown

				if not (v12 and (vector3 - data.position).Magnitude < 450) then
					break
				end

				local v13 = v5 >= 0 and 0.2617993877991494 or -0.2617993877991494
				v6 += v13
				v5 += v13
				local v14 = vector2.X + math.cos(v6) * number
				local rng3 = state.rng
				local v15 = math.max(state.smoothedAnchorY, vector2.Y)
				local v16 = v15 + v3.altMin
				local v17 = v15 + v3.altMax
				local v18

				if data then
					v18 = data.position.Y
				else
					v18 = vector2.Y
				end

				vector3 = Vector3.new(
					v14,
					math.clamp(
						v18 + math.tan((rng3:NextNumber(0.017453292519943295, 0.24434609527920614))) * number,
						v16,
						v17
					),
					vector2.Z + math.sin(v6) * number
				)
				count += 1
			end
		elseif v2 == 2 then
			local v12 = pointVisible(vector3, data, 0) -- equivalent call inferred; original call site unknown

			if v12 and number < 450 then
				number = rng:NextNumber(450, (math.max(distMax, 450)))
				local v13 = vector2.X + math.cos(v6) * number
				local rng3 = state.rng
				local v14 = math.max(state.smoothedAnchorY, vector2.Y)
				local v15 = v14 + v3.altMin
				local v16 = v14 + v3.altMax
				local v17

				if data then
					v17 = data.position.Y
				else
					v17 = vector2.Y
				end

				vector3 = Vector3.new(
					v13,
					math.clamp(
						v17 + math.tan((rng3:NextNumber(0.017453292519943295, 0.24434609527920614))) * number,
						v15,
						v16
					),
					vector2.Z + math.sin(v6) * number
				)
			end
		end
	end

	local spawnInsideFrustum = pointVisible(vector3, data, 0) -- equivalent call inferred; original call site unknown
	local courseDir = courseDirection(state, vector3, vector2, v3)
	local velocity = courseDir * 30
	local cframe = CFrame.lookAlong(vector3, courseDir)

	for _, bird in state2.birds do
		bird.position = cframe * slotOffset(bird, state.elapsed)
		bird.velocity = velocity
		bird.rotation = CFrame.lookAlong(createVector(0, 0, 0), courseDir)
		bird.cframe = CFrame.new(bird.position) * bird.rotation
		bird.bank = 0
		bird.fade = 0
		bird.scale = v3.scale * bird.sizeJitter
		bird.paletteIndex = v2
	end

	state2.leader.position = vector3
	state2.leader.cframe = CFrame.new(vector3) * state2.leader.rotation
	state2.state = "FadingIn"
	state2.fade = 0
	state2.fadeInTime = spawnInsideFrustum and 3 or 1.5
	state2.layerIndex = v2
	state2.bandMin = v3.altMin
	state2.bandMax = v3.altMax
	state2.scale = v3.scale
	state2.despawnMin = v3.despawnMin
	state2.despawnMax = v3.despawnMax
	state2.courseOrigin = vector3
	state2.courseDir = courseDir
	state2.offscreenTime = 0
	state2.visible = true
	state2.obstructed = false
	local Y = vector3.Y
	local v15

	if data then
		v15 = data.position.Y
	else
		v15 = vector2.Y
	end

	state2.spawnElevation = math.atan((Y - v15) / math.max(number, 0.0001))
	state2.spawnInsideFrustum = spawnInsideFrustum
	state2.spawnConeOffset = not spawnFromCone and 3.141592653589793 or math.abs(v5)
	state2.spawnFromCone = spawnFromCone

	if flag then
		state.noticeCooldown = 4
	end

	state.spawnCount += 1
	state2.spawnId = state.spawnCount
end

local function beginWaiting(p, p2, p3: number?)
	p2.state = "Waiting"
	p2.fade = 0
	p2.respawnTimer = p3 or p.rng:NextNumber(1, 5)

	for _, bird in p2.birds do
		bird.fade = 0
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function escortSpeedMax(data)
	return (math.clamp(data.velocity.Magnitude * 1.2, 26, 95))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function escortTargetY(p, data)
	local v2 = data.position.Y + 4
	return v2 + (math.max(data.topY + 30, v2) - v2) * p.heightAlpha
end

-- equivalent calls inferred from this helper; original call sites unknown
local function escortClearance(data, p: number)
	if p < data.topY + 4 then
		return data.halfLength + 8
	end

	return 0
end

local function spawnEscort(state, state2, data, data2)
	local rng = state.rng
	local cross = data.heading:Cross(createVector(0, 1, 0))
	local v2 = not (cross.Magnitude > 0.0001) and createVector(1, 0, 0) or cross.Unit
	local v3 = data.position - data.heading * 150 + v2 * rng:NextNumber(-40, 40)
	local speedMax = escortSpeedMax(data) -- equivalent call inferred; original call site unknown
	local velocity = data.velocity + data.heading * 15
	local magnitude = velocity.Magnitude

	if magnitude < 0.0001 then
		velocity = data.heading * 26
	elseif speedMax < magnitude then
		velocity *= speedMax / magnitude
	elseif magnitude < 12 then
		velocity *= 12 / magnitude
	end

	local heading = data.heading

	if not (velocity.X * velocity.X + velocity.Z * velocity.Z < 0.0001) then
		heading = velocity.Unit
	end

	local cframe = CFrame.lookAlong(createVector(0, 0, 0), heading)
	local v6 = #state2.birds

	for k, bird in state2.birds do
		bird.heightAlpha = (k - rng:NextNumber()) / v6
		local v7 = escortTargetY(bird, data) -- equivalent call inferred; original call site unknown
		bird.lowFlier = v7 < data.topY + 4
		local v8 = rng:NextInteger(0, 1) == 0 and 1 or -1

		if bird.lowFlier then
			local v9 = data.halfLength + 8
			bird.stationBack = rng:NextNumber(v9, data.halfLength + 45)
			bird.stationSide = v8 * rng:NextNumber(0, 14)
			bird.orbitRadius = rng:NextNumber(v9, v9 + 12)
		else
			bird.stationBack = rng:NextNumber(6, 40)
			bird.stationSide = v8 * rng:NextNumber(4, 26)
			bird.orbitRadius = rng:NextNumber(14, 34)
		end

		bird.orbitSpeed = rng:NextNumber(13, 19)
		bird.orbitSign = rng:NextInteger(0, 1) == 0 and 1 or -1
		local v9 = v3 + v2 * bird.stationSide - data.heading * rng:NextNumber(0, 20)
		bird.position = Vector3.new(v9.X, v7, v9.Z)
		bird.velocity = velocity
		bird.rotation = cframe
		bird.cframe = CFrame.new(bird.position) * cframe
		bird.bank = 0
		bird.fade = 0
		bird.scale = bird.sizeJitter
		bird.paletteIndex = 1
		bird.speedMin = 12
		bird.speedMax = speedMax
		bird.maxAccel = 26
	end

	local position = state2.leader.position
	local spawnInsideFrustum = pointVisible(position, data2, 0) -- equivalent call inferred; original call site unknown
	state2.state = "FadingIn"
	state2.fade = 0
	state2.fadeInTime = spawnInsideFrustum and 3 or 1.5
	state2.layerIndex = 1
	state2.bandMin = 4
	state2.bandMax = 30
	state2.scale = 1
	state2.despawnMin = v[1].despawnMin
	state2.despawnMax = v[1].despawnMax
	state2.courseOrigin = position
	state2.courseDir = heading
	state2.offscreenTime = 0
	state2.visible = true
	state2.obstructed = false
	state2.escortBlend = data.speed01
	state2.spawnElevation = 0
	state2.spawnInsideFrustum = spawnInsideFrustum
	state2.spawnConeOffset = 3.141592653589793
	state2.spawnFromCone = false
	state.spawnCount += 1
	state2.spawnId = state.spawnCount
end

local function updateEscortFlock(state, flock, p: number, data, p2)
	if data then
		flock.escortBlend += (data.speed01 - flock.escortBlend) * (1 - math.exp(p * -1.5))
	end

	if flock.state == "Waiting" then
		flock.respawnTimer -= p

		if not data or data.velocity.Magnitude > 85 then
			return
		end

		if flock.respawnTimer <= 0 then
			spawnEscort(state, flock, data, p2)
		end
	else
		flock.visible = flockVisible(flock, p2)

		if flock.state == "FadingIn" or flock.state == "Active" then
			local v2

			if data == nil then
				v2 = false
			else
				local position = flock.leader.position
				local position2 = data.position
				v2 = Vector3.new(position.X - position2.X, 0, position.Z - position2.Z).Magnitude > 250
			end

			if not data or flock.obstructed or v2 then
				flock.state = "FadingOut"
			end
		end

		if flock.state == "FadingIn" then
			flock.fade = math.min(1, flock.fade + p / flock.fadeInTime)

			if flock.fade >= 1 then
				flock.state = "Active"
			end
		elseif flock.state == "FadingOut" then
			flock.fade = math.max(0, flock.fade - p / 1)

			if flock.fade <= 0 then
				flock.state = "Waiting"
				flock.fade = 0
				flock.respawnTimer = state.rng:NextNumber(1, 5)

				for _, bird in flock.birds do
					bird.fade = 0
				end

				return
			end
		end

		for _, bird in flock.birds do
			bird.fade = flock.fade
		end
	end
end

local function reapUnseen(state, lastAnchorPosition: Vector3, p)
	if not p then
		return
	end

	for _, flock in state.flocks do
		if not flock.escort and flock.state == "Waiting" then
			return
		end
	end

	local v2 = 0
	local v3 = nil

	for _, flock in state.flocks do
		if flock.escort or flock.state ~= "Active" or (flock.offscreenTime <= 1 or flockVisible(flock, p)) then
			continue
		end

		local position = flock.leader.position
		local magnitude = Vector3.new(position.X - lastAnchorPosition.X, 0, position.Z - lastAnchorPosition.Z).Magnitude

		if not (v2 <= magnitude) then
			continue
		end

		v3 = flock
		v2 = magnitude
	end

	if v3 then
		v3.state = "Waiting"
		v3.fade = 0
		v3.respawnTimer = 0

		for _, bird in v3.birds do
			bird.fade = 0
		end
	end
end

local function separationSteer(p, p2)
	local v2 = createVector(0, 0, 0)

	for _, bird in p2.birds do
		if bird == p then
			continue
		end

		local v3 = p.position - bird.position
		local magnitude = v3.Magnitude

		if magnitude < 12 and magnitude > 0.0001 then
			v2 += v3.Unit * (14 * (1 - magnitude / 12))
		end
	end

	return v2
end

local function wanderSteer(p, data)
	local elapsed = p.elapsed
	local velocity = data.velocity
	local lookVector = data.rotation.LookVector

	if not (velocity.X * velocity.X + velocity.Z * velocity.Z < 0.0001) then
		lookVector = velocity.Unit
	end

	local cross = lookVector:Cross(createVector(0, 1, 0))
	local unit

	if cross.Magnitude > 0.0001 then
		unit = cross.Unit
	else
		unit = data.rotation.RightVector
	end

	local v2 = data.wanderMainAmp * math.sin(elapsed * data.wanderMainFreq + data.wanderMainPhase) + data.wanderFineAmp * math.sin(elapsed * data.wanderFineFreq + data.wanderFinePhase)
	local v3 = data.wanderVerticalAmp * math.sin(elapsed * data.wanderVerticalFreq + data.wanderVerticalPhase)
	return unit * v2 + createVector(0, 1, 0) * v3
end

local function steerLeader(state, bird, flock, _: Vector3)
	local v2 = wanderSteer(state, bird)
	local v3 = state.smoothedAnchorY + flock.bandMin
	local v4 = state.smoothedAnchorY + flock.bandMax

	if bird.position.Y < v3 then
		v2 += createVector(0, 1, 0) * (math.min((v3 - bird.position.Y) * 1.2, 14) - bird.velocity.Y * 0.8)
	elseif v4 < bird.position.Y then
		v2 -= createVector(0, 1, 0) * (math.min((bird.position.Y - v4) * 1.2, 14) + bird.velocity.Y * 0.8)
	end

	local vector2 = horizontalOffset(bird.position, flock.courseOrigin) -- equivalent call inferred; original call site unknown
	local v5 = (vector2 - flock.courseDir * vector2:Dot(flock.courseDir)) * 0.15
	local magnitude = v5.Magnitude

	if magnitude > 4 and magnitude > 0.0001 then
		v5 *= 4 / magnitude
	end

	return v2 - v5
end

local function steerFollower(state, bird, flock)
	local leader = flock.leader
	local velocity = leader.velocity
	local lookVector = leader.rotation.LookVector

	if not (velocity.X * velocity.X + velocity.Z * velocity.Z < 0.0001) then
		lookVector = velocity.Unit
	end

	return (CFrame.lookAlong(leader.position, lookVector) * slotOffset(bird, state.elapsed) - bird.position) * 2.2 + (leader.velocity - bird.velocity) * 2.6 + separationSteer(
		bird,
		flock
	)
end

local function steerEscortBird(state, bird, flock, data)
	local v2 = wanderSteer(state, bird)
	local v3 = separationSteer(bird, flock)

	if not data then
		return v2 + v3
	end

	local elapsed = state.elapsed
	local escortBlend = flock.escortBlend
	local cross = data.heading:Cross(createVector(0, 1, 0))
	local v4 = not (cross.Magnitude > 0.0001) and createVector(1, 0, 0) or cross.Unit
	local v5 = escortTargetY(bird, data) -- equivalent call inferred; original call site unknown
	local v6 = escortClearance(data, v5) -- equivalent call inferred; original call site unknown
	local v7 = horizontalOffset(bird.position, data.position) -- equivalent call inferred; original call site unknown
	local magnitude = v7.Magnitude
	local vector2

	if magnitude > 0.0001 then
		vector2 = v7 / magnitude
	else
		vector2 = v4
	end

	local v8 = vector2:Cross(createVector(0, 1, 0)) * bird.orbitSign
	local v9 = math.max(bird.orbitRadius, v6)
	local v10 = (v8 * bird.orbitSpeed + vector2 * ((v9 - magnitude) * 0.8) - Vector3.new(
		bird.velocity.X,
		0,
		bird.velocity.Z
	)) * 2.5
	local v11 = v5 - 3
	local v12 = v5 + 3

	if bird.position.Y < v11 then
		v10 += createVector(0, 1, 0) * (math.min((v11 - bird.position.Y) * 1.2, 14) - bird.velocity.Y * 0.8)
	elseif v12 < bird.position.Y then
		v10 -= createVector(0, 1, 0) * (math.min((bird.position.Y - v12) * 1.2, 14) + bird.velocity.Y * 0.8)
	end

	local v13 = v4 * (math.sin(elapsed * bird.breatheFreqX + bird.breathePhaseX) * 8) + createVector(0, 1, 0) * (math.sin(elapsed * bird.breatheFreqY + bird.breathePhaseY) * 4)
	local v14 = (data.position - data.heading * math.max(bird.stationBack, v6) + v4 * bird.stationSide + createVector(
		0,
		1,
		0
	) * (v5 - data.position.Y) + v13 - bird.position) * 1.6 + (data.velocity - bird.velocity) * 2.2
	return v10 * (1 - escortBlend) + v14 * escortBlend + v2 * 0.5 + v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateEscortLimits(bird, flock, p)
	bird.speedMin = flock.escortBlend * 10 + 12
	bird.speedMax = math.clamp(p.velocity.Magnitude * 1.2, 26, 95)
	bird.maxAccel = 26
end

local function integrate(bird, vector2: Vector3, p: number)
	local maxAccel = bird.maxAccel
	local magnitude = vector2.Magnitude

	if maxAccel < magnitude and magnitude > 0.0001 then
		vector2 *= maxAccel / magnitude
	end

	local vector3 = bird.velocity + vector2 * p
	local v2 = math.sqrt(vector3.X * vector3.X + vector3.Z * vector3.Z) * 0.8390996311772799

	if v2 < math.abs(vector3.Y) then
		local X = vector3.X

		if not (vector3.Y > 0) then
			v2 = -v2
		end

		vector3 = Vector3.new(X, v2, vector3.Z)
	end

	local magnitude2 = vector3.Magnitude

	if magnitude2 < 0.0001 then
		vector3 = bird.rotation.LookVector * bird.speedMin
	elseif bird.speedMax < magnitude2 then
		vector3 *= bird.speedMax / magnitude2
	elseif magnitude2 < bird.speedMin then
		vector3 *= bird.speedMin / magnitude2
	end

	bird.velocity = vector3
	bird.position += vector3 * p
	local lookVector = bird.rotation.LookVector

	if not (vector3.X * vector3.X + vector3.Z * vector3.Z < 0.0001) then
		lookVector = vector3.Unit
	end

	local cross = lookVector:Cross(createVector(0, 1, 0))
	local v3

	if cross.Magnitude > 0.0001 then
		v3 = cross.Unit
	else
		v3 = bird.rotation.RightVector
	end

	local v4 = math.clamp(math.atan(vector2:Dot(v3) / 26), -0.6108652381980153, 0.6108652381980153)
	bird.bank += (v4 - bird.bank) * (1 - math.exp(p * -4))
	local v5 = CFrame.lookAlong(createVector(0, 0, 0), lookVector) * CFrame.Angles(0, 0, -bird.bank)
	bird.rotation = bird.rotation:Lerp(v5, 1 - math.exp(p * -5))
	bird.cframe = CFrame.new(bird.position) * bird.rotation
end

local function updateFlap(bird, p: number)
	bird.boutTimer -= p

	if bird.boutTimer <= 0 then
		bird.flapping = not bird.flapping
		local boutTimer

		if bird.flapping then
			boutTimer = bird.rng:NextNumber(1.5, 4)
		else
			boutTimer = bird.rng:NextNumber(1, 3)
		end

		bird.boutTimer = boutTimer
	end

	local v2 = bird.flapping and 1 or 0
	local v3 = bird.velocity.Y > 2 and 1 or bird.velocity.Y < -3 and 0 or v2
	local v4 = bird.velocity.Magnitude > 44 and 1 or v3
	bird.flapWeight += (v4 - bird.flapWeight) * (1 - math.exp(p * -6))
	bird.flapPhase = (bird.flapPhase + 15.079644737231007 * bird.flapWeight * p / bird.sizeJitter) % 6.283185307179586
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateScale(bird, flock, p)
	local scale = flock.scale * bird.sizeJitter

	if p then
		local v3 = (bird.position - p.position).Magnitude * 0.0016

		if scale < v3 then
			scale = math.floor(v3 / 0.05 + 0.5) * 0.05
		end
	end

	bird.scale = scale
end

local function updateFlock(state, flock, p: number, lastAnchorPosition: Vector3, p2, flag: boolean)
	if flock.state == "Waiting" then
		flock.respawnTimer -= p

		if not (math.abs(state.anchorVerticalSpeed) <= 80) then
			return false
		end

		if flag or flock.respawnTimer <= 0 then
			spawnFlock(state, flock, lastAnchorPosition, p2, flag)
			return true
		else
			return false
		end
	else
		flock.visible = flockVisible(flock, p2)

		if flock.visible then
			flock.offscreenTime = 0
		else
			flock.offscreenTime += p
		end

		if flock.state == "FadingIn" then
			if flock.obstructed then
				flock.state = "FadingOut"
			else
				flock.fade = math.min(1, flock.fade + p / flock.fadeInTime)

				if flock.fade >= 1 then
					flock.state = "Active"
				end
			end
		elseif flock.state == "FadingOut" then
			flock.fade = math.max(0, flock.fade - p / 1)

			if flock.fade <= 0 then
				flock.state = "Waiting"
				flock.fade = 0
				flock.respawnTimer = state.rng:NextNumber(1, 5)

				for _, bird in flock.birds do
					bird.fade = 0
				end

				return false
			end
		else
			local leader = flock.leader
			local v2 = horizontalOffset(leader.position, lastAnchorPosition) -- equivalent call inferred; original call site unknown
			local magnitude = v2.Magnitude
			local v3 = leader.position.Y < lastAnchorPosition.Y + 10

			if flock.obstructed or v3 or flock.despawnMax < magnitude then
				flock.state = "FadingOut"
			elseif not flock.visible and flock.offscreenTime > 1 and flock.despawnMin < magnitude then
				local velocity = leader.velocity

				if Vector3.new(velocity.X - 0, 0, velocity.Z - 0):Dot(v2) > 0 then
					flock.state = "Waiting"
					flock.fade = 0
					flock.respawnTimer = state.rng:NextNumber(1, 5)

					for _, bird in flock.birds do
						bird.fade = 0
					end

					return false
				end
			end
		end

		for _, bird in flock.birds do
			bird.fade = flock.fade
		end

		return false
	end
end

function FlockSim.new(options)
	local v2 = options or {}
	local random = Random.new()
	local flockCount = v2.flockCount or 6
	local flockSizeMin = v2.flockSizeMin or 1
	local flockSizeMax = v2.flockSizeMax or 5
	local object = setmetatable({
		rng = random,
		birds = {},
		flocks = {},
		elapsed = 0,
		smoothedAnchorY = 0,
		lastAnchorY = 0,
		anchorVerticalSpeed = 0,
		lastAnchorPosition = createVector(0, 0, 0),
		anchorTravel = createVector(0, 0, 0),
		cameraForward = nil,
		noticeCooldown = 0,
		spawnCount = 0
	}, FlockSim)

	local function addFlock(p: number, escort: boolean)
		local birds = {}

		for i = 1, p do
			local v4 = newBird(random, i)
			table.insert(birds, v4)
			table.insert(object.birds, v4)
		end

		table.insert(object.flocks, {
			birds = birds,
			leader = birds[1],
			state = "Waiting",
			fade = 0,
			fadeInTime = 1.5,
			layerIndex = 1,
			bandMin = v[1].altMin,
			bandMax = v[1].altMax,
			scale = v[1].scale,
			despawnMin = v[1].despawnMin,
			despawnMax = v[1].despawnMax,
			courseOrigin = createVector(0, 0, 0),
			courseDir = createVector(0, 0, -1),
			offscreenTime = 0,
			respawnTimer = 0,
			visible = true,
			obstructed = false,
			spawnId = 0,
			spawnElevation = 0,
			spawnInsideFrustum = false,
			spawnConeOffset = 0,
			spawnFromCone = false,
			escort = escort,
			escortBlend = 0
		})
	end

	for _ = 1, flockCount do
		addFlock(random:NextInteger(flockSizeMin, flockSizeMax), false)
	end

	addFlock(random:NextInteger(8, 12), true)
	return object
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCameraForward(state, p)
	if not p then
		return
	end

	local vector2 = Vector3.new(p.look.X, 0, p.look.Z)

	if vector2.Magnitude > 0.001 then
		state.cameraForward = vector2.Unit
	end
end

function FlockSim:reset(lastAnchorPosition: Vector3, p, p2)
	self.smoothedAnchorY = lastAnchorPosition.Y
	self.lastAnchorY = lastAnchorPosition.Y
	self.anchorVerticalSpeed = 0
	self.lastAnchorPosition = lastAnchorPosition
	self.anchorTravel = createVector(0, 0, 0)
	self.noticeCooldown = 0
	updateCameraForward(self, p) -- equivalent call inferred; original call site unknown

	for _, flock in self.flocks do
		if flock.escort then
			if p2 and p2.velocity.Magnitude <= 85 then
				spawnEscort(self, flock, p2, p)
			else
				flock.state = "Waiting"
				flock.fade = 0
				flock.respawnTimer = self.rng:NextNumber(1, 5)

				for _, bird in flock.birds do
					bird.fade = 0
				end
			end
		else
			spawnFlock(self, flock, lastAnchorPosition, p, false)
		end
	end
end

function FlockSim:step(p: number, lastAnchorPosition: Vector3, p2, p3)
	local v2 = math.min(p, 0.1)

	if v2 <= 0 then
		return
	end

	self.elapsed += v2
	updateCameraForward(self, p2) -- equivalent call inferred; original call site unknown
	local Y = lastAnchorPosition.Y
	local v3 = (Y - self.lastAnchorY) / v2
	self.lastAnchorY = Y
	self.anchorVerticalSpeed += (v3 - self.anchorVerticalSpeed) * (1 - math.exp(v2 * -4))
	local lastAnchorPosition2 = self.lastAnchorPosition
	local v4 = Vector3.new(
		lastAnchorPosition.X - lastAnchorPosition2.X,
		0,
		lastAnchorPosition.Z - lastAnchorPosition2.Z
	) / v2
	self.lastAnchorPosition = lastAnchorPosition
	self.anchorTravel += (v4 - self.anchorTravel) * (1 - math.exp(v2 * -4))
	local v5 = self.smoothedAnchorY < Y and 2.5 or 0.5
	self.smoothedAnchorY += (Y - self.smoothedAnchorY) * (1 - math.exp(-v5 * v2))
	self.noticeCooldown = math.max(0, self.noticeCooldown - v2)
	local v6

	if self.noticeCooldown <= 0 then
		v6 = forwardOccupancy(self, lastAnchorPosition, 0.6108652381980153) == 0
	else
		v6 = false
	end

	if v6 then
		reapUnseen(self, lastAnchorPosition, p2)
	end

	for _, flock in self.flocks do
		if flock.escort then
			updateEscortFlock(self, flock, v2, p3, p2)
		elseif updateFlock(self, flock, v2, lastAnchorPosition, p2, v6) then
			v6 = false
		end

		if flock.state == "Waiting" then
			continue
		end

		for _, bird in flock.birds do
			local v7

			if flock.escort then
				if p3 then
					updateEscortLimits(bird, flock, p3) -- equivalent call inferred; original call site unknown
				end

				v7 = steerEscortBird(self, bird, flock, p3)
			elseif bird == flock.leader then
				v7 = steerLeader(self, bird, flock, lastAnchorPosition)
			else
				v7 = steerFollower(self, bird, flock)
			end

			integrate(bird, v7, v2)
			updateFlap(bird, v2)
			updateScale(bird, flock, p2) -- equivalent call inferred; original call site unknown
		end
	end
end

return FlockSim