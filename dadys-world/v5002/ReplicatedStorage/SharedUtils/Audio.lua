local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ServerStorage = game:GetService("ServerStorage")
local isServer = RunService:IsServer()
local Audio = {}
local v = {
	Volume = 0.5,
	RollOffMaxDistance = 300,
	RollOffMinDistance = 10,
	PlaybackSpeed = 1,
	Looped = false,
	Parent = isServer and workspace or Players.LocalPlayer
}
local v2 = {}
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizePath(value: string)
	return (value:gsub("^Sounds%.", ""))
end

local function isLeaf(p)
	return typeof(p) == "table" and p.__sound == true
end

local function waitForManifest(value: number?)
	local v4 = os.clock() + (value or 10)

	while v3 == nil and os.clock() < v4 do
		task.wait(0.05)
	end

	return v3
end

local function resolveNode(value: string)
	if not v3 then
		return nil
	end

	local v4 = v3

	for _, v5 in ipairs(value:split(".")) do
		if typeof(v4) ~= "table" then
			return nil
		end

		local v6

		if typeof(v4) == "table" then
			v6 = v4.__sound == true
		else
			v6 = false
		end

		if v6 then
			return nil
		end

		v4 = v4[v5]

		if v4 == nil then
			return nil
		end

		continue
	end

	return v4
end

local collectLeaves

collectLeaves = function(p, options)
	local v4 = options or {}
	local v5

	if typeof(p) == "table" then
		v5 = p.__sound == true
	else
		v5 = false
	end

	if v5 then
		table.insert(v4, p)
		return v4
	end

	if typeof(p) == "table" then
		for _, v6 in pairs(p) do
			collectLeaves(v6, v4)
		end
	end

	return v4
end

local function inheritProperties(p, p2, items)
	if not p then
		return
	end

	local v4 = typeof(p2) == "table" and p2 or {}
	local v5 = {}

	for k, item in pairs(items) do
		v5[k] = item
	end

	for k, v6 in pairs(v4) do
		v5[k] = v6
	end

	for k, v6 in pairs(v5) do
		if not (k ~= "Parent" and k ~= "Duration") then
			continue
		end

		local v7 = k
		local v8 = v6
		local success, result = pcall(function()
			p[v7] = v8
		end)

		if not success then
			warn(string.format(
				"Could not set property %s on object %s; Err: %s",
				tostring(k),
				tostring(p),
				(tostring(result))
			))
		end
	end

	if v5.Parent then
		p.Parent = v5.Parent
	end

	return p
end

local function mergedBase(items)
	if not items then
		return v
	end

	local result = {}

	for k, v4 in pairs(v) do
		result[k] = v4
	end

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

local function debugPlayLatency(_, _: string?, _: number, _: boolean) end

local function playWhenLoaded(object, p: string?)
	local now = os.clock()

	if object.IsLoaded then
		object:Play()
		return
	end

	local flag = false
	local loadedConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function start()
		if flag then
			return
		end

		flag = true

		if loadedConnection then
			loadedConnection:Disconnect()
			loadedConnection = nil
		end

		if object.Parent then
			object:Play()
		end
	end

	loadedConnection = object.Loaded:Connect(start)

	if not object.IsLoaded then
		task.spawn(function()
			local v4 = os.clock() + 0

			while not flag and object.Parent and os.clock() < v4 do
				RunService.Heartbeat:Wait()

				if not object.IsLoaded then
					continue
				end

				if flag then
					return
				end

				flag = true

				if loadedConnection then
					loadedConnection:Disconnect()
					loadedConnection = nil
				end

				if object.Parent then
					object:Play()
				end

				return
			end

			start() -- equivalent call inferred; original call site unknown
		end)
		return
	end

	start() -- equivalent call inferred; original call site unknown
end

