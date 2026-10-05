local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local AtomicBinding = require(script:WaitForChild("AtomicBinding"))
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserAtomicCharacterSounds")
end)
local v = success and result
local v2 = {
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
		SoundId = "rbxassetid://7502168613"
	},
	Running = {
		SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3",
		Looped = false,
		Pitch = 0
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
	local result2 = {}

	for k, item in pairs(items) do
		result2[k] = item
	end

	return result2
end

local function initializeSoundSystem(data)
	local player = data.player
	local humanoid = data.humanoid
	local rootPart = data.rootPart
	local v3 = {}

	for k, v4 in pairs(v2) do
		local sound = Instance.new("Sound")
		sound.Name = k
		sound.Archivable = false
		sound.RollOffMinDistance = 5
		sound.RollOffMaxDistance = 150
		sound.Volume = 0.65

		for k2, v5 in pairs(v4) do
			sound[k2] = v5
		end

		sound.Parent = rootPart
		v3[k] = sound
	end

	local v4 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopPlayingLoopedSounds(p)
		local v6 = {}

		for k, v7 in pairs(v4) do
			v6[k] = v7
		end

		for k in pairs(v6) do
			if k == p then
				continue
			end

			k.Playing = false
			v4[k] = nil
		end
	end

	local v5 = {
		[Enum.HumanoidStateType.FallingDown] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
		end,
		[Enum.HumanoidStateType.GettingUp] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			playSound(v3.GettingUp) -- equivalent call inferred; original call site unknown
		end,
		[Enum.HumanoidStateType.Jumping] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			playSound(v3.Jumping) -- equivalent call inferred; original call site unknown
		end,
		[Enum.HumanoidStateType.Swimming] = function()
			local Y = math.abs(rootPart.AssemblyLinearVelocity.Y)

			if Y > 0.1 then
				v3.Splash.Volume = math.clamp((Y - 100) * 0.72 / 250 + 0.28, 0, 1)
				playSound(v3.Splash) -- equivalent call inferred; original call site unknown
			end

			stopPlayingLoopedSounds(v3.Swimming) -- equivalent call inferred; original call site unknown
			v3.Swimming.Playing = true
			v4[v3.Swimming] = true
		end,
		[Enum.HumanoidStateType.Freefall] = function()
			v3.FreeFalling.Volume = 0
			stopPlayingLoopedSounds(v3.FreeFalling) -- equivalent call inferred; original call site unknown
			v4[v3.FreeFalling] = true
		end,
		[Enum.HumanoidStateType.Landed] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			local Y = math.abs(rootPart.AssemblyLinearVelocity.Y)

			if Y > 75 then
				v3.Landing.Volume = math.clamp((Y - 50) * 1 / 50 + 0, 0, 1)
				playSound(v3.Landing) -- equivalent call inferred; original call site unknown
			end
		end,
		[Enum.HumanoidStateType.Running] = function()
			stopPlayingLoopedSounds(v3.Running) -- equivalent call inferred; original call site unknown
			v3.Running.Playing = true
			v4[v3.Running] = true
		end,
		[Enum.HumanoidStateType.Climbing] = function()
			local climbing = v3.Climbing

			if math.abs(rootPart.AssemblyLinearVelocity.Y) > 0.1 then
				climbing.Playing = true
				stopPlayingLoopedSounds(climbing) -- equivalent call inferred; original call site unknown
			else
				stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			end

			v4[climbing] = true
		end,
		[Enum.HumanoidStateType.Seated] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
		end,
		[Enum.HumanoidStateType.Dead] = function()
			stopPlayingLoopedSounds(nil) -- equivalent call inferred; original call site unknown
			playSound(v3.Died) -- equivalent call inferred; original call site unknown
		end
	}
	local v6 = {
		[v3.Climbing] = function(_: number, p, vector: Vector3)
			p.Playing = vector.Magnitude > 0.1
		end,
		[v3.FreeFalling] = function(p: number, p2, vector: Vector3)
			if vector.Magnitude > 75 then
				p2.Volume = math.clamp(p2.Volume + p * 0.9, 0, 1)
			else
				p2.Volume = 0
			end
		end,
		[v3.Running] = function(_: number, p, vector: Vector3)
			p.Playing = vector.Magnitude > 0.5 and humanoid.MoveDirection.Magnitude > 0.5
		end
	}
	local runningsByRunningNoPhysics = {
		[Enum.HumanoidStateType.RunningNoPhysics] = Enum.HumanoidStateType.Running
	}
	local v7 = runningsByRunningNoPhysics[humanoid:GetState()] or humanoid:GetState()
	local stateChangedConnection = humanoid.StateChanged:Connect(function(_, p)
		local v8 = runningsByRunningNoPhysics[p] or p

		if v8 ~= v7 then
			local v9 = v5[v8]

			if v9 then
				v9()
			end

			v7 = v8
		end
	end)
	local steppedConnection = RunService.Stepped:Connect(function(_, dt: number)
		for k in pairs(v4) do
			local v8 = v6[k]

			if v8 then
				v8(dt, k, rootPart.AssemblyLinearVelocity)
			end
		end
	end)
	local ancestryChangedConnection = nil
	local ancestryChangedConnection2 = nil
	local characterAddedConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function terminate()
		stateChangedConnection:Disconnect()
		steppedConnection:Disconnect()

		if not v then
			ancestryChangedConnection:Disconnect()
			ancestryChangedConnection2:Disconnect()
			characterAddedConnection:Disconnect()
		end
	end

	if not v then
		ancestryChangedConnection = humanoid.AncestryChanged:Connect(function(_, parent)
			if not parent then
				terminate() -- equivalent call inferred; original call site unknown
			end
		end)
		ancestryChangedConnection2 = rootPart.AncestryChanged:Connect(function(_, parent)
			if not parent then
				terminate() -- equivalent call inferred; original call site unknown
			end
		end)
		characterAddedConnection = player.CharacterAdded:Connect(terminate)
	end

	return terminate
end

if v then
	local v3 = AtomicBinding.new({
		humanoid = "Humanoid",
		rootPart = "HumanoidRootPart"
	}, initializeSoundSystem)
	local v4 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function characterAdded(character)
		v3:bindRoot(character)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function characterRemoving(character)
		v3:unbindRoot(character)
	end

	local function playerAdded(player)
		local connections = v4[player]

		if not connections then
			connections = {}
			v4[player] = connections
		end

		if player.Character then
			characterAdded(player.Character) -- equivalent call inferred; original call site unknown
		end

		table.insert(connections, player.CharacterAdded:Connect(characterAdded))
		table.insert(connections, player.CharacterRemoving:Connect(characterRemoving))
	end

	local function playerRemoving(player)
		local v5 = v4[player]

		if v5 then
			for _, connection in ipairs(v5) do
				connection:Disconnect()
			end

			v4[player] = nil
		end

		if player.Character then
			characterRemoving(player.Character) -- equivalent call inferred; original call site unknown
		end
	end

	for _, v5 in ipairs(Players:GetPlayers()) do
		task.spawn(playerAdded, v5)
	end

	Players.PlayerAdded:Connect(playerAdded)
	Players.PlayerRemoving:Connect(playerRemoving)
else
	local function waitForFirst(...)
		local bindableEvent = Instance.new("BindableEvent")
		local connections = { ... }

		local function fire(...)
			for i = 1, #connections do
				connections[i]:Disconnect()
			end

			return bindableEvent:Fire(...)
		end

		for i = 1, #connections do
			connections[i] = connections[i]:Connect(fire)
		end

		return bindableEvent.Event:Wait()
	end

	local function playerAdded(player)
		local function characterAdded(character)
			if not character.Parent then
				waitForFirst(character.AncestryChanged, player.CharacterAdded)
			end

			if player.Character ~= character or not character.Parent then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")

			while character:IsDescendantOf(game) and not humanoid do
				waitForFirst(character.ChildAdded, character.AncestryChanged, player.CharacterAdded)
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			if player.Character ~= character or not character:IsDescendantOf(game) then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			while character:IsDescendantOf(game) and not humanoidRootPart do
				waitForFirst(
					character.ChildAdded,
					character.AncestryChanged,
					humanoid.AncestryChanged,
					player.CharacterAdded
				)
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if humanoidRootPart and humanoid:IsDescendantOf(game) and character:IsDescendantOf(game) and player.Character == character then
				initializeSoundSystem({
					player = player,
					humanoid = humanoid,
					rootPart = humanoidRootPart
				})
			end
		end

		if player.Character then
			characterAdded(player.Character)
		end

		player.CharacterAdded:Connect(characterAdded)
	end

	Players.PlayerAdded:Connect(playerAdded)

	for _, v3 in ipairs(Players:GetPlayers()) do
		local player = v3

		local function characterAdded(character)
			if not character.Parent then
				waitForFirst(character.AncestryChanged, player.CharacterAdded)
			end

			if player.Character ~= character or not character.Parent then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")

			while character:IsDescendantOf(game) and not humanoid do
				waitForFirst(character.ChildAdded, character.AncestryChanged, player.CharacterAdded)
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			if player.Character ~= character or not character:IsDescendantOf(game) then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			while character:IsDescendantOf(game) and not humanoidRootPart do
				waitForFirst(
					character.ChildAdded,
					character.AncestryChanged,
					humanoid.AncestryChanged,
					player.CharacterAdded
				)
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if humanoidRootPart and humanoid:IsDescendantOf(game) and character:IsDescendantOf(game) and player.Character == character then
				initializeSoundSystem({
					player = player,
					humanoid = humanoid,
					rootPart = humanoidRootPart
				})
			end
		end

		if v3.Character then
			characterAdded(v3.Character)
		end

		v3.CharacterAdded:Connect(characterAdded)
	end
end