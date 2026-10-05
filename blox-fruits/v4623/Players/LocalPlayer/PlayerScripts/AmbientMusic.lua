local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local Notification = require(game.ReplicatedStorage:WaitForChild("Notification"))
local Groups = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("Sound"):WaitForChild("Groups"))
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local locations = _WorldOrigin:WaitForChild("Locations")
local locations2 = _WorldOrigin:WaitForChild("Sounds"):WaitForChild("Locations")
local v = {
	cj_oyer = true,
	azarth = nil,
	Player1 = true,
	Player2 = true
}

for _, child in pairs(locations:GetChildren()) do
	child.Transparency = 1
end

local localPlayer = game.Players.LocalPlayer
local v2 = nil
local humanoidRootPart = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function charAdded(character)
	v2 = character
	humanoidRootPart = v2 and v2:WaitForChild("HumanoidRootPart")
end

localPlayer.CharacterAdded:Connect(charAdded)

if localPlayer.Character then
	charAdded(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

local function isDevMuted()
	local Global = require(game.ReplicatedStorage.Global)

	if Global.TestGame and v[localPlayer.Name:lower()] or localPlayer.Name == "CJ_Oyer" then
		return true
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkIfMute(p)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.TestGame and v[localPlayer.Name:lower()] or localPlayer.Name == "CJ_Oyer" then
		p.Volume = 0
	end
end

local v3 = nil

local function updateUnderwaterAmbience(name: string)
	local v4

	if name == "Underwater City" then
		local Global = require(game.ReplicatedStorage.Global)
		v4 = not (Global.TestGame and v[localPlayer.Name:lower()] and true) and localPlayer.Name ~= "CJ_Oyer"
	else
		v4 = false
	end

	if v4 == (v3 ~= nil) then
		return
	end

	if v4 then
		local v5 = Util.Sound:Play("UnderwaterCityBonusMoments.Underwater_Ambience_01", nil, {
			fadeIn = 1.5,
			group = "LowPriority"
		})
		v5.Looped = true
		v3 = v5
	elseif v3 then
		Util.Sound:FadeOut(v3, 1.5)
		v3 = nil
	end
end

local name = nil
local position = nil

local function setLocation(state)
	if state.NoNotification == nil and state.LocationPart:GetAttribute("NoNotification") then
		state.NoNotification = true
	end

	local sound = state.SoundLocationPart:FindFirstChild("Sound")
	local soundId

	if sound:GetAttribute("SoundId") == nil then
		soundId = sound.SoundId
	else
		soundId = sound:GetAttribute("SoundId")
	end

	local timePosition

	if sound:GetAttribute("TimePosition") == nil then
		timePosition = sound.TimePosition
	else
		timePosition = sound:GetAttribute("TimePosition")
	end

	local v4 = nil

	if name then
		if state.LocationPart.Name == name then
			return
		end

		for _, sound2 in pairs(locations2:GetChildren()) do
			if sound2.Name == "" then
				continue
			end

			assert(sound2:IsA("Sound"))

			if sound2.SoundId == soundId then
				timePosition = sound2.TimePosition
				v4 = sound2
			else
				sound2.Name = ""
				Util.Sound:FadeOut(sound2, 1.5)
			end
		end
	end

	name = state.LocationPart.Name
	local Global = require(game.ReplicatedStorage.Global)
	Global.CurrentLocation = name
	updateUnderwaterAmbience(name)
	local v5 = v4 or Instance.new("Sound")
	local soundIdChangedConnection = nil
	local nameChangedConnection = nil
	soundIdChangedConnection = sound:GetAttributeChangedSignal("SoundId"):Connect(function()
		name = "none"
		soundIdChangedConnection:Disconnect()
		nameChangedConnection:Disconnect()
	end)
	nameChangedConnection = v5:GetPropertyChangedSignal("Name"):Connect(function()
		if v5.Name == "" then
			soundIdChangedConnection:Disconnect()
			nameChangedConnection:Disconnect()
		end
	end)
	local playbackSpeed

	if sound:GetAttribute("PlaybackSpeed") == nil then
		playbackSpeed = sound.PlaybackSpeed
	else
		playbackSpeed = sound:GetAttribute("PlaybackSpeed")
	end

	v5.PlaybackSpeed = playbackSpeed
	local rollOffMinDistance

	if sound:GetAttribute("RollOffMinDistance") == nil then
		rollOffMinDistance = sound.RollOffMinDistance
	else
		rollOffMinDistance = sound:GetAttribute("RollOffMinDistance")
	end

	v5.RollOffMinDistance = rollOffMinDistance
	local rollOffMaxDistance

	if sound:GetAttribute("RollOffMaxDistance") == nil then
		rollOffMaxDistance = sound.RollOffMaxDistance
	else
		rollOffMaxDistance = sound:GetAttribute("RollOffMaxDistance")
	end

	v5.RollOffMaxDistance = rollOffMaxDistance
	local rollOffMode

	if sound:GetAttribute("RollOffMode") == nil then
		rollOffMode = sound.RollOffMode
	else
		rollOffMode = sound:GetAttribute("RollOffMode")
	end

	v5.RollOffMode = rollOffMode
	v5.TimePosition = timePosition
	local soundId2

	if sound:GetAttribute("SoundId") == nil then
		soundId2 = sound.SoundId
	else
		soundId2 = sound:GetAttribute("SoundId")
	end

	v5.SoundId = soundId2
	local playOnRemove

	if sound:GetAttribute("PlayOnRemove") == nil then
		playOnRemove = sound.PlayOnRemove
	else
		playOnRemove = sound:GetAttribute("PlayOnRemove")
	end

	v5.PlayOnRemove = playOnRemove
	local volume

	if sound:GetAttribute("Volume") == nil then
		volume = sound.Volume
	else
		volume = sound:GetAttribute("Volume")
	end

	v5.Volume = volume
	v5.Name = assert(name)
	v5.Looped = true
	Groups.assign(v5, "LowPriority")
	checkIfMute(v5) -- equivalent call inferred; original call site unknown

	if not v5.Playing then
		v5:Play()
	end

	v5.Parent = locations2
	local ambient = state.SoundLocationPart:FindFirstChild("Ambient")

	if ambient then
		for _, child in pairs(ambient:GetChildren()) do
			if not (child:IsA("Sound") or child:IsA("StringValue") and child.Name ~= "Sound") then
				continue
			end

			local sound2 = Instance.new("Sound")
			local playbackSpeed2

			if child:GetAttribute("PlaybackSpeed") == nil then
				playbackSpeed2 = child.PlaybackSpeed
			else
				playbackSpeed2 = child:GetAttribute("PlaybackSpeed")
			end

			sound2.PlaybackSpeed = playbackSpeed2
			local rollOffMinDistance2

			if child:GetAttribute("RollOffMinDistance") == nil then
				rollOffMinDistance2 = child.RollOffMinDistance
			else
				rollOffMinDistance2 = child:GetAttribute("RollOffMinDistance")
			end

			sound2.RollOffMinDistance = rollOffMinDistance2
			local rollOffMaxDistance2

			if child:GetAttribute("RollOffMaxDistance") == nil then
				rollOffMaxDistance2 = child.RollOffMaxDistance
			else
				rollOffMaxDistance2 = child:GetAttribute("RollOffMaxDistance")
			end

			sound2.RollOffMaxDistance = rollOffMaxDistance2
			local rollOffMode2

			if child:GetAttribute("RollOffMode") == nil then
				rollOffMode2 = child.RollOffMode
			else
				rollOffMode2 = child:GetAttribute("RollOffMode")
			end

			sound2.RollOffMode = rollOffMode2
			local timePosition2

			if child:GetAttribute("TimePosition") == nil then
				timePosition2 = child.TimePosition
			else
				timePosition2 = child:GetAttribute("TimePosition")
			end

			sound2.TimePosition = timePosition2
			local soundId3

			if child:GetAttribute("SoundId") == nil then
				soundId3 = child.SoundId
			else
				soundId3 = child:GetAttribute("SoundId")
			end

			sound2.SoundId = soundId3
			local playOnRemove2

			if child:GetAttribute("PlayOnRemove") == nil then
				playOnRemove2 = child.PlayOnRemove
			else
				playOnRemove2 = child:GetAttribute("PlayOnRemove")
			end

			sound2.PlayOnRemove = playOnRemove2
			local playing

			if child:GetAttribute("Playing") == nil then
				playing = child.Playing
			else
				playing = child:GetAttribute("Playing")
			end

			sound2.Playing = playing
			local volume2

			if child:GetAttribute("Volume") == nil then
				volume2 = child.Volume
			else
				volume2 = child:GetAttribute("Volume")
			end

			sound2.Volume = volume2
			sound2.Name = name
			sound2.Looped = true
			Groups.assign(sound2, "LowPriority")
			checkIfMute(sound2) -- equivalent call inferred; original call site unknown
			sound2.Parent = locations2
			sound2:Play()
		end
	end

	game.SoundService.AmbientReverb = Enum.ReverbType[state.SoundLocationPart:GetAttribute("AmbientReverb") or "NoReverb"]

	if not state.NoNotification then
		local Global2 = require(game.ReplicatedStorage.Global)

		if Global2.InCutscene then
			return
		else
			Notification.new(string.format("<%s>", name)):Display()
		end
	end
end

if workspace._WorldOrigin.Locations:FindFirstChild("Sea") then
	setLocation({
		LocationPart = workspace._WorldOrigin.Locations.Sea,
		SoundLocationPart = workspace._WorldOrigin.Locations.Sea,
		Notification = true
	})
end

repeat
	wait()
until v2 and v2:FindFirstChild("CharacterReady")

while true do
	if humanoidRootPart and humanoidRootPart.Parent then
		if position and (humanoidRootPart.Position - position).Magnitude >= 500 then
			task.wait(0.2)
			position = nil
		else
			local v4 = {}

			for _, child in pairs(locations:GetChildren()) do
				local position2 = humanoidRootPart.Position
				local position3 = child.Position
				local radiusType = child:GetAttribute("RadiusType")

				if radiusType and radiusType.Y ~= 1 then
					position2 = humanoidRootPart.Position * radiusType
					position3 = child.Position * radiusType
				end

				if (position3 - position2).Magnitude < child.Mesh.Scale.X / 2 then
					table.insert(v4, {
						Dist = (position3 - position2).Magnitude,
						Object = child
					})
				end
			end

			table.sort(v4, function(a, b)
				return a.Dist < b.Dist
			end)

			if #v4 > 0 then
				local object = v4[1].Object
				local object2 = object

				for i = 1, #v4 do
					if v4[i].Object:GetAttribute("SinkMusic") then
						continue
					end

					object2 = v4[i].Object
					break
				end

				setLocation({
					LocationPart = object,
					SoundLocationPart = object2,
					NoNotification = name == "none" or nil
				})
			else
				local sea = workspace._WorldOrigin.Locations.Sea
				setLocation({
					LocationPart = sea,
					SoundLocationPart = sea,
					NoNotification = name == "none" or nil
				})
			end

			position = humanoidRootPart.Position
			task.wait(1.5)
		end
	else
		task.wait(1.5)
	end
end