local function scheduleCleanup(data, data2, timeLength: number?)
	local duration = data2.Duration

	if duration then
		if duration ~= 1e999 then
			Debris:AddItem(data, duration)
		end
	else
		if data2.Looped then
			return
		end

		local v4 = math.max(data2.PlaybackSpeed or 1, 0.05)

		if not timeLength then
			if data.TimeLength > 0 then
				timeLength = data.TimeLength or nil
			else
				timeLength = nil
			end
		end

		if timeLength and data.IsLoaded then
			Debris:AddItem(data, timeLength / v4 * 1.1)
		else
			task.spawn(function()
				local v5 = os.clock() + 0

				while not data.IsLoaded and data.Parent and os.clock() < v5 do
					task.wait(0.05)
				end

				if not data.Parent then
					return
				end

				local v6 = timeLength or data.TimeLength > 0 and data.TimeLength or nil

				if v6 then
					Debris:AddItem(data, v6 / v4 * 1.1)
				else
					Debris:AddItem(data, 5)
				end
			end)
		end
	end
end

local function buildAndPlay(soundId: string, p, p2: number?, items, p3: string?)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.SoundGroup = nil
	local v4 = mergedBase(p)
	inheritProperties(sound, items, v4)
	local v5 = {}

	for k, v6 in pairs(v4) do
		v5[k] = v6
	end

	if typeof(items) == "table" then
		for k, item in pairs(items) do
			v5[k] = item
		end
	end

	playWhenLoaded(sound, p3)
	scheduleCleanup(sound, v5, p2)
	return sound
end

local function buildManaged(soundId: string, p, p2, p3: string?)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.SoundGroup = nil
	inheritProperties(sound, p2, mergedBase(p))
	playWhenLoaded(sound, p3)
	return sound
end

local function getSoundIdFromUnknown(sound)
	if typeof(sound) == "Instance" and sound:IsA("Sound") then
		return sound.SoundId
	end

	if typeof(sound) == "number" then
		return string.format("rbxassetid://%d", sound)
	end

	if typeof(sound) == "string" and (sound:find("rbxassetid://") or sound:find("rbxasset://") or sound:find("roblox.com/asset")) then
		return sound
	end
end

function Audio.GetManifest(_)
	return v3
end

function Audio.GetSoundFromID(_, soundId: string)
	local v4 = v2[soundId]

	if v4 then
		return v4
	end

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	v2[soundId] = sound
	return sound
end

function Audio.PlaySound(_, instance, items)
	local clone = instance:Clone()
	clone.SoundGroup = nil
	inheritProperties(clone, items, v)
	local v4 = {}

	for k, v5 in pairs(v) do
		v4[k] = v5
	end

	if typeof(items) == "table" then
		for k, item in pairs(items) do
			v4[k] = item
		end
	end

	playWhenLoaded(clone)
	scheduleCleanup(clone, v4, instance.TimeLength > 0 and instance.TimeLength or nil)
	return clone
end

