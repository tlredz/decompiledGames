local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("Players")
local SoundPool = require(ReplicatedStorage.Modules.Audio.SoundPool)
local soundPool = SoundPool.SoundPool
local SoundGroupManager = require(ReplicatedStorage.Modules.Audio.SoundGroupManager)
local FootstepMixer = require(ReplicatedStorage.Modules.Audio.FootstepMixer)
local MonsterSoundController = {}
MonsterSoundController.__index = MonsterSoundController
local v = {
	DyleMonster = true
}
local v2 = {
	BobetteMonster = {
		useTimeBasedFootsteps = false,
		playbackSpeedMin = 1.4,
		playbackSpeedMax = 1.45
	},
	SproutMonster = {
		useTimeBasedFootsteps = false,
		playbackSpeedMin = 1.4,
		playbackSpeedMax = 1.45
	}
}

function MonsterSoundController.new(monster, options)
	if v[monster.Name] then
		return nil
	end

	local object = setmetatable({}, MonsterSoundController)
	object.monster = monster
	object.config = options or {}
	object.humanoidRootPart = monster:WaitForChild("HumanoidRootPart", 5)
	object.humanoid = monster:WaitForChild("Humanoid", 5)
	object.animator = object.humanoid and object.humanoid:WaitForChild("Animator", 5)

	if not (object.humanoidRootPart and object.humanoid and object.animator) then
		warn("MonsterSoundController: Failed to find essential components for", monster.Name)
		return nil
	end

	object.activeSounds = {}
	object.soundPools = {}
	object.connectedTracks = {}
	object.connections = {}
	object.emit = false
	object.lastFootstepTick = 0
	object:discoverSounds()
	object:discoverParticles()
	object:discoverStates()
	object:setupAnimationSystem()
	object:setupStateListeners()
	return object
end

function MonsterSoundController:discoverSounds()
	self.sounds = {}
	self.footstepPools = {}

	for _, childName in ipairs({
		"Footstep",
		"Footstep2",
		"Footstep3",
		"Footstep4",
		"Footstep5",
		"Attack",
		"Attack_1",
		"Attack_2",
		"Attack_3",
		"Growl",
		"Bark",
		"Frustrated",
		"Song",
		"RandomGrowl1",
		"RandomGrowl2",
		"RandomGrowl3",
		"RandomGrowl4",
		"GrowlLoop",
		"Dyle_Twisted_Slither_Loop",
		"SpottedSound",
		"SpottedSound2",
		"SpottedSound3",
		"LostInterestSound",
		"LostInterestSound2",
		"LostInterestSound3",
		"IdleAmbient",
		"GroundedHappy",
		"GroundedAngry",
		"EmergenceSound",
		"FeedingSound",
		"RageSound",
		"ElectricTick",
		"ElectricTick2",
		"ElectricTick3",
		"ElectricTick4",
		"FireLoop",
		"ChargeUp",
		"Spotted",
		"Shatter",
		"Shatter2",
		"Explode",
		"Pop",
		"Break",
		"Steal",
		"Sound",
		"Create"
	}) do
		local sound = self.humanoidRootPart:FindFirstChild(childName)

		if not (sound and sound:IsA("Sound")) then
			continue
		end

		self.sounds[childName] = sound
		local v3 = childName:find("Footstep") and 4 or 3
		local v4 = soundPool.new(sound, v3)
		self.soundPools[childName] = v4

		if childName:find("^Footstep") then
			table.insert(self.footstepPools, v4)
		end
	end

	if self.config.DebugEnabled then
		print("MonsterSoundController: Discovered sounds for", self.monster.Name)

		for k, _ in pairs(self.sounds) do
			print("  -", k)
		end
	end

	self:preloadSounds()
end

function MonsterSoundController:preloadSounds()
	local sounds = {}

	for _, sound in pairs(self.sounds) do
		table.insert(sounds, sound)
	end

	if #sounds == 0 then
		return
	end

	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync(sounds)
		end)

		if self.config.DebugEnabled then
			print(string.format("[MonsterSoundController] Preloaded %d sounds for %s", #sounds, self.monster.Name))
		end
	end)
end

function MonsterSoundController:discoverParticles()
	self.particles = {}
	local v3 = {
		{
			path = "HumanoidRootPart.Particles",
			name = "RootParticles1"
		},
		{
			path = "HumanoidRootPart.Particles2",
			name = "RootParticles2"
		},
		{
			path = "Torso.Particles",
			name = "TorsoParticles1"
		},
		{
			path = "Head.Particles",
			name = "HeadParticles1"
		},
		{
			path = "Head_geo.Particles",
			name = "HeadGeoParticles1"
		},
		{
			path = "LeftHand.Particles",
			name = "LeftHandParticles1"
		},
		{
			path = "LeftLowerArm.Particles",
			name = "LeftArmParticles1"
		},
		{
			path = "RightHand.Particles",
			name = "RightHandParticles1"
		},
		{
			path = "RightLowerArm.Particles",
			name = "RightArmParticles1"
		}
	}
	local quickLinks = self.monster:FindFirstChild("QuickLinks")

	if quickLinks then
		for _, objectValue in pairs(quickLinks:GetChildren()) do
			if not (objectValue:IsA("ObjectValue") and objectValue.Value) then
				continue
			end

			local value = objectValue.Value
			local particles = value:FindFirstChild("Particles")

			if particles then
				table.insert(v3, {
					path = value.Name .. ".Particles",
					name = value.Name .. "Particles1",
					directRef = particles
				})
			end
		end
	end

	for _, v4 in ipairs(v3) do
		local directRef

		if v4.directRef then
			directRef = v4.directRef
		else
			local v5 = string.split(v4.path, ".")
			directRef = self.monster

			for _, childName in ipairs(v5) do
				directRef = directRef:FindFirstChild(childName)

				if not directRef then
					break
				end
			end
		end

		if not directRef then
			continue
		end

		local particleEmitter = directRef:FindFirstChild("ParticleEmitter")
		local particleEmitter2 = directRef:FindFirstChild("ParticleEmitter2")

		if particleEmitter then
			self.particles[v4.name] = particleEmitter
		end

		if particleEmitter2 then
			self.particles[v4.name:gsub("1$", "2")] = particleEmitter2
		end
	end

	if self.config.DebugEnabled then
		print("MonsterSoundController: Discovered particles for", self.monster.Name)

		for k, _ in pairs(self.particles) do
			print("  -", k)
		end
	end
end

function MonsterSoundController:discoverStates()
	self.stateNames = {
		"Attacking",
		"Chasing",
		"Wandering",
		"Alerted",
		"LostInterest"
	}

	if not (self.monster:FindFirstChild("Chaser") or self.monster:WaitForChild("Chaser", 5)) then
		warn("[MonsterSoundController] Monster not fully initialized (no Chaser folder):", self.monster.Name)
		return
	end

	self.stateSource = self.monster

	for _, stateName in ipairs(self.stateNames) do
		self:setupSingleStateListener(stateName)
	end
end

function MonsterSoundController:getState(attributeName)
	if self.stateSource then
		return self.stateSource:GetAttribute(attributeName) or false
	end

	return false
end

local v3 = {
	Footstep = "Footsteps",
	Footstep2 = "Footsteps",
	Footstep3 = "Footsteps",
	Footstep4 = "Footsteps",
	Footstep5 = "Footsteps",
	Attack = "MonsterCombat",
	Attack_1 = "MonsterCombat",
	Attack_2 = "MonsterCombat",
	Attack_3 = "MonsterCombat",
	Growl = "MonsterState",
	Bark = "MonsterState",
	Frustrated = "MonsterState",
	SpottedSound = "MonsterState",
	SpottedSound2 = "MonsterState",
	SpottedSound3 = "MonsterState",
	LostInterestSound = "MonsterState",
	LostInterestSound2 = "MonsterState",
	LostInterestSound3 = "MonsterState",
	Spotted = "MonsterState",
	RandomGrowl1 = "MonsterAmbient",
	RandomGrowl2 = "MonsterAmbient",
	RandomGrowl3 = "MonsterAmbient",
	RandomGrowl4 = "MonsterAmbient",
	GrowlLoop = "MonsterAmbient",
	Song = "MonsterAmbient",
	IdleAmbient = "MonsterAmbient",
	Dyle_Twisted_Slither_Loop = "MonsterAmbient",
	FireLoop = "MonsterAmbient",
	ChargeUp = "MonsterCombat",
	Shatter = "MonsterCombat",
	Shatter2 = "MonsterCombat",
	Explode = "MonsterCombat",
	Pop = "MonsterCombat",
	Break = "MonsterCombat",
	Steal = "MonsterCombat",
	Create = "MonsterCombat",
	ElectricTick = "MonsterState",
	ElectricTick2 = "MonsterState",
	ElectricTick3 = "MonsterState",
	ElectricTick4 = "MonsterState",
	Sound = "MonsterState"
}

function MonsterSoundController:playSound(p, p2)
	local sound = self.sounds[p]
	local soundPool2 = self.soundPools[p]

	if not (sound and soundPool2) then
		return nil
	end

	self:stopSound(p)
	local v4 = soundPool2:PlaySound(p2)
	local v5 = v3[p]

	if v5 and SoundGroupManager then
		SoundGroupManager.AssignSound(v4, v5)
	end

	self.activeSounds[p] = v4
	v4.Ended:Connect(function()
		if self.activeSounds[p] == v4 then
			self.activeSounds[p] = nil
		end
	end)
	return v4
end

function MonsterSoundController:stopSound(p2)
	local activeSound = self.activeSounds[p2]

	if activeSound then
		if activeSound.IsPlaying then
			activeSound:Stop()
		end

		self.activeSounds[p2] = nil
	end
end

function MonsterSoundController:playFootstepSound()
	local now = tick()

	if now - self.lastFootstepTick < 0.001 then
		return
	end

	self.lastFootstepTick = now
	local footstepPools = self.footstepPools

	if footstepPools and #footstepPools ~= 0 then
		local footstepPool = footstepPools[math.random(1, #footstepPools)]
		local v4 = v2[self.monster.Name]
		local v5 = {
			PlaybackSpeed = math.random(95, 105) / 100
		}

		if v4 and v4.playbackSpeedMin then
			local v6 = math.floor(v4.playbackSpeedMin * 100)
			local v7 = math.floor(v4.playbackSpeedMax * 100)
			v5.PlaybackSpeed = math.random(v6, v7) / 100
		end

		local v6 = footstepPool:PlaySound(v5)
		local position = self.humanoidRootPart and self.humanoidRootPart.Position

		if v6 then
			SoundGroupManager.AssignSound(v6, "Footsteps")

			if position then
				FootstepMixer.RegisterFootstep(v6, self.monster.Name, position)
			end
		end

		self:emitFootstepParticles()
	elseif self.config.DebugEnabled then
		warn("[MonsterSoundController] No Footstep sound pool for", self.monster.Name)
	end
end

function MonsterSoundController:emitFootstepParticles()
	local rootParticles1 = self.particles.RootParticles1
	local rootParticles2 = self.particles.RootParticles2

	if self.emit and rootParticles1 then
		rootParticles1:Emit(1)
	elseif rootParticles2 then
		rootParticles2:Emit(1)
	elseif rootParticles1 then
		rootParticles1:Emit(1)
	end

	self.emit = not self.emit
end

function MonsterSoundController:setupAnimationSystem()
	local v4 = v2[self.monster.Name]

	if v4 and v4.useTimeBasedFootsteps then
		self:startTimeBasedFootstepLoops(v4)
		return
	end

	self.connections.animationPlayed = self.animator.AnimationPlayed:Connect(function(p)
		self:setupAnimationMarkers(p)
	end)

	for _, v5 in ipairs(self.animator:GetPlayingAnimationTracks()) do
		self:setupAnimationMarkers(v5)
	end
end

function MonsterSoundController:startTimeBasedFootstepLoops(p)
	local chasingInterval = p.chasingInterval or 0.5
	local wanderingInterval = p.wanderingInterval or 0.8
	self.connections.chasingFootstepLoop = task.spawn(function()
		local total = 0

		while total < 30 and not self.stateSource do
			task.wait(0.5)
			total += 0.5
		end

		while self.monster.Parent do
			local state = self:getState("Chasing")
			local state2 = self:getState("Alerted")

			if state or state2 then
				self:playFootstepSound()
			end

			task.wait(chasingInterval)
		end
	end)
	self.connections.wanderingFootstepLoop = task.spawn(function()
		local total = 0

		while total < 30 and not self.stateSource do
			task.wait(0.5)
			total += 0.5
		end

		while self.monster.Parent do
			local state = self:getState("Wandering")
			local state2 = self:getState("Alerted")
			local state3 = self:getState("Chasing")

			if state and not (state2 or state3) then
				self:playFootstepSound()
			end

			task.wait(wanderingInterval)
		end
	end)
end

local v4 = { "StepSound", "Step", "StepRun" }

function MonsterSoundController:setupAnimationMarkers(object2)
	if self.connectedTracks[object2] then
		return
	end

	self.connectedTracks[object2] = true
	local v5 = false

	for _, v6 in ipairs(v4) do
		local v7 = v6
		pcall(function()
			object2:GetMarkerReachedSignal(v7):Connect(function()
				if self:shouldPlayFootstep() then
					v5 = true
					self:playFootstepSound()
				end
			end)
		end)
	end

	task.delay(0.3, function()
		if not v5 then
			self:implementTimeBasedFootsteps(object2)
		end
	end)
end

function MonsterSoundController:implementTimeBasedFootsteps(data)
	local name = data.Animation.Name or ""

	if not (name:lower():match("walk") or name:lower():match("run") or name:lower():match("move")) then
		return
	end

	local timePosition = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not data.IsPlaying then
			heartbeatConnection:Disconnect()
			return
		end

		local timePosition2 = data.TimePosition

		if timePosition + 0.5 < timePosition2 then
			timePosition = data.TimePosition

			if self:shouldPlayFootstep() then
				self:playFootstepSound()
			end
		end
	end)
end

function MonsterSoundController:shouldPlayFootstep()
	local state = self:getState("Chasing")
	local state2 = self:getState("Alerted")
	local state3 = self:getState("Wandering")
	return state or state2 or state3 and not state2
end

function MonsterSoundController:setupSingleStateListener(value)
	if not self.stateSource then
		return
	end

	local lower = value:lower()

	if self.connections[lower] then
		return
	end

	if value == "Attacking" then
		self.connections[lower] = self.stateSource:GetAttributeChangedSignal("Attacking"):Connect(function()
			if self.stateSource:GetAttribute("Attacking") then
				self:handleAttacking()
			end
		end)
	elseif value == "Chasing" then
		self.connections[lower] = self.stateSource:GetAttributeChangedSignal("Chasing"):Connect(function()
			self:handleChasing((self.stateSource:GetAttribute("Chasing")))
		end)
	elseif value == "Alerted" then
		self.connections[lower] = self.stateSource:GetAttributeChangedSignal("Alerted"):Connect(function()
			if self.stateSource:GetAttribute("Alerted") then
				self:handleAlerted()
			end
		end)
	end
end

function MonsterSoundController:setupLostInterestSoundListener()
	local events = ReplicatedStorage:FindFirstChild("Events")
	local animateTower = events and events:FindFirstChild("AnimateTower")

	if animateTower then
		self.connections.lostInterestSound = animateTower.OnClientEvent:Connect(function(p, p2)
			if p == self.monster and p2 == "LostInterest" then
				self:handleLostInterest()
			end
		end)
	else
		warn("[MonsterSoundController] AnimateTower event missing — give-up sound disabled for", self.monster.Name)
	end
end

function MonsterSoundController:setupStateListeners()
	self:setupLostInterestSoundListener()
	self:startAmbientSounds()
end

function MonsterSoundController:handleAttacking()
	local v5

	if self.sounds.Attack_1 and self.sounds.Attack_2 and self.sounds.Attack_3 then
		if not self.currentAttackIndex then
			self.currentAttackIndex = 1
		end

		v5 = ({ "Attack_1", "Attack_2", "Attack_3" })[self.currentAttackIndex]
		self.currentAttackIndex = self.currentAttackIndex % 3 + 1
	else
		v5 = "Attack"
	end

	if v5 then
		self:playSound(v5)
	end

	self:playSound("Growl")
	task.wait(0.15)
	self:enableAttackParticles(true)
	task.wait(0.75)
	self:enableAttackParticles(false)
end

function MonsterSoundController:enableAttackParticles(enabled)
	for _, v5 in ipairs({
		"TorsoParticles1",
		"TorsoParticles2",
		"HeadParticles1",
		"HeadParticles2",
		"HeadGeoParticles1",
		"HeadGeoParticles2",
		"LeftHandParticles1",
		"LeftHandParticles2",
		"LeftArmParticles1",
		"LeftArmParticles2",
		"RightHandParticles1",
		"RightHandParticles2",
		"RightArmParticles1",
		"RightArmParticles2"
	}) do
		local particle = self.particles[v5]

		if particle then
			particle.Enabled = enabled
		end
	end
end

function MonsterSoundController:handleChasing(p)
	if p then
		if not self.barkDebounce then
			self.barkDebounce = true

			if self.sounds.Bark then
				local v5 = {}

				if self.monster.Name:find("Sprout") then
					v5.TimePosition = 0.15
				end

				self:playSound("Bark", v5)
			end

			local barkCooldown = self.config.BarkCooldown or 12
			task.delay(barkCooldown, function()
				self.barkDebounce = false
			end)
		end

		if self.sounds.GrowlLoop then
			local growlLoop = self.sounds.GrowlLoop

			if not growlLoop.Playing then
				growlLoop:Play()
			end
		end
	elseif self.sounds.GrowlLoop then
		self.sounds.GrowlLoop:Stop()
	end
end

function MonsterSoundController:handleAlerted()
	if self.sounds.SpottedSound then
		local v5 = {}

		if self.sounds.SpottedSound then
			table.insert(v5, "SpottedSound")
		end

		if self.sounds.SpottedSound2 then
			table.insert(v5, "SpottedSound2")
		end

		if self.sounds.SpottedSound3 then
			table.insert(v5, "SpottedSound3")
		end

		if #v5 > 0 then
			self:playSound(v5[math.random(1, #v5)])
		end
	else
		self:playSound("Growl")
	end
end

function MonsterSoundController:handleLostInterest()
	local v5 = nil

	if self.sounds.LostInterestSound then
		local v6 = {}

		if self.sounds.LostInterestSound then
			table.insert(v6, "LostInterestSound")
		end

		if self.sounds.LostInterestSound2 then
			table.insert(v6, "LostInterestSound2")
		end

		if self.sounds.LostInterestSound3 then
			table.insert(v6, "LostInterestSound3")
		end

		if #v6 > 0 then
			v5 = v6[math.random(1, #v6)]
		end
	else
		v5 = self.sounds.Frustrated and "Frustrated" or v5
	end

	local v6

	if v5 then
		v6 = self:playSound(v5) or nil
	end

	self:_debugLoseSight(v5, v6)
end

function MonsterSoundController:_debugLoseSight(_, _) end

function MonsterSoundController:startAmbientSounds()
	self.connections.ambientLoop = task.spawn(function()
		while self.monster.Parent do
			task.wait(math.random(18, 25))

			if not self:getState("Wandering") then
				continue
			end

			local v5 = {}

			if self.sounds["RandomGrowl" .. 1] then
				table.insert(v5, "RandomGrowl" .. 1)
			end

			if self.sounds["RandomGrowl" .. 2] then
				table.insert(v5, "RandomGrowl" .. 2)
			end

			if self.sounds["RandomGrowl" .. 3] then
				table.insert(v5, "RandomGrowl" .. 3)
			end

			if self.sounds["RandomGrowl" .. 4] then
				table.insert(v5, "RandomGrowl" .. 4)
			end

			if not (#v5 > 0) then
				continue
			end

			local v6 = v5[math.random(1, #v5)]
			local activeSound = self.activeSounds[v6]

			if not (activeSound and activeSound.IsPlaying) then
				self:playSound(v6)
			end
		end
	end)

	if self.sounds.Song and self.monster.Name == "DandyMonster" then
		self:playSound("Song")
	end
end

function MonsterSoundController:cleanup()
	for k, _ in pairs(self.activeSounds) do
		self:stopSound(k)
	end

	for _, connection in pairs(self.connections) do
		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		elseif typeof(connection) == "thread" then
			task.cancel(connection)
		end
	end

	for _, soundPool2 in pairs(self.soundPools) do
		soundPool2:Destroy()
	end

	self.activeSounds = {}
	self.soundPools = {}
	self.connectedTracks = {}
	self.connections = {}
end

return MonsterSoundController