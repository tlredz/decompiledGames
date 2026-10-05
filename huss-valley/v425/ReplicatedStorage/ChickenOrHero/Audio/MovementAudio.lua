local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage.ChickenOrHero
local AudioPolicy = require(script.Parent.AudioPolicy)
local AnimationConfig = require(chickenOrHero.Animation.AnimationConfig)
local MovementProfiles = require(chickenOrHero.Movement.MovementProfiles)
local MovementAudio = {}
MovementAudio.__index = MovementAudio
local v = {}

for _, v2 in {
	"Walk",
	"Run",
	"Left",
	"Right",
	"Back"
} do
	v["CoH_" .. v2] = true
	v[AnimationConfig.PublishedIds[v2]] = true
end

function MovementAudio.new(playback, cfg)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true
	return (setmetatable({
		playback = playback,
		cfg = cfg,
		records = {},
		params = raycastParams
	}, MovementAudio))
end

function MovementAudio:remove(p2)
	local record = self.records[p2]

	if not record then
		return
	end

	local coHAudioEmitter = record.root:FindFirstChild("CoHAudioEmitter")

	if coHAudioEmitter then
		coHAudioEmitter:Destroy()
	end

	self.records[p2] = nil
end

function MovementAudio:newRecord(p, instance, root, p3)
	self:remove(p)
	local v2 = {
		character = instance,
		root = root,
		h = p3,
		lastPosition = root.Position,
		reset = instance:GetAttribute("MovementReset"),
		lastMode = instance:GetAttribute("MovementState"),
		lastAction = instance:GetAttribute("AnimationAction"),
		dashCount = instance:GetAttribute("DashCount") or 0,
		tackleStarted = instance:GetAttribute("TackleStartedAt"),
		lastReady = instance:GetAttribute("DashReady"),
		wasMoving = false,
		wasGrounded = true,
		airTime = 0,
		fallSpeed = 0,
		stepDistance = 0,
		lastStep = -1e999,
		lastJump = false,
		health = p3.Health
	}
	self.records[p] = v2

	if p == localPlayer then
		self.playback:one("Respawn")
	end

	return v2
end

function MovementAudio:step(state, p2, p3, p4, lastStep)
	if lastStep - state.lastStep < self.cfg.MinStepInterval then
		return
	end

	local v2 = "Footstep" .. p3

	if not self.playback:template(v2) then
		v2 = "Footstep" .. self.cfg.DefaultSurface
	end

	local playback = self.playback
	local v3

	if p2 ~= localPlayer then
		v3 = state.root or nil
	end

	playback:one(v2, v3, p4, 1 + (math.random() - 0.5) * 0.08)
	state.lastStep = lastStep
end

