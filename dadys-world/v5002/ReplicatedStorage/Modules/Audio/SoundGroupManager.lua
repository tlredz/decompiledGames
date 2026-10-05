local createVector = vector.create
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local SoundGroupManager = {}
local v = {
	Master = {
		volume = 1,
		parent = nil,
		limiter = {
			enabled = true,
			maxLevel = -1.5
		}
	},
	MonsterCombat = {
		volume = 0.9,
		parent = "Master"
	},
	MonsterState = {
		volume = 0.85,
		parent = "Master",
		compressor = {
			sidechain = "MonsterCombat",
			threshold = -12,
			ratio = 2,
			attack = 0.01,
			release = 0.15
		}
	},
	MonsterAmbient = {
		volume = 0.75,
		parent = "Master",
		compressor = {
			sidechain = "MonsterState",
			threshold = -14,
			ratio = 2.5,
			attack = 0.02,
			release = 0.25
		}
	},
	MonsterMusic = {
		volume = 0.75,
		parent = "Master"
	},
	Monster = {
		volume = 0.85,
		parent = "Master"
	},
	Footsteps = {
		volume = 0.8,
		parent = "Master",
		compressor = {
			sidechain = "MonsterState",
			threshold = -14,
			ratio = 2.5,
			attack = 0.01,
			release = 0.15
		}
	},
	SFX = {
		volume = 0.8,
		parent = "Master",
		compressor = {
			sidechain = "MonsterCombat",
			threshold = -15,
			ratio = 2.5,
			attack = 0.02,
			release = 0.25
		}
	},
	Ambience = {
		volume = 0.6,
		parent = "Master",
		compressor = {
			sidechain = "MonsterState",
			threshold = -16,
			ratio = 2,
			attack = 0.03,
			release = 0.4
		}
	},
	Music = {
		volume = 0.5,
		parent = "Master",
		compressor = {
			sidechain = "MonsterCombat",
			threshold = -18,
			ratio = 2.5,
			attack = 0.04,
			release = 0.6
		}
	},
	UI = {
		volume = 0.65,
		parent = "Master"
	},
	ItemUsage = {
		volume = 0.75,
		parent = "Master",
		compressor = {
			sidechain = "MonsterCombat",
			threshold = -15,
			ratio = 2,
			attack = 0.02,
			release = 0.25
		}
	},
	Environmental = {
		volume = 0.7,
		parent = "Master",
		compressor = {
			sidechain = "MonsterCombat",
			threshold = -16,
			ratio = 2,
			attack = 0.025,
			release = 0.35
		}
	},
	LevelEvents = {
		volume = 0.85,
		parent = "Master",
		compressor = {
			sidechain = "MonsterCombat",
			threshold = -14,
			ratio = 2,
			attack = 0.02,
			release = 0.3
		}
	},
	Elevator = {
		volume = 0.75,
		parent = "Master",
		compressor = {
			sidechain = "MonsterCombat",
			threshold = -15,
			ratio = 2,
			attack = 0.02,
			release = 0.3
		}
	},
	Machines = {
		volume = 0.8,
		parent = "Master",
		compressor = {
			sidechain = "MonsterCombat",
			threshold = -14,
			ratio = 2,
			attack = 0.02,
			release = 0.25
		}
	}
}
local v2 = {
	Combat = {
		"^Attack",
		"Bite",
		"Slash",
		"^Hit"
	},
	State = {
		"^Growl$",
		"Bark",
		"Frustrated",
		"Spotted",
		"Alerted",
		"LostInterest",
		"Scream",
		"Roar",
		"Rage",
		"Emergence"
	},
	Ambient = {
		"GrowlLoop",
		"RandomGrowl",
		"Idle",
		"IdleAmbient",
		"Breathing",
		"Sniff",
		"Ambient",
		"Feeding",
		"Grounded"
	},
	Music = { "Song", "Theme", "Intro" },
	Footsteps = { "^Footstep" }
}
local v3 = {
	UI = {
		"Tick",
		"Click",
		"TinyTick",
		"Equip",
		"CantUse",
		"ChangeTrinket",
		"PopUp",
		"PlaceSound",
		"CloseSound",
		"Closing",
		"ElectricTick",
		"CountSound",
		"MoneyPopup",
		"Switch",
		"BackDown",
		"RiseUp"
	},
	ItemUsage = {
		"UseSound",
		"Eat",
		"Consume",
		"Drink",
		"Pour",
		"Correct",
		"Fail",
		"AirHorn",
		"Heal",
		"Bandage",
		"Pop",
		"Jawbreaker",
		"Gumball"
	},
	Environmental = {
		"Drip",
		"Splash",
		"Ice",
		"Puddle",
		"Ambient",
		"Wind",
		"Creak",
		"Static",
		"Hum",
		"Loop",
		"Buzz"
	},
	Elevator = {
		"Door",
		"Open",
		"Close",
		"Ding",
		"Elevator",
		"Hiss",
		"ColdAir",
		"Disrupt"
	},
	Machines = {
		"Generator",
		"Valve",
		"Machine",
		"Power",
		"Electric",
		"Motor",
		"Engine",
		"Pump"
	},
	LevelEvents = {
		"Train",
		"Horn",
		"Steam",
		"Crash",
		"Impact",
		"Explosion"
	},
	Music = {
		"Music",
		"Song",
		"BGM",
		"Theme",
		"Radio"
	},
	SFX = {
		"Damage",
		"Hurt",
		"Death",
		"Glitch",
		"TurnOn",
		"TurnOff",
		"Startup",
		"TVClick"
	}
}
local v4 = {
	MonsterFootstep = {
		RollOffMode = Enum.RollOffMode.LinearSquare,
		RollOffMinDistance = 8,
		RollOffMaxDistance = 80,
		EmitterSize = 2
	},
	MonsterVocal = {
		RollOffMode = Enum.RollOffMode.LinearSquare,
		RollOffMinDistance = 15,
		RollOffMaxDistance = 120,
		EmitterSize = 5
	},
	Environmental = {
		RollOffMode = Enum.RollOffMode.Linear,
		RollOffMinDistance = 5,
		RollOffMaxDistance = 40,
		EmitterSize = 3
	},
	Machines = {
		RollOffMode = Enum.RollOffMode.LinearSquare,
		RollOffMinDistance = 10,
		RollOffMaxDistance = 60,
		EmitterSize = 4
	},
	ItemUsage = {
		RollOffMode = Enum.RollOffMode.Linear,
		RollOffMinDistance = 3,
		RollOffMaxDistance = 25,
		EmitterSize = 1
	},
	Elevator = {
		RollOffMode = Enum.RollOffMode.LinearSquare,
		RollOffMinDistance = 8,
		RollOffMaxDistance = 50,
		EmitterSize = 3
	},
	LevelEvents = {
		RollOffMode = Enum.RollOffMode.LinearSquare,
		RollOffMinDistance = 20,
		RollOffMaxDistance = 150,
		EmitterSize = 8
	}
}
local v5 = {
	enabled = true,
	raycastParams = nil,
	updateInterval = 0.1,
	dampingFactor = 0.4,
	lowPassCutoff = 800
}
local v6 = {
	ReverbPresets = {
		Small = Enum.ReverbType.Room,
		Medium = Enum.ReverbType.LivingRoom,
		Large = Enum.ReverbType.Hangar,
		Hallway = Enum.ReverbType.Hallway,
		Cave = Enum.ReverbType.Cave,
		Outside = Enum.ReverbType.Plain
	},
	DistanceFactor = 3.33,
	DopplerScale = 1,
	RolloffScale = 1.2
}
local v7 = {}
local flag = false

