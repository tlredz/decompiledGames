local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local TestLibrary = require(ReplicatedStorage.Modules.TestLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)

if CONSTANTS.IS_CLIENT then
	require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
end

local SpectateController = CONSTANTS.IS_CLIENT and require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local testAttribute = TestLibrary:GetTestAttribute("StudioPing")
local IS_STUDIO = CONSTANTS.IS_STUDIO
local Emote = {}
Emote.__index = Emote
Emote._id_counter = 0

function Emote.new(lifetime, name, humanoid)
	assert(CosmeticLibrary.Cosmetics[name] and CosmeticLibrary.Cosmetics[name].Type == "Emote", name)
	local v

	if typeof(humanoid) == "Instance" then
		v = humanoid:IsA("Humanoid")
	else
		v = false
	end

	assert(v, "Argument 1 invalid, expected a Humanoid")
	local self = setmetatable({}, Emote)
	self.Destroying = Signal.new()
	self.ObjectID = self:_NewObjectID()
	self.Name = name
	self.Info = CosmeticLibrary.Cosmetics[name]
	self.Lifetime = lifetime
	self._humanoid = humanoid
	self._destroyed = false
	self._destroy_these = {}
	self._connections = {}
	self._threads = {}
	self._animation_tracks = {}
	self._serial = nil
	self._seed = math.random(1, 1000000)
	self._sounds = {}
	self._are_sounds_hidden = false
	self:_Init()
	return self
end

function Emote:IsDestroyed()
	return self._destroyed
end

function Emote:CreateSound(p, p2, p3, p4, p5, p6, p7, p8, _, p9)
	local v

	if not (self._destroyed or not self._humanoid:IsDescendantOf(workspace) or self._are_sounds_hidden) then
		v = p4 or self._humanoid.RootPart
	end

	local sound = Utility:CreateSound(p, p2, p3, v, p5, p6, p7, p8, self:_GetSoundGroup(), p9)
	table.insert(self._destroy_these, sound)
	self._sounds[sound] = sound.Parent
	return sound
end

function Emote:HideSounds(are_sounds_hidden)
	if are_sounds_hidden == self._are_sounds_hidden then
		return
	end

	self._are_sounds_hidden = are_sounds_hidden

	for k, _sound in pairs(self._sounds) do
		local v = k
		local v2 = _sound
		pcall(function()
			local v3 = v
			local parent

			if not self._are_sounds_hidden then
				parent = v2
			end

			v3.Parent = parent
		end)
	end
end

function Emote:Simulate(callback)
	local bindableEvent = Instance.new("BindableEvent")
	table.insert(self._destroy_these, bindableEvent)
	local count = 0
	task.spawn(function()
		local success, result = pcall(self.PlayServer, self, true)

		if not success and callback then
			callback(result)
		end

		if not success and IS_STUDIO then
			error(result)
		end

		count += 1
		bindableEvent:Fire()
	end)
	task.spawn(function()
		if testAttribute and testAttribute > 0 then
			wait(testAttribute / 1000)
		end

		local success, result = pcall(self.PlayClient, self, true)

		if not success and callback then
			callback(result)
		end

		if not success and IS_STUDIO then
			error(result)
		end

		count += 1
		bindableEvent:Fire()
	end)

	while count < 2 do
		bindableEvent.Event:Wait()
	end
end

function Emote.PlayServer(p, _)
	if p.Lifetime then
		task.delay(p.Lifetime, p.Destroy, p)
	end
end

function Emote.PlayClient(_, _) end

function Emote:SetSerial(serial)
	self._serial = serial
	self._seed = serial.Seed
	self.ObjectID = serial.ObjectID
end

function Emote:Serialize()
	return {
		ObjectID = self.ObjectID,
		Name = self.Name,
		Seed = self._seed
	}
end

function Emote:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	self.Destroying:Fire()
	task.defer(self.Destroying.Destroy, self.Destroying)

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	for _, v in pairs(self._destroy_these) do
		v:Destroy()
	end

	for _, _thread in pairs(self._threads) do
		pcall(task.cancel, _thread)
	end

	for _, _animation_track in pairs(self._animation_tracks) do
		_animation_track:Stop()
		_animation_track:Destroy()
	end
end

function Emote:_GetSoundGroup()
	local playerFromCharacter = self:_IsWorkspaceEmote() and self._humanoid.Parent and Players:GetPlayerFromCharacter(self._humanoid.Parent)
	local player = SpectateController and SpectateController.CurrentSubject and SpectateController.CurrentSubject.Player

	if playerFromCharacter and playerFromCharacter ~= player then
		return "EmoteFromOthers"
	end

	return "Emote"
end

function Emote:_IsWorkspaceEmote()
	local _humanoid = self._humanoid

	while _humanoid do
		if _humanoid:IsA("WorldModel") then
			return false
		end

		if _humanoid == workspace then
			return true
		else
			_humanoid = _humanoid.Parent
		end
	end

	return false
end

function Emote:_CanPlayAnimation()
	local playerFromCharacter = self._humanoid.Parent and Players:GetPlayerFromCharacter(self._humanoid.Parent)
	return not playerFromCharacter or playerFromCharacter == Players.LocalPlayer
end

function Emote:_NewObjectID()
	Emote._id_counter += 1
	return utf8.char(Emote._id_counter - 1)
end

function Emote._GetGroundPosition(_, p, p2)
	return Utility:Raycast(p, p + createVector(0, -100, 0), 100, p2, Enum.RaycastFilterType.Exclude).Position
end

function Emote:_SetupProp(instance)
	local clones = {}

	for _, part in pairs(instance:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local clone = part:Clone()
		table.insert(self._destroy_these, clone)
		local clone2 = instance:WaitForChild(clone.Name):Clone()
		table.insert(self._destroy_these, clone2)
		clone2.Part1 = clone
		clone2.Part0 = self._humanoid.RootPart
		clone2.Parent = self._humanoid.RootPart

		-- equivalent calls inferred from this helper; original call sites unknown
		local function format(part2)
			if not part2:IsA("BasePart") then
				return
			end

			part2.CanCollide = false
			part2.CanTouch = false
			part2.CanQuery = false
			part2.Massless = true
		end

		for _, descendant in pairs(clone:GetDescendants()) do
			format(descendant) -- equivalent call inferred; original call site unknown
		end

		format(clone) -- equivalent call inferred; original call site unknown
		clone:PivotTo(self._humanoid.RootPart.CFrame)
		clone.Parent = self._humanoid.Parent

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:SetAttribute("IgnoreVisibilityCheck", true)
			end
		end

		table.insert(clones, clone)
	end

	return table.unpack(clones)
end

function Emote:_SetupMultipleProps(...)
	local v = { self:_SetupProp(...) }
	local result = {}

	for _, v2 in pairs(v) do
		assert(not result[v2.Name], v2.Name)
		result[v2.Name] = v2
	end

	return result
end

function Emote:_PlayAnimation(animationId, animationId2, p, value, p2)
	if not self:_CanPlayAnimation() then
		return
	end

	local v = value or 1
	self:_InternalThread(task.spawn, function()
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		table.insert(self._destroy_these, animation)

		if animationId2 then
			task.spawn(pcall, ContentProvider.PreloadAsync, ContentProvider, { animation })
			local animation2 = Instance.new("Animation")
			animation2.AnimationId = animationId2
			table.insert(self._destroy_these, animation2)
			local success, result = pcall(self._humanoid.LoadAnimation, self._humanoid, animation2)

			if success then
				table.insert(self._animation_tracks, result)
				result:Play()
				result:AdjustSpeed(v)
			end

			wait(p - 0.04)

			if self._destroyed then
				return
			end
		end

		local success, result = pcall(self._humanoid.LoadAnimation, self._humanoid, animation)

		if not success then
			return
		end

		table.insert(self._animation_tracks, result)
		result:Play(animationId2 and 0 or 0.1)
		result:AdjustSpeed(v)

		if not p2 then
			return
		end

		while true do
			result:AdjustSpeed(v * ((not self:_IsWorkspaceEmote() or self._humanoid:GetAttribute("SimulateMoving")) and 1 or (self._humanoid.RootPart.Velocity * createVector(
				1,
				0,
				1
			)).Magnitude / p2))
			RunService.Heartbeat:Wait()
		end
	end)
end

function Emote:_InternalThread(callback, ...)
	local v = nil

	if IS_STUDIO then
		v = callback(...)
	else
		pcall(function(...)
			v = callback(...)
		end, ...)
	end

	table.insert(self._threads, v)
	return v
end

function Emote:_Init()
	table.insert(self._connections, self._humanoid.Destroying:Connect(function()
		self:Destroy()
	end))
end

return Emote