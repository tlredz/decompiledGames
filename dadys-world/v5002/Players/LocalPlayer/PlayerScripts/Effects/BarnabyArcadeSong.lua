local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local v = nil

local function musicMuted()
	return v ~= nil and v.Value == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function songsEnabled()
	local info = Workspace:FindFirstChild("Info")
	local barnabyArcadeSongEnabled = info and info:GetAttribute("BarnabyArcadeSongEnabled")

	if barnabyArcadeSongEnabled == nil or barnabyArcadeSongEnabled then
		return true
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isBarnabyOverlay(p)
	return p.Name == "SwimmyBarnaby" or string.match(p.Name, "^SwimmyBarnaby_") ~= nil
end

local function findOverlayDisplayPart(folder)
	local v2 = 0
	local v3 = nil

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local name = string.lower(part.Name)

		if not string.find(name, "screen", 1, true) then
			continue
		end

		if string.find(name, "border", 1, true) or string.find(name, "small", 1, true) or string.find(
			name,
			"_02",
			1,
			true
		) then
			continue
		end

		local v4 = part.Size.X * part.Size.Y

		if not (v2 < v4) then
			continue
		end

		v3 = part
		v2 = v4
	end

	return v3
end

local v2 = {}
local v3 = nil

local function resolveSource(gen)
	for _, child in ipairs(gen:GetChildren()) do
		if not isBarnabyOverlay(child) then
			continue
		end

		local overlayDisplayPart = findOverlayDisplayPart(child)

		if not overlayDisplayPart then
			continue
		end

		local surfaceGui = overlayDisplayPart:FindFirstChildWhichIsA("SurfaceGui")
		local menuMusic = surfaceGui and surfaceGui:FindFirstChild("MenuMusic")

		if not menuMusic or not menuMusic:IsA("Sound") or menuMusic.SoundId == "" then
			return overlayDisplayPart, nil, nil
		end

		local v4 = not (menuMusic.Volume and menuMusic.Volume > 0) and 0.5 or menuMusic.Volume or 0.5
		return overlayDisplayPart, menuMusic.SoundId, v4
	end

	return nil, nil, nil
end

local function makeEmitter(parent, soundId: string, volume: number)
	local sound = Instance.new("Sound")
	sound.Name = "BarnabyArcadeSong"
	sound.SoundId = soundId
	sound.Looped = true
	sound.Volume = volume
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = 10
	sound.RollOffMaxDistance = 70
	sound.Parent = parent
	return sound
end

local function shouldPlay(p)
	local v4 = songsEnabled() -- equivalent call inferred; original call site unknown

	if not v4 then
		return v4
	end

	v4 = v == nil or v.Value ~= true

	if v4 then
		if p.sound == nil or p.gen == v3 then
			return false
		else
			return p.gen.Parent ~= nil
		end
	end

	return v4
end

local function refresh(state)
	if not (state.gen and state.gen.Parent) then
		return
	end

	if not (state.sound and state.sound.Parent) then
		local source, soundId, v5 = resolveSource(state.gen)
		state.part = source

		if source and soundId then
			local sound = Instance.new("Sound")
			sound.Name = "BarnabyArcadeSong"
			sound.SoundId = soundId
			sound.Looped = true
			sound.Volume = v5 or 0.5
			sound.RollOffMode = Enum.RollOffMode.InverseTapered
			sound.RollOffMinDistance = 10
			sound.RollOffMaxDistance = 70
			sound.Parent = source
			state.sound = sound
		end
	end

	if not state.sound then
		return
	end

	local v4 = songsEnabled() -- equivalent call inferred; original call site unknown

	if v4 then
		v4 = v == nil or v.Value ~= true

		if v4 then
			if state.sound == nil or state.gen == v3 then
				v4 = false
			else
				v4 = state.gen.Parent ~= nil
			end
		end
	end

	if v4 and not state.sound.IsPlaying then
		state.sound:Play()
	elseif not v4 and state.sound.IsPlaying then
		state.sound:Stop()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshAll()
	for _, v4 in pairs(v2) do
		refresh(v4)
	end
end