local function createSoundGroup(name, data)
	local soundGroup = SoundService:FindFirstChild(name)

	if soundGroup and soundGroup:IsA("SoundGroup") then
		v7[name] = soundGroup
		return soundGroup
	end

	local soundGroup2 = Instance.new("SoundGroup")
	soundGroup2.Name = name
	soundGroup2.Volume = data.volume or 1

	if data.limiter and data.limiter.enabled then
		pcall(function()
			local audioLimiter = Instance.new("AudioLimiter")
			audioLimiter.MaxLevel = data.limiter.maxLevel or -3
			audioLimiter.Parent = soundGroup2
		end)
	end

	if data.parent and v7[data.parent] then
		soundGroup2.Parent = v7[data.parent]
	else
		soundGroup2.Parent = SoundService
	end

	v7[name] = soundGroup2
	return soundGroup2
end

local function addCompressor(parent, p)
	if not p.compressor then
		return
	end

	local compressor = p.compressor
	local sideChain = v7[compressor.sidechain]

	if sideChain then
		pcall(function()
			local compressorSoundEffect = Instance.new("CompressorSoundEffect")
			compressorSoundEffect.Threshold = compressor.threshold or -20
			compressorSoundEffect.Ratio = compressor.ratio or 4
			compressorSoundEffect.Attack = compressor.attack or 0.01
			compressorSoundEffect.Release = compressor.release or 0.3
			compressorSoundEffect.SideChain = sideChain
			compressorSoundEffect.Parent = parent
		end)
	else
		warn("[SoundGroupManager] Sidechain group not found:", compressor.sidechain)
	end
end

function SoundGroupManager.Initialize()
	if flag then
		return v7
	end

	local v8 = {
		"Master",
		"MonsterCombat",
		"MonsterState",
		"MonsterAmbient",
		"MonsterMusic",
		"Monster",
		"Footsteps",
		"SFX",
		"Ambience",
		"Music",
		"UI",
		"ItemUsage",
		"Environmental",
		"LevelEvents",
		"Elevator",
		"Machines"
	}
	v5.raycastParams = RaycastParams.new()
	v5.raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	v5.raycastParams.FilterDescendantsInstances = {}

	for _, v9 in ipairs(v8) do
		local v10 = v[v9]

		if v10 then
			createSoundGroup(v9, v10)
		end
	end

	for _, v9 in ipairs(v8) do
		local v10 = v[v9]
		local parent = v7[v9]

		if v10 and parent then
			addCompressor(parent, v10)
		end
	end

	flag = true
	return v7
end

function SoundGroupManager.GetGroup(p)
	if not flag then
		SoundGroupManager.Initialize()
	end

	return v7[p]
end

function SoundGroupManager.RegisterGroup(name, p2)
	if not v[name] then
		v[name] = p2
	end

	if not flag then
		SoundGroupManager.Initialize()
	end

	return v7[name] or createSoundGroup(name, v[name])
end

function SoundGroupManager:AssignSound(p2)
	if not self then
		return false
	end

	local group = SoundGroupManager.GetGroup(p2)

	if group then
		self.SoundGroup = group
		return true
	end

	warn("[SoundGroupManager] Group not found:", p2)
	return false
end

function SoundGroupManager.AssignSounds(list, p)
	local group = SoundGroupManager.GetGroup(p)

	if not group then
		warn("[SoundGroupManager] Group not found:", p)
		return 0
	end

	local count = 0

	for _, sound in ipairs(list) do
		if not (sound and sound:IsA("Sound")) then
			continue
		end

		sound.SoundGroup = group
		count += 1
	end

	return count
end

function SoundGroupManager.SetGroupVolume(p, value)
	local v8 = v7[p]

	if not v8 then
		return false
	end

	v8.Volume = math.clamp(value, 0, 1)
	return true
end

function SoundGroupManager.GetGroupVolume(p)
	local v8 = v7[p]

	if v8 then
		return v8.Volume
	end

	return nil
end

function SoundGroupManager.SetGroupMuted(p, p2)
	local v8 = v7[p]

	if not v8 then
		return false
	end

	v8.Volume = p2 and 0 or v[p] and v[p].volume or 1
	return true
end

function SoundGroupManager.GetAllGroups()
	if not flag then
		SoundGroupManager.Initialize()
	end

	return v7
end

function SoundGroupManager.AssignMonsterSound(p)
	return SoundGroupManager.AssignSound(p, "Monster")
end

function SoundGroupManager.AssignFootstepSound(p)
	return SoundGroupManager.AssignSound(p, "Footsteps")
end

function SoundGroupManager.AssignSFXSound(p)
	return SoundGroupManager.AssignSound(p, "SFX")
end

function SoundGroupManager.AssignAmbienceSound(p)
	return SoundGroupManager.AssignSound(p, "Ambience")
end

function SoundGroupManager.AssignMusicSound(p)
	local v8 = SoundGroupManager.AssignSound(p, "Music")
	local music = v7.Music

	if music and not CollectionService:HasTag(music, "MusicSource") then
		CollectionService:AddTag(music, "MusicSource")
	end

	return v8
end

function SoundGroupManager.AssignUISound(p)
	return SoundGroupManager.AssignSound(p, "UI")
end

function SoundGroupManager.AssignMonsterCombatSound(p)
	return SoundGroupManager.AssignSound(p, "MonsterCombat")
end

function SoundGroupManager.AssignMonsterStateSound(p)
	return SoundGroupManager.AssignSound(p, "MonsterState")
end

function SoundGroupManager.AssignMonsterAmbientSound(p)
	return SoundGroupManager.AssignSound(p, "MonsterAmbient")
end

function SoundGroupManager.AssignMonsterMusicSound(p)
	return SoundGroupManager.AssignSound(p, "MonsterMusic")
end

function SoundGroupManager.AutoAssignMonsterSound(sound)
	if not (sound and sound:IsA("Sound")) then
		return nil
	end

	local name = sound.Name

	for _, footstep in ipairs(v2.Footsteps) do
		if not name:match(footstep) then
			continue
		end

		SoundGroupManager.AssignSound(sound, "Footsteps")
		return "Footsteps"
	end

	for _, v8 in ipairs(v2.Music) do
		if not name:match(v8) then
			continue
		end

		SoundGroupManager.AssignSound(sound, "MonsterMusic")
		return "MonsterMusic"
	end

	for _, v8 in ipairs(v2.Ambient) do
		if not name:match(v8) then
			continue
		end

		SoundGroupManager.AssignSound(sound, "MonsterAmbient")
		return "MonsterAmbient"
	end

	for _, v8 in ipairs(v2.Combat) do
		if not name:match(v8) then
			continue
		end

		SoundGroupManager.AssignSound(sound, "MonsterCombat")
		return "MonsterCombat"
	end

	for _, v8 in ipairs(v2.State) do
		if not name:match(v8) then
			continue
		end

		SoundGroupManager.AssignSound(sound, "MonsterState")
		return "MonsterState"
	end

	SoundGroupManager.AssignSound(sound, "Monster")
	return "Monster"
end

function SoundGroupManager.AutoAssignAllMonsterSounds(instance)
	if not instance then
		return 0
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance:WaitForChild("HumanoidRootPart", 5)

	if not humanoidRootPart then
		warn("[SoundGroupManager] No HumanoidRootPart found for", instance.Name)
		return 0
	end

	local count = 0

	for _, sound in ipairs(humanoidRootPart:GetChildren()) do
		if sound:IsA("Sound") and SoundGroupManager.AutoAssignMonsterSound(sound) then
			count += 1
		end
	end

	return count
end

function SoundGroupManager.WatchMonsterSounds(instance)
	if not instance then
		return nil
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance:WaitForChild("HumanoidRootPart", 5)

	if humanoidRootPart then
		SoundGroupManager.AutoAssignAllMonsterSounds(instance)
		return (humanoidRootPart.ChildAdded:Connect(function(sound)
			if sound:IsA("Sound") then
				SoundGroupManager.AutoAssignMonsterSound(sound)
			end
		end))
	end

	warn("[SoundGroupManager] Cannot watch sounds - no HumanoidRootPart for", instance.Name)
	return nil
end

function SoundGroupManager.AssignItemUsageSound(p)
	return SoundGroupManager.AssignSound(p, "ItemUsage")
end

function SoundGroupManager.AssignEnvironmentalSound(p)
	return SoundGroupManager.AssignSound(p, "Environmental")
end

function SoundGroupManager.AssignLevelEventSound(p)
	return SoundGroupManager.AssignSound(p, "LevelEvents")
end

function SoundGroupManager.AssignElevatorSound(p)
	return SoundGroupManager.AssignSound(p, "Elevator")
end

function SoundGroupManager.AssignMachineSound(p)
	return SoundGroupManager.AssignSound(p, "Machines")
end

function SoundGroupManager:ConfigureVolumetric(p)
	if not (self and self:IsA("Sound")) then
		return false
	end

	local v8 = v4[p] or {
		RollOffMode = Enum.RollOffMode.LinearSquare,
		RollOffMinDistance = 10,
		RollOffMaxDistance = 60,
		EmitterSize = 3
	}
	self.RollOffMode = v8.RollOffMode
	self.RollOffMinDistance = v8.RollOffMinDistance
	self.RollOffMaxDistance = v8.RollOffMaxDistance
	pcall(function()
		self.EmitterSize = v8.EmitterSize
	end)
	return true
end

function SoundGroupManager:ConfigureStereo()
	if not (self and self:IsA("Sound")) then
		return false
	end

	self.RollOffMode = Enum.RollOffMode.Linear
	self.RollOffMinDistance = 0
	self.RollOffMaxDistance = 10000
	return true
end

function SoundGroupManager.AutoAssignSound(sound)
	if not (sound and sound:IsA("Sound")) then
		return nil
	end

	local name = sound.Name

	for _, v8 in ipairs({
		"UI",
		"ItemUsage",
		"Elevator",
		"Machines",
		"LevelEvents",
		"Environmental",
		"Music",
		"SFX"
	}) do
		local v9 = v3[v8]

		if not v9 then
			continue
		end

		for _, v10 in ipairs(v9) do
			if not name:match(v10) then
				continue
			end

			SoundGroupManager.AssignSound(sound, v8)

			if v8 == "UI" or v8 == "Music" then
				SoundGroupManager.ConfigureStereo(sound)
				return v8
			end

			SoundGroupManager.ConfigureVolumetric(sound, v8)
			return v8
		end
	end

	SoundGroupManager.AssignSound(sound, "SFX")
	return "SFX"
end

function SoundGroupManager.CheckObstruction(p)
	if not v5.enabled then
		return false
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return false
	end

	local character = localPlayer.Character

	if not character then
		return false
	end

	local head = character:FindFirstChild("Head")

	if not head then
		return false
	end

	local position = head.Position
	local v8 = p - position
	v5.raycastParams.FilterDescendantsInstances = { character }
	local raycastResult = workspace:Raycast(position, v8, v5.raycastParams)

	if raycastResult then
		return (raycastResult.Position - position).Magnitude < v8.Magnitude - 1
	end

	return false
end

function SoundGroupManager:ApplyObstructionEffect(p)
	if not (self and self:IsA("Sound") and v5.enabled) then
		return
	end

	if SoundGroupManager.CheckObstruction(p) then
		local originalVolume = self:GetAttribute("OriginalVolume") or self.Volume
		self:SetAttribute("OriginalVolume", originalVolume)
		self.Volume = originalVolume * v5.dampingFactor
		pcall(function()
			if not self:FindFirstChild("ObstructionEQ") then
				local equalizerSoundEffect = Instance.new("EqualizerSoundEffect")
				equalizerSoundEffect.Name = "ObstructionEQ"
				equalizerSoundEffect.HighGain = -12
				equalizerSoundEffect.MidGain = -3
				equalizerSoundEffect.LowGain = 0
				equalizerSoundEffect.Parent = self
			end
		end)
	else
		local originalVolume = self:GetAttribute("OriginalVolume")

		if originalVolume then
			self.Volume = originalVolume
		end

		local obstructionEQ = self:FindFirstChild("ObstructionEQ")

		if obstructionEQ then
			obstructionEQ:Destroy()
		end
	end
end