function Audio:Play(value, p)
	local soundIdFromUnknown = getSoundIdFromUnknown(value)

	if soundIdFromUnknown then
		return (buildAndPlay(soundIdFromUnknown, nil, nil, p))
	end

	if typeof(value) ~= "string" or not value:find("[.]") then
		return
	end

	if not waitForManifest(10) then
		warn(string.format("[Audio] manifest unavailable, cannot resolve path: %s", value))
		return
	end

	local node = resolveNode(value:gsub("^Sounds%.", ""))

	if not node then
		warn(string.format("Path resolution unsuccessful: %s", value))
		return
	end

	local v4 = collectLeaves(node)

	if #v4 == 0 then
		warn(string.format("No sound entries under path %s", value))
	else
		local v5 = v4[math.random(1, #v4)]
		return (buildAndPlay(v5.id, v5.props, v5.duration, p, value))
	end
end

function Audio.Acquire(_, value, p)
	local soundIdFromUnknown = getSoundIdFromUnknown(value)

	if soundIdFromUnknown then
		local sound = Instance.new("Sound")
		sound.SoundId = soundIdFromUnknown
		sound.SoundGroup = nil
		inheritProperties(sound, p, v)
		playWhenLoaded(sound, nil)
		return sound
	else
		if typeof(value) ~= "string" or not value:find("[.]") then
			return
		end

		if not waitForManifest(10) then
			warn(string.format("[Audio] manifest unavailable, cannot resolve path: %s", value))
			return
		end

		local node = resolveNode(value:gsub("^Sounds%.", ""))

		if not node then
			warn(string.format("Path resolution unsuccessful: %s", value))
			return
		end

		local v4 = collectLeaves(node)

		if #v4 == 0 then
			warn(string.format("No sound entries under path %s", value))
			return
		end

		local v5 = v4[math.random(1, #v4)]
		local id = v5.id
		local props = v5.props
		local sound = Instance.new("Sound")
		sound.SoundId = id
		sound.SoundGroup = nil
		inheritProperties(sound, p, mergedBase(props))
		playWhenLoaded(sound, value)
		return sound
	end
end

local v4 = {}

local function playCached(p, soundId, p2, p3)
	local v5 = v4[p]

	if not (v5 and v5.Parent) then
		v5 = Instance.new("Sound")
		v5.SoundGroup = nil
		v4[p] = v5
	end

	if v5.SoundId ~= soundId then
		v5.SoundId = soundId
	end

	local v6 = mergedBase(p2)
	v5:Stop()
	inheritProperties(v5, p3, v6)
	playWhenLoaded(v5, p)
	return v5
end

function Audio.IsOnePlaying(_, value)
	local soundIdFromUnknown = getSoundIdFromUnknown(value)

	if not soundIdFromUnknown and typeof(value) == "string" and value:find("[.]") then
		soundIdFromUnknown = value:gsub("^Sounds%.", "")
	end

	local v5 = soundIdFromUnknown and v4[soundIdFromUnknown]
	return v5 ~= nil and v5.IsPlaying
end

function Audio.PlayOne(_, value, p)
	local soundIdFromUnknown = getSoundIdFromUnknown(value)

	if soundIdFromUnknown then
		return (playCached(soundIdFromUnknown, soundIdFromUnknown, nil, p))
	end

	if typeof(value) ~= "string" or not value:find("[.]") then
		return
	end

	if not waitForManifest(10) then
		warn(string.format("[Audio] manifest unavailable, cannot resolve path: %s", value))
		return
	end

	local path = normalizePath(value) -- equivalent call inferred; original call site unknown
	local node = resolveNode(path)

	if not node then
		warn(string.format("Path resolution unsuccessful: %s", value))
		return
	end

	local v5 = collectLeaves(node)

	if #v5 == 0 then
		warn(string.format("No sound entries under path %s", value))
	else
		local v6 = v5[math.random(1, #v5)]
		return (playCached(path, v6.id, v6.props, p))
	end
end

local v5 = {}
local folder = nil

local function getWarmContainer()
	if folder and folder.Parent then
		return folder
	end

	folder = Instance.new("Folder")
	folder.Name = "AudioPrewarm"
	folder.Parent = SoundService
	return folder
end

local function populateWarmSet(p, name)
	if not waitForManifest(10) then
		warn(string.format("[Audio] manifest unavailable, cannot prewarm: %s", name))
		return
	end

	local node = resolveNode(name)

	if not node or p.count <= 0 then
		return
	end

	local folder2 = Instance.new("Folder")
	folder2.Name = name

	for _, v6 in ipairs((collectLeaves(node))) do
		local sound = Instance.new("Sound")
		sound.SoundId = v6.id
		sound.Volume = 0
		sound.Parent = folder2
	end

	p.folder = folder2

	if not (folder and folder.Parent) then
		folder = Instance.new("Folder")
		folder.Name = "AudioPrewarm"
		folder.Parent = SoundService
	end

	folder2.Parent = folder

	if p.count <= 0 then
		folder2:Destroy()
		p.folder = nil
	end
end

function Audio.Prewarm(_, value: string, instance)
	if isServer then
		return
	end

	local path = normalizePath(value) -- equivalent call inferred; original call site unknown
	local v6 = v5[path]

	if v6 then
		v6.count += 1
	else
		local v7 = {
			count = 1,
			folder = nil
		}
		v5[path] = v7
		task.spawn(populateWarmSet, v7, path)
	end

	if typeof(instance) == "Instance" then
		instance.Destroying:Once(function()
			Audio:Release(value)
		end)
	end
end

function Audio:Release(value: string)
	local path = normalizePath(value) -- equivalent call inferred; original call site unknown
	local v6 = v5[path]

	if not v6 then
		return
	end

	v6.count -= 1

	if v6.count > 0 then
		return
	end

	v5[path] = nil

	if v6.folder then
		v6.folder:Destroy()
	end
end

local collectImmediate

collectImmediate = function(leaf, path, options)
	local v6 = options or {}
	local v7

	if typeof(leaf) == "table" then
		v7 = leaf.__sound == true
	else
		v7 = false
	end

	if v7 then
		if leaf.tier == "Immediate" then
			table.insert(v6, {
				path = path,
				leaf = leaf
			})
		end
	else
		if typeof(leaf) ~= "table" then
			return v6
		end

		for k, v8 in pairs(leaf) do
			collectImmediate(v8, path == "" and k or path .. "." .. k, v6)
		end
	end

	return v6
end

local function warmImmediateTier()
	if not v3 or next(v3) == nil then
		return
	end

	local v6 = collectImmediate(v3, "")
	task.spawn(function()
		for i, v7 in ipairs(v6) do
			if not v4[v7.path] then
				local sound = Instance.new("Sound")
				sound.SoundId = v7.leaf.id
				sound.SoundGroup = nil
				inheritProperties(sound, {
					Volume = 0,
					Looped = false
				}, mergedBase(v7.leaf.props))
				v4[v7.path] = sound
				sound:Play()
				task.spawn(function()
					local v9 = os.clock() + 10

					while not sound.IsLoaded and os.clock() < v9 do
						RunService.Heartbeat:Wait()
					end

					sound:Stop()
				end)
			end

			if i % 8 == 0 then
				RunService.Heartbeat:Wait()
			end
		end
	end)
end

local function readPublishedManifest()
	local audioManifest = ReplicatedStorage:WaitForChild("AudioManifest", 2)

	if not audioManifest then
		return false
	end

	local v6 = os.clock() + 2

	while audioManifest.Value == "" and os.clock() < v6 do
		task.wait(0.05)
	end

	if audioManifest.Value == "" then
		return false
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(audioManifest.Value)
	end)

	if success and typeof(result) == "table" then
		v3 = result
		return true
	end

	warn("[Audio] published manifest could not be decoded, falling back to request")
	return false
end

local function requestManifest()
	local Network = require(script.Parent:WaitForChild("Network"))

	for i = 1, 20 do
		local success, result = pcall(function()
			return Network:Get("Audio_GetManifest")
		end)

		if success and typeof(result) == "table" then
			v3 = result
			return true
		else
			task.wait((math.min(i * 0.5, 3)))
		end
	end

	return false
end

if isServer then
	task.spawn(function()
		local sharedModules = ServerStorage:WaitForChild("SharedModules", 10)
		local audioBouncer = sharedModules and sharedModules:FindFirstChild("AudioBouncer")

		if not audioBouncer then
			warn("[Audio] AudioBouncer module not found - path-based playback disabled")
			return
		end

		local module = require(audioBouncer)
		v3 = module:WaitForManifest(15)
	end)
else
	task.spawn(function()
		if readPublishedManifest() or requestManifest() then
			warmImmediateTier()
		else
			warn("[Audio] failed to fetch sound manifest from server")
		end
	end)
end

return Audio