local function track(parent)
	if v2[parent] then
		return
	end

	local v4 = false

	for _, child in ipairs(parent:GetChildren()) do
		if not isBarnabyOverlay(child) then
			continue
		end

		v4 = true
		break
	end

	if not v4 then
		return
	end

	v2[parent] = {
		gen = parent
	}
	refresh(v2[parent])
end

-- equivalent calls inferred from this helper; original call sites unknown
local function untrack(parent)
	local v4 = v2[parent]

	if not v4 then
		return
	end

	v2[parent] = nil

	if v4.sound then
		pcall(function()
			v4.sound:Destroy()
		end)
		v4.sound = nil
	end
end

local function bindDecoding(character)
	local function hook(objectValue)
		if not objectValue:IsA("ObjectValue") then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			local value = objectValue.Value

			if not (value and value:IsA("Model") and value) then
				value = nil
			end

			v3 = value
			refreshAll() -- equivalent call inferred; original call site unknown
		end

		objectValue:GetPropertyChangedSignal("Value"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end

	local decoding = character:FindFirstChild("Decoding")

	if decoding then
		hook(decoding)
	end

	character.ChildAdded:Connect(function(child)
		if child.Name == "Decoding" then
			hook(child)
		end
	end)
	character.ChildRemoved:Connect(function(child)
		if child.Name == "Decoding" then
			v3 = nil
			refreshAll() -- equivalent call inferred; original call site unknown
		end
	end)
end

localPlayer.CharacterAdded:Connect(function(character)
	v3 = nil
	bindDecoding(character)
end)

if localPlayer.Character then
	bindDecoding(localPlayer.Character)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindInfoToggle()
	local info = Workspace:FindFirstChild("Info")

	if not info then
		return false
	end

	info:GetAttributeChangedSignal("BarnabyArcadeSongEnabled"):Connect(refreshAll)
	return true
end

-- equivalent call inferred; original call site unknown
if not bindInfoToggle() then
	Workspace.ChildAdded:Connect(function(child)
		if child.Name == "Info" then
			local info = Workspace:FindFirstChild("Info")

			if not info then
				return
			end

			info:GetAttributeChangedSignal("BarnabyArcadeSongEnabled"):Connect(refreshAll)
		end
	end)
end

local function bindMusicToggle()
	if v then
		return true
	end

	local playerData = ReplicatedStorage:FindFirstChild("PlayerData")
	local child = playerData and playerData:FindFirstChild((tostring(localPlayer.UserId)))
	local musicToggle = child and child:FindFirstChild("MusicToggle")

	if not (musicToggle and musicToggle:IsA("BoolValue")) then
		return false
	end

	v = musicToggle
	musicToggle:GetPropertyChangedSignal("Value"):Connect(refreshAll)
	refreshAll() -- equivalent call inferred; original call site unknown
	return true
end

bindMusicToggle()
Workspace.DescendantAdded:Connect(function(descendant)
	if isBarnabyOverlay(descendant) then
		local parent = descendant.Parent

		if parent and parent:IsA("Model") then
			task.defer(function()
				if parent.Parent then
					track(parent)
				end
			end)
		end
	end
end)
Workspace.DescendantRemoving:Connect(function(descendant)
	if isBarnabyOverlay(descendant) then
		local parent = descendant.Parent

		if not parent then
			return
		end

		local v4 = false

		for _, child in ipairs(parent:GetChildren()) do
			if not (child ~= descendant and (child.Name == "SwimmyBarnaby" or string.match(
				child.Name,
				"^SwimmyBarnaby_"
			) ~= nil)) then
				continue
			end

			v4 = true
			break
		end

		if not v4 then
			untrack(parent) -- equivalent call inferred; original call site unknown
		end
	end
end)
task.spawn(function()
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if not isBarnabyOverlay(descendant) then
			continue
		end

		local parent = descendant.Parent

		if parent and parent:IsA("Model") then
			track(parent)
		end
	end

	refreshAll() -- equivalent call inferred; original call site unknown

	while true do
		task.wait(2)
		bindMusicToggle()
		refreshAll() -- equivalent call inferred; original call site unknown
	end
end)