function MovementAudio:update(p)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local cfg = self.cfg
	local playback = self.playback
	local characters = {}
	local v2 = {}

	for _, v3 in Players:GetPlayers() do
		local character = v3.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if character then
			table.insert(characters, character)
		end

		if not (humanoidRootPart and humanoid) then
			continue
		end

		local magnitude = (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude

		if v3 == localPlayer or magnitude <= cfg.RemoteActionDistance then
			table.insert(v2, {
				p = v3,
				c = character,
				root = humanoidRootPart,
				h = humanoid,
				distance = v3 == localPlayer and -1 or magnitude
			})
		end
	end

	table.sort(v2, function(a, b)
		return a.distance < b.distance
	end)
	self.params.FilterDescendantsInstances = characters
	local v3 = {}
	local v4 = false
	local v5 = 0

	for k, v6 in v2 do
		if cfg.MaxNearbyCharacters < k then
			break
		end

		local p2 = v6.p
		local c = v6.c
		local root = v6.root
		local h = v6.h
		v3[p2] = true
		local usedCatch = p2 == localPlayer
		local record = self.records[p2]

		if not record or record.character ~= c or record.root ~= root then
			record = self:newRecord(p2, c, root, h)
		end

		local now = os.clock()
		local serverTimeNow = workspace:GetServerTimeNow()
		local maxSpeed = MovementProfiles.get(p2:GetAttribute("GameRole"), p2).MaxSpeed
		local assemblyLinearVelocity = root.AssemblyLinearVelocity
		local magnitude = (assemblyLinearVelocity * createVector(1, 0, 1)).Magnitude
		local movementReset = c:GetAttribute("MovementReset")
		local v8 = (root.Position - record.lastPosition).Magnitude > math.max(8, maxSpeed * p * 3)
		record.lastPosition = root.Position

		if movementReset ~= record.reset or v8 then
			record.reset = movementReset
			record.stepDistance = 0
			record.track = nil
			record.phase = nil
			record.airTime = 0
			record.fallSpeed = 0
			record.wasMoving = false
			record.usedBoost = false
			record.usedCatch = false
			record.silentUntil = now + 0.2
		end

		local v9 = now < (record.silentUntil or 0)
		local tackleActive = c:GetAttribute("TackleActive") == true
		local tackleStartedAt = c:GetAttribute("TackleStartedAt")

		if tackleStartedAt and tackleStartedAt ~= record.tackleStarted then
			record.tackleStarted = tackleStartedAt
			record.diveLanded = false
			record.usedCatch = usedCatch

			if not c:GetAttribute("DaggerEquipped") then
				local v11

				if not (usedCatch or not root) then
					v11 = root
				end

				playback:one("DiveStart", v11, usedCatch and 1 or cfg.RemoteMovementGain)
			end
		end

		if tackleActive and tackleStartedAt and not record.diveLanded and serverTimeNow - tackleStartedAt >= (c:GetAttribute("TackleDuration") or 0.4) then
			record.diveLanded = true
			local v11

			if not (usedCatch or not root) then
				v11 = root
			end

			playback:one("DiveLand", v11, usedCatch and 1 or cfg.RemoteMovementGain)
			local v13

			if not (usedCatch or not root) then
				v13 = root
			end

			playback:one("DiveRecover", v13, usedCatch and 1 or cfg.RemoteMovementGain)
		end

		if usedCatch and record.usedCatch and not tackleActive and p2:GetAttribute("RunState") == "Active" and (p2:GetAttribute("TackleReadyAt") or 1e999) <= serverTimeNow then
			playback:one("CatchReady")
			record.usedCatch = false
		end

		local movementState = c:GetAttribute("MovementState")
		local animationAction = c:GetAttribute("AnimationAction")
		local state = h:GetState()
		local v10

		if state == Enum.HumanoidStateType.Swimming or state == Enum.HumanoidStateType.Climbing then
			v10 = false
		else
			v10 = state ~= Enum.HumanoidStateType.Physics
		end

		if v10 then
			if h.Health > 0 then
				v10 = not (root.Anchored or h.Sit or h.PlatformStand or c:GetAttribute("MovementLocked") or tackleActive or v9)
			else
				v10 = false
			end
		end

		self.params.CollisionGroup = root.CollisionGroup
		local raycastResult = v10 and workspace:Raycast(root.Position, createVector(0, -4.5, 0), self.params)
		local wasGrounded = (h.FloorMaterial ~= Enum.Material.Air or not usedCatch and raycastResult and root.Position.Y - raycastResult.Position.Y <= 3.65) and true or false

		if usedCatch then
			local dashCount = c:GetAttribute("DashCount") or 0

			if record.dashCount < dashCount and v10 then
				playback:one("BoostStart")
				record.usedBoost = true
			end

			record.dashCount = dashCount

			if movementState == "Recovering" and record.lastMode ~= "Recovering" and v10 then
				playback:one("BoostRecovery")
			end

			local dashReady = c:GetAttribute("DashReady") == true

			if dashReady and not record.lastReady and record.usedBoost and v10 then
				playback:one("BoostReady")
				record.usedBoost = false
			end

			record.lastReady = dashReady

			if animationAction == "Stop" and record.lastAction ~= "Stop" and v10 then
				playback:one("RunStop")
			end

			if h.Health <= 0 and record.health > 0 then
				playback:one("Death")
			end

			local lastJump = h:GetState() == Enum.HumanoidStateType.Jumping

			if lastJump and not record.lastJump and v10 then
				playback:one("Jump")
			end

			record.lastJump = lastJump

			if v10 and not wasGrounded then
				record.airTime += p
				record.fallSpeed = math.max(record.fallSpeed, -assemblyLinearVelocity.Y)
			elseif wasGrounded and not record.wasGrounded then
				if v10 and record.airTime >= cfg.MinFallTime then
					playback:one(record.fallSpeed >= cfg.HardLandingSpeed and playback:template("LandHard") and "LandHard" or "LandSoft")
				end

				record.airTime = 0
				record.fallSpeed = 0
			elseif not v10 then
				record.airTime = 0
				record.fallSpeed = 0
			end
		end

		if v10 then
			if wasGrounded then
				if cfg.MinStepSpeed <= magnitude then
					v10 = animationAction ~= "Stop"
				else
					v10 = false
				end
			else
				v10 = wasGrounded
			end
		end

		local track = nil
		local weightCurrent = 0
		local v13 = false

		if v10 then
			local animator = h:FindFirstChildOfClass("Animator")

			if animator then
				for _, v14 in animator:GetPlayingAnimationTracks() do
					local animationId = v14.Animation and v14.Animation.AnimationId

					if v14.Name == "CoH_Stop" or animationId == AnimationConfig.PublishedIds.Stop then
						v13 = v14.WeightCurrent > 0.2 or v13
					end

					if not ((v[v14.Name] or v[animationId]) and v14.Length > 0 and weightCurrent < v14.WeightCurrent) then
						continue
					end

					weightCurrent = v14.WeightCurrent
					track = v14
				end
			end
		end

		local wasMoving = v10 and not v13

		if usedCatch then
			if wasMoving and not record.wasMoving and (record.lastSpeed or 0) < cfg.MinStepSpeed and not v9 then
				playback:one("MovementStart")
			end

			if wasMoving and maxSpeed * 0.5 <= magnitude and movementState ~= "Boosting" and movementState ~= "Dashing" then
				local unit = (assemblyLinearVelocity * createVector(1, 0, 1)).Unit

				if record.direction and unit:Dot(record.direction) < 0.25881904510252074 and now - (record.turnAt or 0) > 0.6 then
					playback:one("SharpTurn")
					record.turnAt = now
				end

				record.direction = unit
			else
				record.direction = nil
			end

			v5 = math.clamp(magnitude / maxSpeed, 0, 1.3)
			v4 = wasMoving
		end

		if wasMoving and (usedCatch or v6.distance <= cfg.RemoteFootstepDistance) then
			local surface = AudioPolicy.surface(
				raycastResult and raycastResult.Material or h.FloorMaterial,
				raycastResult and raycastResult.Instance,
				cfg
			)
			local v15 = (usedCatch and 1 or cfg.RemoteFootstepGain) * math.clamp(
				0.6 + magnitude / maxSpeed * 0.4,
				0.6,
				1
			)

			if track and weightCurrent > 0.1 then
				local phase = track.TimePosition / track.Length % 1

				if record.track == track and AudioPolicy.crossed(record.phase, phase, cfg.FootstepPhases) then
					self:step(record, p2, surface, v15, now)
				end

				record.track = track
				record.phase = phase
				record.stepDistance = 0
			else
				record.track = nil
				record.phase = nil
				record.stepDistance += magnitude * p

				if record.stepDistance >= cfg.FallbackStepDistance then
					record.stepDistance %= cfg.FallbackStepDistance
					self:step(record, p2, surface, v15, now)
				end
			end
		else
			record.track = nil
			record.phase = nil
			record.stepDistance = 0
		end

		record.lastMode = movementState
		record.lastAction = animationAction
		record.health = h.Health
		record.wasMoving = wasMoving
		record.wasGrounded = wasGrounded
		record.lastSpeed = magnitude
	end

	playback:loop("Clothes", v4 and "ClothesRustle" or nil, nil, v5 * 0.5 + 0.5, (math.clamp(v5, 0.7, 1.2)))
	playback:loop("Wind", v4 and "SprintWind" or nil, nil, math.clamp((v5 - 0.7) / 0.3, 0, 1), 1)

	for k in self.records do
		if not v3[k] then
			self:remove(k)
		end
	end
end

function MovementAudio:destroy()
	for k in self.records do
		self:remove(k)
	end

	self.playback:loop("Clothes", nil)
	self.playback:loop("Wind", nil)
end

return MovementAudio