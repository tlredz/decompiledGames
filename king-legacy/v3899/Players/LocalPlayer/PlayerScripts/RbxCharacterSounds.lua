local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local AtomicBinding = require(script:WaitForChild("AtomicBinding"))

-- equivalent calls inferred from this helper; original call sites unknown
local function loadFlag(p: string)
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled(p)
	end)
	return success and result
end

local flag = loadFlag("UserAtomicCharacterSoundsUnparent") -- equivalent call inferred; original call site unknown
local v3 = {
	Climbing = {
		SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3",
		Looped = true
	},
	Died = {
		SoundId = "rbxassetid://11636216579"
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
		SoundId = "rbxassetid://12116025240"
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

local function initializeSoundSystem(data)
	local _ = data.player
	local humanoid = data.humanoid
	local rootPart = data.rootPart
	local v4 = {}

	if not rootPart:FindFirstChild("Swim") then
		for k, v5 in pairs(v3) do
			local sound = Instance.new("Sound")
			sound.Name = k
			sound.Archivable = false
			sound.RollOffMinDistance = 5
			sound.RollOffMaxDistance = 150
			sound.Volume = 0.65

			for k2, v6 in pairs(v5) do
				sound[k2] = v6
			end

			sound.Parent = rootPart
			v4[k] = sound
		end
	end

	local v5 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopPlayingLoopedSounds(p)
		local v7 = {}

		for k, v8 in pairs(v5) do
			v7[k] = v8
		end

		for k in pairs(v7) do
			if k == p then
				continue
			end

			k.Playing = false
			v5[k] = nil
		end
	end

	local v6 = {
		[Enum.HumanoidStateType.FallingDown] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
		end,
		[Enum.HumanoidStateType.GettingUp] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			playSound(v4.GettingUp) -- equivalent call inferred; original call site unknown
		end,
		[Enum.HumanoidStateType.Jumping] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			playSound(v4.Jumping) -- equivalent call inferred; original call site unknown
		end,
		[Enum.HumanoidStateType.Swimming] = function()
			local Y = math.abs(rootPart.AssemblyLinearVelocity.Y)

			if Y > 0.1 then
				v4.Splash.Volume = math.clamp((Y - 100) * 0.72 / 250 + 0.28, 0, 1)
				playSound(v4.Splash) -- equivalent call inferred; original call site unknown
			end

			stopPlayingLoopedSounds(v4.Swimming) -- equivalent call inferred; original call site unknown
			v4.Swimming.Playing = true
			v5[v4.Swimming] = true
		end,
		[Enum.HumanoidStateType.Freefall] = function()
			v4.FreeFalling.Volume = 0
			stopPlayingLoopedSounds(v4.FreeFalling) -- equivalent call inferred; original call site unknown
			v5[v4.FreeFalling] = true
		end,
		[Enum.HumanoidStateType.Landed] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			local Y = math.abs(rootPart.AssemblyLinearVelocity.Y)

			if Y > 75 then
				v4.Landing.Volume = math.clamp((Y - 50) * 1 / 50 + 0, 0, 1)
				playSound(v4.Landing) -- equivalent call inferred; original call site unknown
			end
		end,
		[Enum.HumanoidStateType.Running] = function()
			stopPlayingLoopedSounds(v4.Running) -- equivalent call inferred; original call site unknown
			v4.Running.Playing = true
			v5[v4.Running] = true
		end,
		[Enum.HumanoidStateType.Climbing] = function()
			local climbing = v4.Climbing

			if math.abs(rootPart.AssemblyLinearVelocity.Y) > 0.1 then
				climbing.Playing = true
				stopPlayingLoopedSounds(climbing) -- equivalent call inferred; original call site unknown
			else
				stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			end

			v5[climbing] = true
		end,
		[Enum.HumanoidStateType.Seated] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
		end,
		[Enum.HumanoidStateType.Dead] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			playSound(v4.Died) -- equivalent call inferred; original call site unknown
		end
	}
	local v7 = {
		[v4.Climbing] = function(_: number, p, vector: Vector3)
			p.Playing = vector.Magnitude > 0.1
		end,
		[v4.FreeFalling] = function(p: number, p2, vector: Vector3)
			if vector.Magnitude > 75 then
				p2.Volume = math.clamp(p2.Volume + p * 0.9, 0, 1)
			else
				p2.Volume = 0
			end
		end,
		[v4.Running] = function(_: number, p, vector: Vector3)
			p.Playing = vector.Magnitude > 0.5 and humanoid.MoveDirection.Magnitude > 0.5
		end
	}
	local runningsByRunningNoPhysics = {
		[Enum.HumanoidStateType.RunningNoPhysics] = Enum.HumanoidStateType.Running
	}
	local v8 = runningsByRunningNoPhysics[humanoid:GetState()] or humanoid:GetState()
	local stateChangedConnection = humanoid.StateChanged:Connect(function(_, p)
		local v9 = runningsByRunningNoPhysics[p] or p

		if v9 ~= v8 then
			local v10 = v6[v9]

			if v10 then
				v10()
			end

			v8 = v9
		end
	end)
	local steppedConnection = RunService.Stepped:Connect(function(_, dt: number)
		for k in pairs(v5) do
			local v9 = v7[k]

			if v9 then
				v9(dt, k, rootPart.AssemblyLinearVelocity)
			end
		end
	end)

	local function terminate()
		stateChangedConnection:Disconnect()
		steppedConnection:Disconnect()

		if flag then
			for _, v9 in pairs(v4) do
				v9:Destroy()
			end

			table.clear(v4)
		end
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