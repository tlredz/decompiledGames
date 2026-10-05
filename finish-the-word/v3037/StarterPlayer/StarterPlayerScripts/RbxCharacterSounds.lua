local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local AtomicBinding = require(script:WaitForChild("AtomicBinding"))

-- equivalent calls inferred from this helper; original call sites unknown
local function loadFlag(p: string)
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled(p)
	end)
	return success and result
end

local flag2 = loadFlag("UserSoundsUseRelativeVelocity2") -- equivalent call inferred; original call site unknown
local flag3 = loadFlag("UserNewCharacterSoundsApi3") -- equivalent call inferred; original call site unknown
local flag4 = loadFlag("UserFixCharSoundsEmitters") -- equivalent call inferred; original call site unknown
local v7 = {
	Climbing = {
		SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3",
		Looped = true
	},
	Died = {
		SoundId = "rbxasset://sounds/uuhhh.mp3"
	},
	FreeFalling = {
		SoundId = "rbxasset://sounds/action_falling.ogg",
		Looped = true
	},
	GettingUp = {
		SoundId = "rbxasset://sounds/action_get_up.mp3"
	},
	Jumping = {
		SoundId = "rbxassetid://98960810548701"
	},
	Landing = {
		SoundId = "rbxasset://sounds/action_jump_land.mp3"
	},
	Running = {
		SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3",
		Looped = true,
		Pitch = 1.85
	},
	Splash = {
		SoundId = "rbxasset://sounds/impact_water.mp3"
	},
	Swimming = {
		SoundId = "rbxasset://sounds/action_swim.mp3",
		Looped = true,
		Pitch = 1.6
	}
}
local v8 = {
	Climbing = {
		AssetId = "rbxasset://sounds/action_footsteps_plastic.mp3",
		Looping = true
	},
	Died = {
		AssetId = "rbxasset://sounds/uuhhh.mp3"
	},
	FreeFalling = {
		AssetId = "rbxasset://sounds/action_falling.ogg",
		Looping = true
	},
	GettingUp = {
		AssetId = "rbxasset://sounds/action_get_up.mp3"
	},
	Jumping = {
		AssetId = "rbxasset://sounds/action_jump.mp3"
	},
	Landing = {
		AssetId = "rbxasset://sounds/action_jump_land.mp3"
	},
	Running = {
		AssetId = "rbxasset://sounds/action_footsteps_plastic.mp3",
		Looping = true,
		PlaybackSpeed = 1.85
	},
	Splash = {
		AssetId = "rbxasset://sounds/impact_water.mp3"
	},
	Swimming = {
		AssetId = "rbxasset://sounds/action_swim.mp3",
		Looping = true,
		PlaybackSpeed = 1.6
	}
}

local function map(p: number, p2: number, p3: number, p4: number, p5: number)
	return (p - p2) * (p5 - p4) / (p3 - p2) + p4
end

local function getRelativeVelocity(controllerManager, p)
	if not controllerManager then
		return p
	end

	local groundSensor = controllerManager.ActiveController and (controllerManager.ActiveController:IsA("GroundController") and controllerManager.GroundSensor or controllerManager.ActiveController:IsA("ClimbController") and controllerManager.ClimbSensor)

	if groundSensor and groundSensor.SensedPart then
		return p - groundSensor.SensedPart:GetVelocityAtPosition(controllerManager.RootPart.Position)
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(audioPlayer, flag: boolean?)
	if not flag then
		audioPlayer.TimePosition = 0
	end

	if flag3 and audioPlayer:IsA("AudioPlayer") then
		audioPlayer:Play()
	else
		audioPlayer.Playing = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopSound(audioPlayer)
	if flag3 and audioPlayer:IsA("AudioPlayer") then
		audioPlayer:Stop()
	else
		audioPlayer.Playing = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSoundIf(audioPlayer, playing: boolean)
	if flag3 and audioPlayer:IsA("AudioPlayer") then
		if audioPlayer.IsPlaying and not playing then
			audioPlayer:Stop()
		elseif not audioPlayer.IsPlaying and playing then
			audioPlayer:Play()
		end
	else
		audioPlayer.Playing = playing
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSoundLooped(audioPlayer, flag: boolean)
	if flag3 and audioPlayer:IsA("AudioPlayer") then
		audioPlayer.Looping = flag
	else
		audioPlayer.Looped = flag
	end
end

local function shallowCopy(items)
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

