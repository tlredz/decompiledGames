local createVector = vector.create
local Sound = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local ContentProvider = game:GetService("ContentProvider")
local CollectionService = game:GetService("CollectionService")
local folder = Instance.new("Folder")
folder.Name = "Sounds"
folder.Parent = localPlayer
local random = Random.new()
local v = {}
local v2 = {}
Client.Events.RequestReplicateSound:Connect(function(_, ...)
	Sound.Play(...)
end)
Client.Events.PlaySound:Connect(function(...)
	Sound.Play(...)
end)

function Sound.Play(value, options)
	local v3 = options or {}
	local v4 = type(value) == "number" and value or v2[value]

	if v4 == nil then
		warn("Tried to play sound: " .. value .. " (doesn't exist)")
		return
	end

	if v2[value] == nil then
		warn("sound does not exist:", v4)
		return
	end

	if v3.Replicate then
		v3.Replicate = nil
		Client.Events.RequestReplicateSound:FireOtherClients(value, v3.ReplicationProperties or v3)
		v3.ReplicationProperties = nil
	end

	local clone = v2[value]

	if clone:GetAttribute("DefaultVolume") == nil then
		clone:SetAttribute("DefaultVolume", clone.Volume)
	end

	clone.Volume = clone:GetAttribute("DefaultVolume")

	for _, soundEffect in pairs(clone:GetChildren()) do
		if soundEffect:IsA("SoundEffect") then
			soundEffect:Destroy()
		end
	end

	if v3.PitchShift then
		local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect", clone)
		pitchShiftSoundEffect.Octave = v3.PitchShift
		v3.PitchShift = nil
	end

	if v3.VarySpeed then
		clone.PlaybackSpeed = 1 - random:NextNumber() * v3.VarySpeed / 2
		v3.VarySpeed = nil
	end

	local position = v3.Position
	v3.Position = nil
	local instance = v3.Instance
	v3.Instance = nil
	local duplicate = v3.Duplicate
	v3.Duplicate = nil

	for k, v5 in pairs(v3) do
		clone[k] = v5
	end

	if instance then
		clone = clone:Clone()
		clone.Parent = instance
	elseif duplicate then
		local parent = clone.Parent
		clone = clone:Clone()
		clone.Parent = parent
	elseif position then
		local part = Instance.new("Part")
		part.Size = createVector(0.1, 0.1, 0.1)
		part.Transparency = 1
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Anchored = true
		part.CFrame = CFrame.new(position)
		part.Parent = workspace
		clone = clone:Clone()
		clone.Parent = part
	end

	local stopSoundConnection = nil
	stopSoundConnection = Client.Events.StopSound:Connect(function(p, options2)
		local v5 = options2 or {}

		if p == value then
			v[value] = nil
			stopSoundConnection:Disconnect()

			if v5.DelayTime then
				wait(v5.DelayTime)
			end

			if v5.FadeTime then
				local volume = clone.Volume
				Client.TweenModule.new(function(p2)
					clone.Volume = volume * (1 - p2)
				end, v5.FadeTime):Start()
				wait(v5.FadeTime)
			end

			clone:Stop()

			if position then
				clone.Parent:Destroy()
			elseif instance or duplicate then
				clone:Destroy()
			end
		end
	end)
	clone:Play()

	if clone.Looped then
		v[value] = true
	else
		task.spawn(function()
			if not clone.IsLoaded then
				clone.Loaded:Wait()
			end

			wait(clone.TimeLength + 0.1)

			if position then
				clone.Parent:Destroy()
			elseif instance or duplicate then
				clone:Destroy()
			end

			stopSoundConnection:Disconnect()
		end)
	end
end

function CreateSoundObject(name, p)
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = "rbxassetid://" .. p
	sound.Parent = folder
	v2[name] = sound
	return sound
end

Sound.CreateSoundObject = CreateSoundObject

function Sound.GetSoundObject(p)
	return v2[p]
end

function PreloadAudio()
	local instances = {}
	local instances2 = {}

	for _, instance in pairs(game.ReplicatedStorage.Core.Sounds:GetChildren()) do
		v2[instance.Name] = instance

		if CollectionService:HasTag(instance, "SoundPrio") then
			table.insert(instances, instance)
		elseif not CollectionService:HasTag(instance, "NoSoundPrio") then
			table.insert(instances2, instance)
		end
	end

	task.spawn(function()
		ContentProvider:PreloadAsync(instances)
	end)
	task.delay(10, function()
		local v3 = {}

		for _, v4 in pairs(instances2) do
			table.insert(v3, v4)

			if not (#v3 >= 25) then
				continue
			end

			ContentProvider:PreloadAsync(v3)
			task.wait(0.5)
			v3 = {}
		end

		if #v3 > 0 then
			ContentProvider:PreloadAsync(v3)
		end
	end)
end

function Sound.Init()
	PreloadAudio()
end

return Sound