function SoundGroupManager.StartObstructionTracking(sound, callback)
	if not (sound and sound:IsA("Sound") and v5.enabled) then
		return nil
	end

	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if sound and sound.Parent and sound.IsPlaying then
			local v8 = callback()

			if v8 then
				SoundGroupManager.ApplyObstructionEffect(sound, v8)
			end
		elseif heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
	end)
	return heartbeatConnection
end

function SoundGroupManager.ApplyReverbEffect(sound, p)
	if not (sound and sound:IsA("Sound")) then
		return false
	end

	local v8 = ({
		Small = {
			DecayTime = 0.8,
			Density = 0.6,
			Diffusion = 0.7,
			DryLevel = 0,
			WetLevel = -8
		},
		Medium = {
			DecayTime = 1.5,
			Density = 0.7,
			Diffusion = 0.8,
			DryLevel = 0,
			WetLevel = -6
		},
		Large = {
			DecayTime = 2.5,
			Density = 0.8,
			Diffusion = 0.9,
			DryLevel = 0,
			WetLevel = -4
		},
		Hallway = {
			DecayTime = 3,
			Density = 0.5,
			Diffusion = 0.6,
			DryLevel = 0,
			WetLevel = -3
		},
		Cave = {
			DecayTime = 4,
			Density = 0.9,
			Diffusion = 0.95,
			DryLevel = 0,
			WetLevel = -2
		}
	})[p]

	if v8 then
		return (pcall(function()
			local roomReverb = sound:FindFirstChild("RoomReverb")

			if roomReverb then
				roomReverb:Destroy()
			end

			local reverbSoundEffect = Instance.new("ReverbSoundEffect")
			reverbSoundEffect.Name = "RoomReverb"
			reverbSoundEffect.DecayTime = v8.DecayTime
			reverbSoundEffect.Density = v8.Density
			reverbSoundEffect.Diffusion = v8.Diffusion
			reverbSoundEffect.DryLevel = v8.DryLevel
			reverbSoundEffect.WetLevel = v8.WetLevel
			reverbSoundEffect.Parent = sound
		end))
	end

	return false
end

function SoundGroupManager.ConfigureHorrorSound(sound, options)
	if not (sound and sound:IsA("Sound")) then
		return false
	end

	local v8 = options or {}
	local group = v8.group or "SFX"
	SoundGroupManager.AssignSound(sound, group)

	if v8.stereo then
		SoundGroupManager.ConfigureStereo(sound)
	else
		local volumetricType = v8.volumetricType or group
		SoundGroupManager.ConfigureVolumetric(sound, volumetricType)
	end

	if v8.roomType then
		SoundGroupManager.ApplyReverbEffect(sound, v8.roomType)
	end

	if v8.trackObstruction and v8.getPosition then
		SoundGroupManager.StartObstructionTracking(sound, v8.getPosition)
	end

	return true
end

function SoundGroupManager.GetVolumetricConfig(p)
	return v4[p]
end

function SoundGroupManager.GetObstructionConfig()
	return v5
end

function SoundGroupManager.SetObstructionEnabled(enabled)
	v5.enabled = enabled
end

function SoundGroupManager.ConfigureSoundService(value)
	local reverbPreset = v6.ReverbPresets[value or "Medium"]

	if reverbPreset then
		SoundService.AmbientReverb = reverbPreset
	end

	SoundService.DistanceFactor = v6.DistanceFactor
	SoundService.DopplerScale = v6.DopplerScale
	SoundService.RolloffScale = v6.RolloffScale
	return true
end

function SoundGroupManager.SetAmbientReverb(p)
	local reverbPreset = v6.ReverbPresets[p]

	if not reverbPreset then
		return false
	end

	SoundService.AmbientReverb = reverbPreset
	return true
end

function SoundGroupManager.GetRobloxAudioConfig()
	return v6
end

local v8 = {}