local function initializeSoundSystem(p)
	local humanoid = p.humanoid
	local rootPart = p.rootPart
	local controllerManager

	if flag2 then
		controllerManager = humanoid.Parent:FindFirstChild("ControllerManager")
	else
		controllerManager = nil
	end

	local v9 = {}

	if flag3 and SoundService.CharacterSoundsUseNewApi == Enum.RolloutState.Enabled then
		local character = nil
		local rootPart2 = nil

		if flag4 then
			rootPart2 = humanoid.RootPart
		else
			character = Players.LocalPlayer.Character
		end

		local v10 = 5
		local v11 = {}

		while v10 < 150 do
			v11[v10] = 5 / v10
			v10 *= 1.25
		end

		v11[150] = 0
		local targetInstance

		if flag4 then
			targetInstance = Instance.new("AudioEmitter", rootPart2)
		else
			targetInstance = Instance.new("AudioEmitter", character)
		end

		targetInstance.Name = "RbxCharacterSoundsEmitter"
		targetInstance:SetDistanceAttenuation(v11)

		for k, v13 in pairs(v8) do
			local audioPlayer = Instance.new("AudioPlayer")
			local wire = Instance.new("Wire")
			audioPlayer.Name = k
			wire.Name = k .. "Wire"
			audioPlayer.Archivable = false
			audioPlayer.Volume = 0.65

			for k2, v14 in pairs(v13) do
				audioPlayer[k2] = v14
			end

			audioPlayer.Parent = rootPart
			wire.Parent = audioPlayer
			wire.SourceInstance = audioPlayer
			wire.TargetInstance = targetInstance
			v9[k] = audioPlayer
		end
	else
		for k, v10 in pairs(v7) do
			local sound = Instance.new("Sound")
			sound.Name = k
			sound.Archivable = false
			sound.RollOffMinDistance = 5
			sound.RollOffMaxDistance = 150
			sound.Volume = 0.65

			for k2, v11 in pairs(v10) do
				sound[k2] = v11
			end

			sound.Parent = rootPart
			v9[k] = sound
		end
	end

	local v10 = {}

	local function stopPlayingLoopedSounds(p2)
		local v12 = {}
		local v13 = p2 or nil

		for k, v14 in pairs(v10) do
			v12[k] = v14
		end

		for k in pairs(v12) do
			if k == v13 then
				continue
			end

			stopSound(k) -- equivalent call inferred; original call site unknown
			v10[k] = nil
		end
	end

	local v11 = {
		[Enum.HumanoidStateType.FallingDown] = function()
			stopPlayingLoopedSounds()
		end,
		[Enum.HumanoidStateType.GettingUp] = function()
			stopPlayingLoopedSounds()
			playSound(v9.GettingUp, false) -- equivalent call inferred; original call site unknown
		end,
		[Enum.HumanoidStateType.Jumping] = function()
			stopPlayingLoopedSounds()
			playSound(v9.Jumping, false) -- equivalent call inferred; original call site unknown
		end,
		[Enum.HumanoidStateType.Swimming] = function()
			local Y = math.abs(rootPart.AssemblyLinearVelocity.Y)

			if Y > 0.1 then
				v9.Splash.Volume = math.clamp((Y - 100) * 0.72 / 250 + 0.28, 0, 1)
				playSound(v9.Splash, false) -- equivalent call inferred; original call site unknown
			end

			stopPlayingLoopedSounds(v9.Swimming)
			playSound(v9.Swimming, true) -- equivalent call inferred; original call site unknown
			v10[v9.Swimming] = true
		end,
		[Enum.HumanoidStateType.Freefall] = function()
			v9.FreeFalling.Volume = 0
			stopPlayingLoopedSounds(v9.FreeFalling)
			setSoundLooped(v9.FreeFalling, true) -- equivalent call inferred; original call site unknown

			if v9.FreeFalling:IsA("Sound") then
				v9.FreeFalling.PlaybackRegionsEnabled = true
			end

			v9.FreeFalling.LoopRegion = NumberRange.new(2, 9)
			playSound(v9.FreeFalling, false) -- equivalent call inferred; original call site unknown
			v10[v9.FreeFalling] = true
		end,
		[Enum.HumanoidStateType.Landed] = function()
			stopPlayingLoopedSounds()
			local Y = math.abs(rootPart.AssemblyLinearVelocity.Y)

			if Y > 75 then
				v9.Landing.Volume = math.clamp((Y - 50) * 1 / 50 + 0, 0, 1)
				playSound(v9.Landing, false) -- equivalent call inferred; original call site unknown
			end
		end,
		[Enum.HumanoidStateType.Running] = function()
			stopPlayingLoopedSounds(v9.Running)
			playSound(v9.Running, true) -- equivalent call inferred; original call site unknown
			v10[v9.Running] = true
		end,
		[Enum.HumanoidStateType.Climbing] = function()
			local climbing = v9.Climbing
			local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity

			if flag2 then
				assemblyLinearVelocity = getRelativeVelocity(controllerManager, assemblyLinearVelocity)
			end

			if math.abs(assemblyLinearVelocity.Y) > 0.1 then
				playSound(climbing, true) -- equivalent call inferred; original call site unknown
				stopPlayingLoopedSounds(climbing)
			else
				stopPlayingLoopedSounds()
			end

			v10[climbing] = true
		end,
		[Enum.HumanoidStateType.Seated] = function()
			stopPlayingLoopedSounds()
		end,
		[Enum.HumanoidStateType.Dead] = function()
			stopPlayingLoopedSounds()
			playSound(v9.Died, false) -- equivalent call inferred; original call site unknown
		end
	}
	local v12 = {
		[v9.Climbing] = function(_: number, audioPlayer, vector: Vector3)
			if flag2 then
				vector = getRelativeVelocity(controllerManager, vector)
			end

			playSoundIf(audioPlayer, vector.Magnitude > 0.1) -- equivalent call inferred; original call site unknown
		end,
		[v9.FreeFalling] = function(p2: number, p3, vector: Vector3)
			if vector.Magnitude > 75 then
				p3.Volume = math.clamp(p3.Volume + p2 * 0.9, 0, 1)
			else
				p3.Volume = 0
			end
		end,
		[v9.Running] = function(_: number, audioPlayer, vector: Vector3)
			playSoundIf(audioPlayer, vector.Magnitude > 0.5 and humanoid.MoveDirection.Magnitude > 0.5) -- equivalent call inferred; original call site unknown
		end
	}
	local runningsByRunningNoPhysics = {
		[Enum.HumanoidStateType.RunningNoPhysics] = Enum.HumanoidStateType.Running
	}
	local v13 = runningsByRunningNoPhysics[humanoid:GetState()] or humanoid:GetState()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function transitionTo(p2)
		local v14 = v11[p2]

		if v14 then
			v14()
		end

		v13 = p2
	end

	transitionTo(v13) -- equivalent call inferred; original call site unknown
	local stateChangedConnection = humanoid.StateChanged:Connect(function(_, p2)
		local v15 = runningsByRunningNoPhysics[p2] or p2

		if v15 ~= v13 then
			transitionTo(v15) -- equivalent call inferred; original call site unknown
		end
	end)
	local steppedConnection = RunService.Stepped:Connect(function(_, dt: number)
		for k in pairs(v10) do
			local v15 = v12[k]

			if v15 then
				v15(dt, k, rootPart.AssemblyLinearVelocity)
			end
		end
	end)

	local function terminate()
		stateChangedConnection:Disconnect()
		steppedConnection:Disconnect()

		for _, v15 in pairs(v9) do
			v15:Destroy()
		end

		table.clear(v9)
	end

	return terminate
end

local v9 = AtomicBinding.new({
	humanoid = "Humanoid",
	rootPart = "HumanoidRootPart"
}, initializeSoundSystem)
local v10 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function characterAdded(character)
	v9:bindRoot(character)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function characterRemoving(character)
	v9:unbindRoot(character)
end

local function playerAdded(player)
	local connections = v10[player]

	if not connections then
		connections = {}
		v10[player] = connections
	end

	if player.Character then
		characterAdded(player.Character) -- equivalent call inferred; original call site unknown
	end

	table.insert(connections, player.CharacterAdded:Connect(characterAdded))
	table.insert(connections, player.CharacterRemoving:Connect(characterRemoving))
end

local function playerRemoving(player)
	local v11 = v10[player]

	if v11 then
		for _, connection in ipairs(v11) do
			connection:Disconnect()
		end

		v10[player] = nil
	end

	if player.Character then
		characterRemoving(player.Character) -- equivalent call inferred; original call site unknown
	end
end

for _, v11 in ipairs(Players:GetPlayers()) do
	task.spawn(playerAdded, v11)
end

Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoving)