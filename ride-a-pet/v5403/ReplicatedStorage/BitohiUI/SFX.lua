local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local SFXBank = require(script.Parent:WaitForChild("SFXBank"))
local bindableEvent = Instance.new("BindableEvent")
bindableEvent.Name = "Played"
local SFX = {
	Played = bindableEvent.Event
}
local v = nil
local v2 = {}

local function getMaster()
	if v then
		return v
	end

	local v3 = SoundService:FindFirstChild("UI")

	if not (v3 and v3:IsA("SoundGroup")) then
		v3 = Instance.new("SoundGroup")
		v3.Name = "UI"
		v3.Parent = SoundService
	end

	v = v3
	return v
end

local function getGroup(name: string)
	local v3 = v2[name]

	if v3 then
		return v3
	end

	if not v then
		local v4 = SoundService:FindFirstChild("UI")

		if not (v4 and v4:IsA("SoundGroup")) then
			v4 = Instance.new("SoundGroup")
			v4.Name = "UI"
			v4.Parent = SoundService
		end

		v = v4
	end

	local parent = v
	local v5 = parent:FindFirstChild(name)

	if not (v5 and v5:IsA("SoundGroup")) then
		v5 = Instance.new("SoundGroup")
		v5.Name = name
		v5.Parent = parent
	end

	v2[name] = v5
	return v5
end

local function normalise(value: string)
	return (value:gsub("%W", ""):lower():gsub("sfx$", ""))
end

local sounds = script.Parent:FindFirstChild("Sounds")

local function resolveSource(childName: string, childName2: string, p)
	if sounds then
		local child = sounds:FindFirstChild(childName)

		if child then
			local v3 = {
				[childName2:gsub("%W", ""):lower():gsub("sfx$", "")] = true
			}

			if p.Aliases then
				for _, alias in ipairs(p.Aliases) do
					v3[alias:gsub("%W", ""):lower():gsub("sfx$", "")] = true
				end
			end

			for _, sound in ipairs(child:GetChildren()) do
				if sound:IsA("Sound") and v3[sound.Name:gsub("%W", ""):lower():gsub("sfx$", "")] and sound.SoundId ~= "" then
					return sound.SoundId
				end
			end
		end
	end

	local id = p.Id

	if not id or id == "" then
		return nil
	end

	if tonumber(id) then
		return "rbxassetid://" .. id
	end

	return id
end

local v3 = {}
local v4 = {}
local v5 = {}
local clones = {}

local function bankEntries(p: string)
	local v6 = SFXBank[p]
	local v7 = clones[p]

	if not v7 then
		return v6
	end

	if not v6 then
		return v7
	end

	local clone = table.clone(v6)

	for k, v8 in pairs(v7) do
		clone[k] = v8
	end

	return clone
end

local function buildNamespace(childName: string)
	if v4[childName] then
		return
	end

	v4[childName] = true
	local clone = SFXBank[childName]
	local v6 = clones[childName]

	if v6 then
		if clone then
			clone = table.clone(clone)

			for k, v7 in pairs(v6) do
				clone[k] = v7
			end
		else
			clone = v6
		end
	end

	local child = sounds and sounds:FindFirstChild(childName)

	if clone or child then
		local group = getGroup(childName)

		if child then
			for _, sound in ipairs(child:GetChildren()) do
				if not (sound:IsA("Sound") and sound.SoundId ~= "") then
					continue
				end

				local v7 = childName .. "." .. sound.Name
				local child2 = group:FindFirstChild(sound.Name)

				if child2 then
					child2:Destroy()
				end

				local clone2 = sound:Clone()
				clone2.SoundGroup = group
				clone2.Parent = group
				v3[v7] = {
					sound = clone2,
					throttle = 0.05,
					noRetrigger = false
				}
			end
		end

		for childName2, v7 in pairs(clone or {}) do
			local v8 = childName .. "." .. childName2
			local v9 = {
				sound = nil,
				throttle = v7.Throttle or 0.05,
				noRetrigger = v7.NoRetrigger == true
			}
			local source = resolveSource(childName, childName2, v7)

			if source then
				local child2 = group:FindFirstChild(childName2)

				if child2 then
					child2:Destroy()
				end

				local sound = Instance.new("Sound")
				sound.Name = childName2
				sound.SoundId = source
				sound.Volume = v7.Volume or 0.5
				sound.PlaybackSpeed = v7.Speed or 1
				sound.SoundGroup = group
				sound.Parent = group
				v9.sound = sound
			end

			v3[v8] = v9
		end
	elseif RunService:IsStudio() then
		warn(("[SFX] unknown namespace %q"):format(childName))
	end
end

local function split(value: string)
	local v6 = value:find(".", 1, true)

	if v6 then
		return value:sub(1, v6 - 1), value:sub(v6 + 1)
	end

	return nil, nil
end

function SFX.play(value: string)
	local v6 = v3[value]

	if not v6 then
		local v7 = value:find(".", 1, true)
		local v8

		if v7 then
			v8 = value:sub(1, v7 - 1)
			value:sub(v7 + 1)
		end

		if not v8 then
			return
		end

		buildNamespace(v8)
		v6 = v3[value]

		if not v6 then
			if RunService:IsStudio() then
				warn(("[SFX] unknown key %q"):format(value))
			end

			v3[value] = {
				sound = nil,
				throttle = 0,
				noRetrigger = false
			}
			return
		end
	end

	local sound = v6.sound

	if not sound or v6.noRetrigger and sound.IsPlaying then
		return
	end

	local now = os.clock()
	local v7 = v5[value]

	if v7 and now - v7 < v6.throttle then
		return
	end

	v5[value] = now
	sound.TimePosition = 0
	sound:Play()
	bindableEvent:Fire(value, sound.SoundId, sound)
end

function SFX.stop(p: string)
	local v6 = v3[p]

	if v6 and v6.sound then
		v6.sound:Stop()
	end
end

function SFX.preload(name: string)
	buildNamespace(name)
	task.spawn(function()
		local sounds2 = {}

		for k, v6 in pairs(v3) do
			if v6.sound and k:sub(1, #name + 1) == name .. "." then
				sounds2[#sounds2 + 1] = v6.sound
			end
		end

		if #sounds2 > 0 then
			pcall(ContentProvider.PreloadAsync, ContentProvider, sounds2)
		end
	end)
end

function SFX.register(p: string, items)
	local v6 = clones[p]

	if v6 then
		for k, item in pairs(items) do
			v6[k] = item
		end
	else
		clones[p] = table.clone(items)
	end

	v4[p] = nil
	local v7 = p .. "."

	for k, v8 in pairs(v3) do
		if k:sub(1, #v7) ~= v7 then
			continue
		end

		if v8.sound then
			v8.sound:Destroy()
		end

		v3[k] = nil
		v5[k] = nil
	end
end

function SFX.setVolume(name: string, value: number)
	local group = getGroup(name)
	group.Volume = math.clamp(value, 0, 1)
end

function SFX.setMasterVolume(value: number)
	if not v then
		local v6 = SoundService:FindFirstChild("UI")

		if not (v6 and v6:IsA("SoundGroup")) then
			v6 = Instance.new("SoundGroup")
			v6.Name = "UI"
			v6.Parent = SoundService
		end

		v = v6
	end

	v.Volume = math.clamp(value, 0, 1)
end

function SFX.refresh()
	sounds = script.Parent:FindFirstChild("Sounds")

	for _, v6 in pairs(v3) do
		if v6.sound then
			v6.sound:Destroy()
		end
	end

	table.clear(v3)
	table.clear(v4)
	table.clear(v5)
end

return SFX