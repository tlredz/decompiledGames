local createVector = vector.create
local Promise = require(game.ReplicatedStorage.Modules.Util.Promise)
local CharacterReady = require(game.ReplicatedStorage.Modules.Player.CharacterReady)
local PlayerAdded = require(game.ReplicatedStorage.Modules.Player.PlayerAdded)
local OnDestroy = require(game.ReplicatedStorage.Modules.Util.OnDestroy)
local Tracking = {}
local v = {
	Players = {}
}

function Tracking.GetPlayers(_)
	debug.profilebegin("Tracking.GetPlayers")
	local players = {}

	for _, player in pairs(v.Players) do
		local player2 = player.Player

		if player2 then
			table.insert(players, player2)
		end
	end

	debug.profileend()
	return players
end

function Tracking:GetLocation(p, value: number?)
	local tracker = Tracking:GetTracker(p)

	if not tracker then
		return nil
	end

	debug.profilebegin("Tracking.GetLocation")
	local v2 = tick() - tracker.Location.LastCheck

	if (not tracker.Location.CFrame or (value or 1) <= v2) and tracker.Character then
		tracker.Location.LastCheck = tick()
		local pivot = tracker.Character:GetPivot()
		tracker.Location.CFrame = pivot
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			local lookVector = currentCamera.CFrame.lookVector
			tracker.Location.Heading = math.atan2(lookVector.X, lookVector.Z) + 3.141592653589793
		end

		local primaryPart = tracker.Character.PrimaryPart

		if primaryPart then
			tracker.Location.Orientation = primaryPart.Orientation.Y
		end
	end

	debug.profileend()
	return tracker.Location
end

function Tracking:GetPositionFromAny(instance)
	debug.profilebegin("Tracking.GetPositionFromAny")
	local position = nil

	if typeof(instance) == "table" then
		local root = instance:getRoot()

		if root then
			return root.Position
		end

		return nil
	else
		if typeof(instance) == "Instance" then
			if instance:IsA("Player") then
				if instance.Character then
					position = instance.Character:GetPivot().Position
				end
			elseif instance:IsA("Model") then
				position = instance:GetPivot().Position
			elseif instance:IsA("BasePart") then
				position = instance.Position
			elseif instance:IsA("Attachment") then
				position = instance.WorldPosition
			end
		elseif typeof(instance) == "CFrame" then
			position = instance.Position
		elseif typeof(instance) == "Vector3" then
			position = instance
		else
			warn("Unsupported type", instance, typeof(instance), debug.traceback())
		end

		debug.profileend()
		return position
	end
end

function Tracking:DistanceFromPosition(p, p2, vector2: Vector3)
	assert(typeof(p2) == "Vector3" or typeof(p2) == "CFrame", "Type not supported > DistanceFromPosition")
	debug.profilebegin("Tracking.DistanceFromPosition")
	local positionFromAny = Tracking:GetPositionFromAny(p)

	if not positionFromAny then
		debug.profileend()
		return 1e999
	end

	local position = nil

	if typeof(p2) == "CFrame" then
		position = p2.Position
	elseif typeof(p2) == "Vector3" then
		position = p2
	end

	debug.profileend()
	return (positionFromAny * (vector2 or createVector(1, 1, 1)) - position).Magnitude
end

function Tracking:GetTracker(playerFromCharacter)
	debug.profilebegin("GetTracker")
	assert(
		playerFromCharacter.ClassName == "Player" or playerFromCharacter.ClassName == "Model",
		"Unsupported type: " .. typeof(playerFromCharacter)
	)

	if playerFromCharacter.Parent == workspace:FindFirstChild("Characters") then
		playerFromCharacter = game.Players:GetPlayerFromCharacter(playerFromCharacter) or playerFromCharacter
	end

	debug.profileend()

	if playerFromCharacter then
		return v.Players[playerFromCharacter]
	end

	return nil
end

function Tracking.WaitForTrackerAsync(_, p)
	local tracker = Tracking:GetTracker(p)

	if tracker then
		return Promise.resolve(tracker)
	end

	return Promise.new(function(callback, _, callback2)
		local v2 = false
		callback2(function()
			v2 = true
		end)

		while not v2 do
			tracker = Tracking:GetTracker(p)

			if tracker then
				break
			else
				task.wait()
			end
		end

		callback(not v2 and tracker)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePlayer(p, items)
	if v.Players[p] then
		for k, item in pairs(items) do
			v.Players[p][k] = item
		end
	end
end

local function onPlayer(instance)
	local RunService = game:GetService("RunService")

	if RunService:IsClient() and instance ~= game.Players.LocalPlayer then
		return
	end

	assert(v.Players[instance] == nil, (`Tracker already exists for {instance.Name}`))
	local v2 = {
		Group = "Players",
		Location = {
			LastCheck = 1,
			Heading = 0,
			Orientation = 0
		},
		Player = instance,
		Character = nil,
		Humanoid = nil,
		PrimaryPart = nil,
		getLocation = function(_, p: number)
			return Tracking:GetLocation(instance, p)
		end,
		inRange = function(self, vector2: Vector3, p: number)
			local root = self:getRoot()

			if not root then
				return false, 0, 1e999
			end

			local v3 = math.max(0, root.Size.X - 2)
			local v4 = p + v3
			local magnitude = (root.Position - vector2).Magnitude
			return magnitude <= v4, v3, magnitude
		end,
		getHum = function(instance2)
			return instance2.Humanoid
		end,
		getRoot = function(self)
			return self.PrimaryPart
		end,
		getChar = function(player)
			return player.Character
		end,
		distanceFromPosition = function(player, p, p2)
			return Tracking:DistanceFromPosition(player.Character, p, p2)
		end
	}
	local diedConnection = nil
	local characterRemovingConnection = nil
	local v3 = nil

	local function cleanup()
		local player = v.Players[instance]
		v.Players[instance] = nil

		if player then
			player.Player = nil
			player.Character = nil
			player.PrimaryPart = nil
			player.Humanoid = nil
		end

		if diedConnection and diedConnection.Connected then
			diedConnection:Disconnect()
		end

		if characterRemovingConnection and characterRemovingConnection.Connected then
			characterRemovingConnection:Disconnect()
		end

		if v3 then
			v3()
		end

		v3 = nil
		diedConnection = nil
		characterRemovingConnection = nil
	end

	v3 = CharacterReady(instance, function(player)
		updatePlayer(instance, {
			PrimaryPart = player.PrimaryPart,
			Character = player.Character,
			Humanoid = player.Humanoid
		}) -- equivalent call inferred; original call site unknown
		diedConnection = player.Humanoid.Died:Connect(function()
			updatePlayer(instance, {
				PrimaryPart = false,
				Character = false,
				Humanoid = false
			}) -- equivalent call inferred; original call site unknown
		end)
	end)
	characterRemovingConnection = instance.CharacterRemoving:Connect(function()
		updatePlayer(instance, {
			Character = false,
			PrimaryPart = false,
			Humanoid = false
		}) -- equivalent call inferred; original call site unknown
	end)
	OnDestroy.AncestryChanged(instance, cleanup)

	if instance.Parent then
		v.Players[instance] = v2
	end
end

task.spawn(PlayerAdded, onPlayer)
return Tracking