function SoundGroupManager.CreateVolumetricEmitter(data)
	if not data then
		return nil, nil
	end

	local part = Instance.new("Part")
	part.Name = "VolumetricEmitter"
	part.Size = data.size or createVector(20, 10, 20)
	part.Position = data.position or createVector(0, 5, 0)
	part.Anchored = true
	part.Transparency = 1
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	local sound

	if data.sound then
		sound = data.sound
	else
		if not data.soundId then
			part:Destroy()
			return nil, nil
		end

		sound = Instance.new("Sound")
		sound.SoundId = data.soundId
	end

	sound.Parent = part
	sound.Volume = data.volume or 0.5
	sound.Looped = data.looped ~= false
	sound.RollOffMode = Enum.RollOffMode.Linear
	sound.RollOffMinDistance = data.rollOffMin or 5
	sound.RollOffMaxDistance = data.rollOffMax or 50
	local group = data.group or "Ambience"
	SoundGroupManager.AssignSound(sound, group)

	if data.roomType then
		SoundGroupManager.ApplyReverbEffect(sound, data.roomType)
	end

	part.Parent = data.parent or workspace
	table.insert(v8, {
		emitter = part,
		sound = sound
	})
	return part, sound
end

function SoundGroupManager.ConvertToVolumetric(sound, position, size, options)
	if not (sound and sound:IsA("Sound")) then
		return nil
	end

	local v9 = options or {}
	v9.sound = sound
	v9.position = position
	v9.size = size
	v9.parent = sound.Parent
	return (SoundGroupManager.CreateVolumetricEmitter(v9))
end

function SoundGroupManager.CreateRoomAmbient(p, position, soundId, parent)
	local v9 = {
		Generator = {
			size = createVector(15, 8, 15),
			rollOffMin = 8,
			rollOffMax = 40,
			volume = 0.4,
			group = "Machines",
			reverb = "Small"
		},
		Hallway = {
			size = createVector(8, 10, 40),
			rollOffMin = 5,
			rollOffMax = 60,
			volume = 0.3,
			group = "Ambience",
			reverb = "Hallway"
		},
		Cave = {
			size = createVector(30, 15, 30),
			rollOffMin = 10,
			rollOffMax = 80,
			volume = 0.35,
			group = "Ambience",
			reverb = "Cave"
		},
		Vent = {
			size = createVector(4, 4, 20),
			rollOffMin = 3,
			rollOffMax = 25,
			volume = 0.25,
			group = "Environmental",
			reverb = "Small"
		},
		Outside = {
			size = createVector(100, 30, 100),
			rollOffMin = 20,
			rollOffMax = 150,
			volume = 0.3,
			group = "Ambience",
			reverb = nil
		},
		SmallRoom = {
			size = createVector(12, 8, 12),
			rollOffMin = 4,
			rollOffMax = 30,
			volume = 0.35,
			group = "Ambience",
			reverb = "Small"
		},
		LargeRoom = {
			size = createVector(40, 15, 40),
			rollOffMin = 15,
			rollOffMax = 100,
			volume = 0.4,
			group = "Ambience",
			reverb = "Large"
		}
	}
	local v10 = v9[p] or v9.SmallRoom
	return SoundGroupManager.CreateVolumetricEmitter({
		position = position,
		size = v10.size,
		soundId = soundId,
		volume = v10.volume,
		rollOffMin = v10.rollOffMin,
		rollOffMax = v10.rollOffMax,
		group = v10.group,
		roomType = v10.reverb,
		parent = parent
	})
end

function SoundGroupManager.CleanupVolumetricEmitters()
	for _, v9 in ipairs(v8) do
		if v9.sound then
			v9.sound:Stop()
		end

		if v9.emitter then
			v9.emitter:Destroy()
		end
	end

	v8 = {}
end

function SoundGroupManager.RemoveVolumetricEmitter(instance)
	if not instance then
		return
	end

	for i, v9 in ipairs(v8) do
		if v9.emitter ~= instance then
			continue
		end

		if v9.sound then
			v9.sound:Stop()
		end

		v9.emitter:Destroy()
		table.remove(v8, i)
		return true
	end

	local sound = instance:FindFirstChildOfClass("Sound")

	if sound then
		sound:Stop()
	end

	instance:Destroy()
	return true
end

function SoundGroupManager.GetActiveEmitters()
	return v8
end

return SoundGroupManager