game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local AtomicBinding = require(script:WaitForChild("AtomicBinding"))

local function loadFlag(p: string)
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled(p)
	end)
	return success and result
end

local v = {
	Climbing = {
		SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3",
		Looped = true
	},
	Died = {
		SoundId = "rbxasset://sounds/uuhhh.mp3"
	},
	FreeFalling = {
		SoundId = "rbxasset://sounds/action_falling.mp3",
		Looped = true
	},
	GettingUp = {
		SoundId = "rbxasset://sounds/action_get_up.mp3"
	},
	Jumping = {
		SoundId = "rbxasset://sounds/action_jump.mp3"
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
local v2 = {
	Cloud = {
		WithAccessory = {
			Muted = {
				Running = true,
				Climbing = true,
				Jumping = true,
				Landing = true,
				FreeFalling = true
			}
		}
	},
	Deathrider = {
		WithoutAccessory = {
			Muted = true
		},
		WithAccessory = {
			Sounds = {
				Idle = {
					SoundId = "rbxassetid://117646912223117",
					Looped = true
				},
				Jumping = {
					SoundId = "rbxassetid://99310107248071"
				},
				Running = {
					SoundId = "rbxassetid://86993663989611",
					Looped = true
				}
			}
		}
	}
}

local function map(p: number, p2: number, p3: number, p4: number, p5: number)
	return (p - p2) * (p5 - p4) / (p3 - p2) + p4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(p)
	p.TimePosition = 0
	p.Playing = true
end

local function shallowCopy(items)
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

local frozen = table.freeze({})
local v3 = {
	Archivable = false,
	RollOffMinDistance = 5,
	RollOffMaxDistance = 150,
	Volume = 0.65,
	Looped = false,
	PlaybackSpeed = 1,
	SoundId = ""
}

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveSoundVariant(instance)
	if not instance then
		return nil
	end

	local currentlyEquippedSword = instance:GetAttribute("CurrentlyEquippedSword")

	if typeof(currentlyEquippedSword) ~= "string" then
		return nil
	end

	local v4 = v2[currentlyEquippedSword]

	if not v4 then
		return nil
	end

	if instance:GetAttribute("HasAccessoryEquipped") then
		return v4.WithAccessory
	end

	return v4.WithoutAccessory
end

-- equivalent calls inferred from this helper; original call sites unknown
local function configureSound(p, items)
	for k, v4 in pairs(v3) do
		p[k] = v4
	end

	for k, item in pairs(items) do
		p[k] = item
	end
end

local function initializeSoundSystem(data)
	local _ = data.player
	local humanoid = data.humanoid
	local rootPart = data.rootPart
	local parent = rootPart.Parent
	local v4 = {}

	local function createSound(name: string)
		local sound = Instance.new("Sound")
		sound.Name = name
		sound.Parent = rootPart
		v4[name] = sound
		return sound
	end

	local v5 = {}
	local v6 = {}

	for k in pairs(v) do
		local sound = Instance.new("Sound")
		sound.Name = k
		sound.Parent = rootPart
		v4[k] = sound
	end

	local function applySoundProfile()
		local soundVariant = resolveSoundVariant(parent) -- equivalent call inferred; original call site unknown
		local sounds = soundVariant and soundVariant.Sounds or frozen
		local muted = soundVariant and soundVariant.Muted
		table.clear(v5)

		if muted == true then
			for k in pairs(v) do
				v5[k] = true
			end
		elseif muted then
			for k in pairs(muted) do
				v5[k] = true
			end
		end

		for k, v8 in pairs(v) do
			local v9 = v4[k]
			local playing = v9.Playing
			local volume = v9.Volume
			configureSound(v9, sounds[k] or v8) -- equivalent call inferred; original call site unknown

			if not v6[v9] then
				continue
			end

			v9.Volume = volume
			v9.Playing = playing
		end

		local idle = sounds.Idle

		if idle then
			local idle2 = v4.Idle

			if not idle2 then
				idle2 = Instance.new("Sound")
				idle2.Name = "Idle"
				idle2.Parent = rootPart
				v4.Idle = idle2
			end

			configureSound(idle2, idle) -- equivalent call inferred; original call site unknown
		elseif v4.Idle then
			v4.Idle:Destroy()
			v4.Idle = nil
		end

		for k in pairs(v5) do
			local v8 = v4[k]

			if not v8 then
				continue
			end

			v8.Playing = false
			v6[v8] = nil
		end
	end

	applySoundProfile()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopPlayingLoopedSounds(p)
		local v8 = {}

		for k, v9 in pairs(v6) do
			v8[k] = v9
		end

		for k in pairs(v8) do
			if k == p then
				continue
			end

			k.Playing = false
			v6[k] = nil
		end
	end

	local function isMutedSound(p)
		return v5[p.Name] == true
	end

	local v7 = {
		[Enum.HumanoidStateType.FallingDown] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
		end,
		[Enum.HumanoidStateType.GettingUp] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			playSound(v4.GettingUp) -- equivalent call inferred; original call site unknown
		end,
		[Enum.HumanoidStateType.Jumping] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown

			if v5[v4.Jumping.Name] ~= true then
				playSound(v4.Jumping) -- equivalent call inferred; original call site unknown
			end
		end,
		[Enum.HumanoidStateType.Swimming] = function()
			local Y = math.abs(rootPart.AssemblyLinearVelocity.Y)

			if Y > 0.1 then
				v4.Splash.Volume = math.clamp((Y - 100) * 0.72 / 250 + 0.28, 0, 1)
				playSound(v4.Splash) -- equivalent call inferred; original call site unknown
			end

			stopPlayingLoopedSounds(v4.Swimming) -- equivalent call inferred; original call site unknown
			v4.Swimming.Playing = true
			v6[v4.Swimming] = true
		end,
		[Enum.HumanoidStateType.Freefall] = function()
			v4.FreeFalling.Volume = 0

			if v5[v4.FreeFalling.Name] == true then
				stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			else
				stopPlayingLoopedSounds(v4.FreeFalling) -- equivalent call inferred; original call site unknown
				v6[v4.FreeFalling] = true
			end
		end,
		[Enum.HumanoidStateType.Landed] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown

			if v5[v4.Landing.Name] == true then
				return
			end

			local Y = math.abs(rootPart.AssemblyLinearVelocity.Y)

			if Y > 75 then
				v4.Landing.Volume = math.clamp((Y - 50) * 1 / 50 + 0, 0, 1)
				playSound(v4.Landing) -- equivalent call inferred; original call site unknown
			end
		end,
		[Enum.HumanoidStateType.Running] = function()
			stopPlayingLoopedSounds(v4.Running) -- equivalent call inferred; original call site unknown

			if v5[v4.Running.Name] ~= true then
				v4.Running.Playing = true
				v6[v4.Running] = true
			end
		end,
		[Enum.HumanoidStateType.Climbing] = function()
			local climbing = v4.Climbing

			if v5[climbing.Name] == true then
				stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			else
				if math.abs(rootPart.AssemblyLinearVelocity.Y) > 0.1 then
					climbing.Playing = true
					stopPlayingLoopedSounds(climbing) -- equivalent call inferred; original call site unknown
				else
					stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
				end

				v6[climbing] = true
			end
		end,
		[Enum.HumanoidStateType.Seated] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
		end,
		[Enum.HumanoidStateType.Dead] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			playSound(v4.Died) -- equivalent call inferred; original call site unknown
		end
	}
	local v8 = {
		[v4.Climbing] = function(_: number, p, vector: Vector3)
			p.Playing = vector.Magnitude > 0.1
		end,
		[v4.FreeFalling] = function(p: number, state, vector: Vector3)
			if v5[state.Name] == true then
				state.Volume = 0
				state.Playing = false
			elseif vector.Magnitude > 75 then
				state.Volume = math.clamp(state.Volume + p * 0.9, 0, 1)
			else
				state.Volume = 0
			end
		end,
		[v4.Running] = function(_: number, p, vector: Vector3)
			if v5[p.Name] == true then
				p.Playing = false
				return
			end

			p.Playing = vector.Magnitude > 0.5 and humanoid.MoveDirection.Magnitude > 0.5
		end
	}
	local runningsByRunningNoPhysics = {
		[Enum.HumanoidStateType.RunningNoPhysics] = Enum.HumanoidStateType.Running
	}
	local v9 = runningsByRunningNoPhysics[humanoid:GetState()] or humanoid:GetState()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function transitionTo(p)
		local v10 = v7[p]

		if v10 then
			v10()
		end

		v9 = p
	end

	transitionTo(v9) -- equivalent call inferred; original call site unknown
	local stateChangedConnection = humanoid.StateChanged:Connect(function(_, p)
		local v11 = runningsByRunningNoPhysics[p] or p

		if v11 ~= v9 then
			transitionTo(v11) -- equivalent call inferred; original call site unknown
		end
	end)
	local connections = {}

	if parent then
		for _, v11 in ipairs({ "CurrentlyEquippedSword", "HasAccessoryEquipped" }) do
			table.insert(connections, parent:GetAttributeChangedSignal(v11):Connect(applySoundProfile))
		end
	end

	local steppedConnection = RunService.Stepped:Connect(function(_, dt: number)
		local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity

		for k in pairs(v6) do
			local v11 = v8[k]

			if v11 then
				v11(dt, k, assemblyLinearVelocity)
			end
		end

		local idle = v4.Idle

		if idle then
			local playing

			if v9 == Enum.HumanoidStateType.Running and assemblyLinearVelocity.Magnitude <= 0.5 then
				playing = humanoid.MoveDirection.Magnitude <= 0.5
			else
				playing = false
			end

			if idle.Playing ~= playing then
				idle.Playing = playing
			end
		end
	end)

	local function terminate()
		stateChangedConnection:Disconnect()
		steppedConnection:Disconnect()

		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)

		for _, v11 in pairs(v4) do
			v11:Destroy()
		end

		table.clear(v4)
		table.clear(v5)
		table.clear(v6)
		table.clear(v8)
	end

	return terminate
end

local v4 = AtomicBinding.new({
	humanoid = "Humanoid",
	rootPart = "HumanoidRootPart"
}, initializeSoundSystem)
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function characterAdded(character)
	v4:bindRoot(character)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function characterRemoving(character)
	v4:unbindRoot(character)
end

local function playerAdded(player)
	local connections = v5[player]

	if not connections then
		connections = {}
		v5[player] = connections
	end

	if player.Character then
		characterAdded(player.Character) -- equivalent call inferred; original call site unknown
	end

	table.insert(connections, player.CharacterAdded:Connect(characterAdded))
	table.insert(connections, player.CharacterRemoving:Connect(characterRemoving))
end

local function playerRemoving(player)
	local v6 = v5[player]

	if v6 then
		for _, connection in ipairs(v6) do
			connection:Disconnect()
		end

		v5[player] = nil
	end

	if player.Character then
		characterRemoving(player.Character) -- equivalent call inferred; original call site unknown
	end
end

for _, v6 in ipairs(Players:GetPlayers()) do
	task.spawn(playerAdded, v6)
end

Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoving)