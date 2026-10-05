local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local AssetIds = require(ReplicatedStorage.Shared.Utils.AssetIds)
local GameFlags = require(ReplicatedStorage.Shared.Flags.GameFlags)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Spread = require(ReplicatedStorage.Shared.Utils.Spread)
local isClient = RunService:IsClient()
local Preferences

if isClient then
	Preferences = require(ReplicatedStorage.Shared.Preferences)
else
	Preferences = nil
end

local _ = {
	Gameplay = "Gameplay",
	Music = "Music",
	MusicInner = "GameMusic"
}
local v = {
	Failure = 1,
	Notice = 0.55,
	Prompt = 0.75
}
local v2 = {
	Ambient = Enum.RollOffMode.Linear,
	OneShot = Enum.RollOffMode.LinearSquare
}
local v3 = {
	Style = Enum.EasingStyle.Sine,
	Direction = Enum.EasingDirection.InOut
}
local v4 = {
	{
		Option = "Looped",
		Property = "Looped"
	},
	{
		Option = "MaxDistance",
		Property = "RollOffMaxDistance"
	},
	{
		Option = "PlaybackSpeed",
		Property = "PlaybackSpeed",
		Sampled = true
	},
	{
		Option = "TimePosition",
		Property = "TimePosition"
	},
	{
		Option = "Volume",
		Property = "Volume",
		Sampled = true
	}
}
local v5 = {
	Frame = nil,
	HalfExtent = 0
}
local v6 = {}
local random = Random.new()
local v7 = nil
local object = setmetatable({}, {
	__mode = "k"
})
local pickAsset
local v8 = {
	number = function(p)
		assert(p > 0, "asset ids are positive numbers")
		return p
	end,
	string = function(p)
		return AssetIds.Parse(p) or error(`"{p}" does not name an asset`, 2)
	end,
	table = function(list)
		assert(#list > 0, "a sound list needs at least one entry")
		return pickAsset(list[random:NextInteger(1, #list)])
	end
}

pickAsset = function(p)
	local v9 = v8[typeof(p)]

	if v9 == nil then
		error(`cannot turn a {typeof(p)} into a sound id`, 2)
	end

	return v9(p)
end

local function assetUri(p)
	return (`rbxassetid://{pickAsset(p)}`)
end

local function resolveGroup(instance, p: string)
	local soundGroup

	if typeof(instance) == "Instance" then
		soundGroup = instance
	else
		soundGroup = SoundService:FindFirstChild(instance or p)
	end

	if soundGroup == nil or not soundGroup:IsA("SoundGroup") then
		error(`SoundService has no SoundGroup named {tostring(instance or p)}`, 2)
	end

	if soundGroup.Name == "Music" then
		local gameMusic = soundGroup:FindFirstChild("GameMusic")

		if gameMusic and gameMusic:IsA("SoundGroup") then
			return gameMusic
		end
	end

	return soundGroup
end

local function nearField(p: number)
	return (math.clamp(p * 0.005, 0.01, 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rolloffFor(looped: boolean)
	if looped then
		return v2.Ambient
	end

	return v2.OneShot
end

local function authorSound(sound, sound2, data)
	local looped = data.Looped == true
	local maxDistance = data.MaxDistance or 200
	sound.Looped = looped
	sound.PlaybackSpeed = Spread.Sample(data.PlaybackSpeed, 1, random)
	sound.RollOffMaxDistance = maxDistance
	sound.RollOffMinDistance = math.clamp(maxDistance * 0.005, 0.01, 1)
	local rollOffMode = rolloffFor(looped) -- equivalent call inferred; original call site unknown
	sound.RollOffMode = rollOffMode
	sound.SoundGroup = resolveGroup(data.SoundGroup, "Gameplay")
	sound.SoundId = `rbxassetid://{pickAsset(sound2)}`
	sound.TimePosition = data.TimePosition or 0
	sound.Volume = Spread.Sample(data.Volume, 1, random)
	return sound
end

local function retouchSound(samplesByProperty, p)
	for _, v9 in v4 do
		local sample = p[v9.Option]

		if sample == nil then
			continue
		end

		local property = v9.Property

		if v9.Sampled then
			sample = Spread.Sample(sample, 1, random)
		end

		samplesByProperty[property] = sample
	end

	if p.SoundGroup ~= nil then
		samplesByProperty.SoundGroup = resolveGroup(p.SoundGroup, "Gameplay")
	end

	return samplesByProperty
end

local function attachEffects(parent, effects)
	for _, v9 in effects or {} do
		local clone = v9:Clone()
		clone.Parent = parent
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function optionsFromCatalog(data)
	return {
		Deferred = data.SkipPlay,
		Looped = data.Looped,
		MaxDistance = data.MaxDistance,
		PlaybackSpeed = data.Speed,
		Recipient = data.Player,
		SoundGroup = data.SoundGroup,
		TimePosition = data.TimePos,
		Volume = data.Volume
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function placementOfPart(instance)
	return {
		Frame = instance.CFrame,
		HalfExtent = instance.Size.Magnitude / 2
	}
end

local v9 = {
	CFrame = function(frame)
		return {
			Frame = frame,
			HalfExtent = 0
		}
	end,
	Vector3 = function(position)
		return {
			Frame = CFrame.new(position),
			HalfExtent = 0
		}
	end
}
local v10 = {
	{
		Class = "Attachment",
		Resolve = function(p)
			return {
				Frame = p.WorldCFrame,
				HalfExtent = 0
			}
		end
	},
	{
		Class = "BasePart",
		Resolve = function(instance)
			return placementOfPart(instance)
		end
	},
	{
		Class = "Workspace",
		Resolve = function()
			return v5
		end
	},
	{
		Class = "Model",
		Resolve = function(instance)
			local primaryPart = instance.PrimaryPart

			if primaryPart then
				return placementOfPart(primaryPart)
			end

			return v5
		end
	},
	{
		Class = "PVInstance",
		Resolve = function(instance)
			return {
				Frame = instance:GetPivot(),
				HalfExtent = 0
			}
		end
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function needsPrimaryPart(instance)
	return typeof(instance) == "Instance" and instance:IsA("Model") and not instance:IsA("Workspace")
end

local function placementOf(instance)
	local v11 = v9[typeof(instance)]

	if v11 ~= nil then
		return v11(instance)
	end

	for _, v12 in v10 do
		if instance:IsA(v12.Class) then
			return v12.Resolve(instance)
		end
	end

	return v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function earshotSlack(instance, now: number)
	if typeof(instance) ~= "Instance" then
		return 1.5
	end

	local v11 = object[instance]
	local v12

	if v11 == nil then
		v12 = false
	else
		v12 = now - v11 < 4
	end

	if v12 then
		return 2
	end

	return 1.5
end

local function inEarshot(instance, p, maxDistance: number)
	local currentCamera = Workspace.CurrentCamera
	local frame = p.Frame

	if currentCamera == nil or frame == nil then
		return true
	end

	local now = os.clock()
	local v11 = (currentCamera:GetRenderCFrame().Position - frame.Position).Magnitude - p.HalfExtent
	local v12 = earshotSlack(instance, now) -- equivalent call inferred; original call site unknown
	local v13 = v11 <= maxDistance * v12

	if v13 and typeof(instance) == "Instance" then
		object[instance] = now
	end

	return v13
end

local function shelf()
	local v11 = v7

	if v11 and v11.Parent ~= nil then
		return v11
	end

	local folder = Instance.new("Folder")
	folder.Name = "MusicTracks"
	folder.Parent = SoundService
	v7 = folder
	return folder
end

local function stageFor(instance, worldCFrame: CFrame?)
	if typeof(instance) == "Instance" then
		-- equivalent call inferred; original call site unknown
		if needsPrimaryPart(instance) then
			return assert(instance.PrimaryPart), nil
		end

		return instance, nil
	else
		local attachment = Instance.new("Attachment")
		attachment.Name = "SoundStage"
		attachment.Parent = Workspace.Terrain
		attachment.WorldCFrame = worldCFrame
		return attachment, attachment
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function launch(object2, instance)
	local function retire()
		instance:Destroy()
	end

	object2.Ended:Once(retire)
	object2.Stopped:Once(retire)
	object2:Play()
	return object2
end

local function sfxMuted()
	return not GameFlags.SoundEffects:Get() or Preferences ~= nil and not Preferences.IsOn("SFX")
end

local function dispatch(sound, emitter, p2)
	local recipient = p2.Recipient
	local clone = table.clone(p2)
	clone.Recipient = nil
	local v11 = {
		Source = sound,
		Emitter = emitter,
		Options = clone
	}
	local emitSound = Remotes.SoundBus.EmitSound

	if recipient == nil then
		emitSound:FireAllClients(v11)
		return
	end

	if typeof(recipient) == "Instance" then
		emitSound:FireClient(recipient, v11)
		return
	end

	for _, player in recipient do
		emitSound:FireClient(player, v11)
	end
end

function v6.Play(sound, parent, options)
	local v11 = options or {}

	if not isClient then
		dispatch(sound, parent, v11)
		return nil
	end

	local v12

	if GameFlags.SoundEffects:Get() then
		if Preferences == nil then
			v12 = false
		else
			v12 = not Preferences.IsOn("SFX")
		end
	else
		v12 = true
	end

	if v12 then
		return nil
	end

	local v13 = placementOf(parent)

	if v13.Frame == nil then
		-- equivalent call inferred; original call site unknown
		if needsPrimaryPart(parent) then
			warn((`Audio.Play skipped: {parent:GetFullName()} has no PrimaryPart`))
			return nil
		end
	end

	local maxDistance = v11.MaxDistance or 200

	if v11.Looped ~= true and not inEarshot(parent, v13, maxDistance) then
		return nil
	end

	local v14

	if typeof(sound) == "Instance" then
		assert(sound:IsA("Sound"), "an Instance sound source must be a Sound")
		v14 = retouchSound(sound:Clone(), v11)
	else
		v14 = authorSound(Instance.new("Sound"), sound, v11)
	end

	attachEffects(v14, v11.Effects)
	local frame = v13.Frame
	local v15

	if typeof(parent) == "Instance" then
		-- equivalent call inferred; original call site unknown
		if needsPrimaryPart(parent) then
			parent = assert(parent.PrimaryPart)
		end

		v15 = nil
	else
		parent = Instance.new("Attachment")
		parent.Name = "SoundStage"
		parent.Parent = Workspace.Terrain
		parent.WorldCFrame = frame
		v15 = parent
	end

	v14.Parent = parent

	if v11.Deferred then
		if v15 ~= nil then
			v14.Destroying:Once(function()
				v15:Destroy()
			end)
		end

		return v14
	else
		return launch(v14, v15 or v14)
	end
end

function v6:PlaySound(parent)
	if parent then
		self.Parent = parent
	end

	return launch(self, self)
end

function v6.PlayFile(p, p2, effects)
	local data = p.Data
	local v11 = {
		Deferred = data.SkipPlay,
		Looped = data.Looped,
		MaxDistance = data.MaxDistance,
		PlaybackSpeed = data.Speed,
		Recipient = data.Player,
		SoundGroup = data.SoundGroup,
		TimePosition = data.TimePos,
		Volume = data.Volume,
		Effects = effects
	}
	return v6.Play(p.SoundId, p2, v11)
end

function v6.Configure(p, p2)
	local soundId = p2.SoundId
	assert(typeof(soundId) ~= "Instance", "a catalogued Sound cannot be configured from another Sound")
	return (authorSound(p, soundId, optionsFromCatalog(p2.Data)))
end

function v6.CreateConfigured(parent, p, value: string?)
	local v11 = v6.Configure(Instance.new("Sound"), p)
	v11.Name = value or "CatalogSound"
	v11.Parent = parent
	return v11
end

function v6.MusicTrack(data)
	local sound = Instance.new("Sound")
	sound.Looped = data.Looped
	sound.Name = data.Name
	sound.SoundGroup = resolveGroup(nil, "Music")
	local source = data.Source
	sound.SoundId = `rbxassetid://{pickAsset(source)}`
	sound.Volume = 0
	local parent = v7

	if not parent or parent.Parent == nil then
		parent = Instance.new("Folder")
		parent.Name = "MusicTracks"
		parent.Parent = SoundService
		v7 = parent
	end

	sound.Parent = parent
	return sound
end

function v6.FadeTo(p, data)
	local tween = TweenService:Create(
		p,
		TweenInfo.new(data.Seconds, data.Style or v3.Style, data.Direction or v3.Direction),
		{
			Volume = data.Volume
		}
	)
	tween:Play()
	return tween
end

function v6.Chime(p: string, value: number?, recipient)
	v6.Play(131342831254185, script, {
		Recipient = recipient,
		Volume = (v[p] or 1) * (value or 1)
	})
end

if isClient then
	Remotes.SoundBus.EmitSound.OnClientEvent:Connect(function(data)
		v6.Play(data.Source, data.Emitter, data.Options)
	end)
end

return table.freeze(v6)