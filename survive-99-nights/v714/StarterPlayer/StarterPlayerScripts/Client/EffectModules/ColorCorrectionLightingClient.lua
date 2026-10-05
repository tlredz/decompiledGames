local ColorCorrectionLightingClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
local v = {
	timeOfDay = "Day",
	biome = nil,
	weather = nil,
	flashlight = false,
	nearFire = false,
	isAlien = false,
	isMeteors = false,
	isRiftSpawning = false,
	hasCamperVision = false,
	hasElementalVision = false,
	hasCarrotCake = false,
	isNecromancer = false,
	isVampire = false,
	isNightcrawler = false,
	isBunny = false,
	nearCrystal = false,
	isPollinating = false
}
local v2 = nil
local clones = {}
local v3 = false
local v4 = {
	Day = {
		TintColor = Color3.fromRGB(255, 255, 255),
		Saturation = -0.05,
		Brightness = 0,
		Density = 0.316,
		FogStart = 50,
		FogEnd = 450
	},
	Night = {
		TintColor = Color3.fromRGB(187, 142, 255),
		Saturation = -0.3,
		Brightness = -0.05,
		Density = 0.64,
		FogStart = 30,
		FogEnd = 90
	},
	RiftSpawning = {
		TintColor = Color3.fromRGB(113, 12, 255)
	},
	Flashlight = {
		TintColor = Color3.fromRGB(204, 181, 255),
		Saturation = -0.2,
		Brightness = 0,
		Density = 0.55,
		FogStart = 40,
		FogEnd = 170
	},
	Fire = {
		TintColor = Color3.fromRGB(255, 255, 255),
		Saturation = -0.05,
		Brightness = 0.03,
		Density = 0.5,
		FogStart = 20,
		FogEnd = 150
	},
	DaySaturated = {
		TintColor = Color3.fromRGB(255, 255, 255),
		Saturation = -0.05,
		Brightness = 0,
		Density = 0.316,
		FogStart = 50,
		FogEnd = 450
	},
	Aliens = {
		TintColor = Color3.fromRGB(179, 228, 255),
		Saturation = 0.3,
		Brightness = 0.03,
		Density = 0.316,
		FogStart = 70,
		FogEnd = 150
	},
	Vampire = {
		TintColor = Color3.fromRGB(179, 228, 255),
		Saturation = 0.3,
		Brightness = 0.03,
		Density = 0.316,
		FogStart = 70,
		FogEnd = 150
	},
	Nightcrawler = {
		TintColor = Color3.fromRGB(161, 163, 255),
		Saturation = 0.3,
		Brightness = 0,
		FogColor = Color3.fromRGB(41, 54, 88),
		FogStart = 70,
		FogEnd = 250
	},
	Bunny = {
		TintColor = Color3.fromRGB(161, 163, 255),
		Saturation = 0.3,
		Brightness = 0,
		FogColor = Color3.fromRGB(41, 54, 88),
		FogStart = 70,
		FogEnd = 250
	},
	Necromancer = {
		TintColor = Color3.fromRGB(179, 228, 255),
		Saturation = 0.3,
		Brightness = 0.03,
		Density = 0.316,
		FogStart = 70,
		FogEnd = 150
	},
	SnowBiome = {
		TintColor = Color3.fromRGB(208, 246, 255),
		Saturation = -0.05,
		Brightness = 0.06,
		Density = 0.356,
		FogStart = 50,
		FogEnd = 430
	},
	VolcanicBiome = {
		TintColor = Color3.fromRGB(255, 248, 235),
		Saturation = 0,
		Brightness = -0.05,
		Density = 0.316,
		FogStart = 50,
		FogEnd = 450
	},
	VolcanoBiome = {
		TintColor = Color3.fromRGB(255, 196, 168),
		Saturation = 0.3,
		Brightness = 0.05,
		FogStart = 50,
		FogEnd = 250,
		FogColor = Color3.fromRGB(140, 84, 0)
	},
	PollinatingDay = {
		TintColor = Color3.fromRGB(255, 255, 255),
		Saturation = -0.05,
		Brightness = 0,
		FogStart = 20,
		FogEnd = 150,
		FogColor = Color3.fromRGB(255, 208, 89),
		LightingBrightness = 1,
		Ambient = Color3.fromRGB(255, 238, 0),
		ColorShift_Top = Color3.fromRGB(255, 191, 0),
		OutdoorAmbient = Color3.fromRGB(255, 238, 0),
		TimeOfDay = 14.5
	},
	PollinatingNight = {
		TintColor = Color3.fromRGB(255, 255, 255),
		Saturation = -0.05,
		Brightness = 0,
		FogStart = 20,
		FogEnd = 150,
		FogColor = Color3.fromRGB(255, 208, 89),
		LightingBrightness = 1,
		Ambient = Color3.fromRGB(255, 238, 0),
		ColorShift_Top = Color3.fromRGB(255, 191, 0),
		OutdoorAmbient = Color3.fromRGB(255, 238, 0),
		TimeOfDay = 0
	},
	Blizzard = {
		TintColor = Color3.fromRGB(208, 246, 255),
		Saturation = -0.05,
		Brightness = 0.06,
		Density = 0.356,
		FogStart = 40,
		FogEnd = 200
	},
	SnowBiomeBlizzard = {
		TintColor = Color3.fromRGB(208, 246, 255),
		Saturation = -0.05,
		Brightness = 0.06,
		Density = 0.356,
		FogStart = 40,
		FogEnd = 200
	},
	MeteorShower = {
		TintColor = Color3.fromRGB(208, 246, 255),
		Saturation = -0.05,
		Brightness = 0.06,
		Density = 0.356,
		FogStart = 50,
		FogEnd = 900,
		FogColor = Color3.fromRGB(235, 46, 0)
	},
	HedgeMaze = {
		TintColor = Color3.fromRGB(255, 255, 255),
		Saturation = 0.3,
		Brightness = 0,
		FogStart = 30,
		FogEnd = 96,
		FogColor = Color3.fromRGB(34, 33, 66),
		LightingBrightness = 3,
		Ambient = Color3.fromRGB(156, 156, 191),
		ColorShift_Top = Color3.fromRGB(128, 200, 255),
		OutdoorAmbient = Color3.fromRGB(70, 70, 70),
		TimeOfDay = 1,
		NoOverride = true
	},
	ChristmasSafezone = {
		ExposureCompensation = 0.35,
		TintColor = Color3.fromRGB(255, 255, 255),
		Saturation = 0,
		Brightness = 0.01,
		Contrast = 0.03,
		FogStart = 150,
		FogEnd = 400,
		FogColor = Color3.fromRGB(40, 30, 97),
		LightingBrightness = 0,
		Ambient = Color3.fromRGB(145, 143, 208),
		ColorShift_Top = Color3.fromRGB(0, 0, 0),
		OutdoorAmbient = Color3.fromRGB(52, 40, 67),
		TimeOfDay = 1
	},
	BeesBiome = {
		TintColor = Color3.fromRGB(255, 255, 255),
		Saturation = -0.05,
		Brightness = 0.02,
		Density = 0.316,
		FogStart = 50,
		FogEnd = 450,
		Ambient = Color3.fromRGB(200, 200, 200),
		FogColor = Color3.fromRGB(139, 139, 139)
	},
	FairyBiome = {
		TintColor = Color3.fromRGB(255, 255, 255),
		Saturation = -0.05,
		Brightness = 0,
		Density = 0.316,
		FogStart = 50,
		FogEnd = 450,
		Ambient = Color3.fromRGB(200, 203, 223)
	}
}
local v5 = {
	HEDGEMAZE = 111,
	RIFT_SPAWNING = 110,
	VOLCANO_BIOME = 110,
	POLLINATING = 109,
	CHRISTMAS_SAFEZONE = 105,
	NIGHTCRAWLER_MODE = 100,
	ALIEN_MODE = 100,
	METEOR_SHOWER = 100,
	NECROMANCER_MODE = 95,
	FIRE = 80,
	VAMPIRE_MODE = 75,
	CAVE_CRYSTAL = 73,
	CAVE_FLASHLIGHT = 72,
	CAVE_BIOME = 71,
	FLASHLIGHT = 70,
	NIGHT = 60,
	WEATHER = 40,
	BIOME = 30,
	DAY = 5
}
local v6 = "Day"

local function calculateLightingState()
	if v.biome == "HedgeMaze" then
		Client.Events.ChangeDayOrNight:Fire("Night")
		return "HedgeMaze", 111
	end

	if v6 and v6 == "HedgeMaze" and v.timeOfDay == "Day" then
		Client.Events.ChangeDayOrNight:Fire("Day")
	end

	if v.isRiftSpawning then
		return "RiftSpawning", 110
	end

	if v.biome == "Volcano" then
		return "VolcanoBiome", 110
	end

	if v.isPollinating and v.biome == "Bees" then
		if v.timeOfDay == "Night" then
			return "PollinatingNight", 109
		end

		return "PollinatingDay", 109
	else
		if v.isMeteors then
			return "MeteorShower", 100
		end

		if v.biome == "ChristmasSafezone" and v.timeOfDay == "Night" then
			return "ChristmasSafezone", 105
		end

		if v.nearFire and v.biome ~= "Cave" then
			if v.timeOfDay == "Night" then
				return "Fire", 80
			end

			if Client.CampfireEffectModule.FireEffectEnabled or v.biome == "Snow" then
				return "DaySaturated", 80
			end
		end

		if v.nearCrystal and v.biome == "Cave" then
			if Client.CaveLightingClient.NearGreen then
				return "CaveCrystalGreen", 73
			end

			return "CaveCrystal", 73
		else
			if v.isNightcrawler and (v.timeOfDay == "Night" or v.biome == "Cave") then
				return "Nightcrawler", 100
			end

			if v.isNecromancer and v.timeOfDay == "Night" then
				return "Necromancer", 95
			end

			if v.isVampire and v.timeOfDay == "Night" then
				return "Vampire", 75
			end

			if v.flashlight and v.biome == "Cave" then
				return "CaveFlashlight", 72
			end

			if v.biome == "Cave" then
				return v.biome .. "Biome", 71
			end

			if v.flashlight and v.timeOfDay == "Night" then
				return "Flashlight", 70
			end

			if v.isBunny and (v.timeOfDay == "Night" or v.biome == "Cave") then
				return "Bunny", v5.BUNNY_MODE
			end

			if v.isAlien and v.timeOfDay == "Night" then
				return "Aliens", 100
			end

			if v.timeOfDay == "Night" then
				return "Night", 60
			end

			if v.weather == "Blizzard" and v.biome == "Snow" then
				return "SnowBiomeBlizzard", 40
			end

			if v.weather == "Blizzard" then
				return "Blizzard", 40
			end

			if v.weather then
				return v.weather .. "Biome", 40
			end

			if v.biome then
				return v.biome .. "Biome", 30
			end

			return "Day", 5
		end
	end
end

local function applyClassModifications(day, p)
	local copy = UtilityAlec.deepCopy(day)

	if v.hasCamperVision and (p == "Night" or p == "Flashlight") then
		if p == "Night" then
			copy.FogStart = 40
			copy.FogEnd = 140
			copy.Brightness = -0.02
		elseif p == "Flashlight" then
			copy.FogStart = 45
			copy.FogEnd = 190
		end
	end

	if v.hasElementalVision and (p == "Night" or p == "Flashlight") then
		if p == "Night" then
			copy.FogStart = 52
			copy.FogEnd = 182
		elseif p == "Flashlight" then
			copy.FogStart = 58.5
			copy.FogEnd = 247
		end
	end

	if (localPlayer:GetAttribute("Class") == "Alien" or localPlayer:GetAttribute("Class") == "Cyborg") and (p == "Night" or p == "Flashlight") then
		if p == "Night" then
			copy.FogStart = 70
			copy.FogEnd = 170
			copy.Brightness = 0
		elseif p == "Flashlight" then
			copy.FogStart = 75
			copy.FogEnd = 190
		end
	end

	if not v.hasCarrotCake or p ~= "Night" and p ~= "Flashlight" then
		return copy
	end

	if p == "Night" then
		copy.FogStart = 120
		copy.FogEnd = 250
		copy.Brightness = 0
		return copy
	elseif p == "Flashlight" then
		copy.FogStart = 150
		copy.FogEnd = 300
	end

	return copy
end

local flag = false
v4.CaveBiome = {
	TintColor = Color3.fromRGB(203, 201, 255),
	Saturation = -0.25,
	Brightness = 0,
	FogStart = 30,
	FogEnd = 100,
	FogColor = Color3.fromRGB(0, 0, 0),
	LightingBrightness = 0,
	Ambient = Color3.fromRGB(33, 0, 163),
	ColorShift_Top = Color3.fromRGB(159, 42, 255),
	OutdoorAmbient = Color3.fromRGB(0, 0, 0),
	TimeOfDay = 0
}

if game.ReplicatedStorage:GetAttribute("TestingMode") then
	v4.CaveBiome = {
		TintColor = Color3.fromRGB(255, 255, 255),
		Saturation = -0.25,
		Brightness = 0,
		FogStart = 300,
		FogEnd = 1000,
		FogColor = Color3.fromRGB(0, 0, 0),
		LightingBrightness = 0,
		Ambient = Color3.fromRGB(255, 255, 255),
		ColorShift_Top = Color3.fromRGB(159, 42, 255),
		OutdoorAmbient = Color3.fromRGB(0, 0, 0),
		TimeOfDay = 0
	}
end

v4.CaveFlashlight = {
	TintColor = Color3.fromRGB(203, 201, 255),
	Saturation = -0.15,
	Brightness = 0,
	FogStart = 40,
	FogEnd = 170,
	FogColor = Color3.fromRGB(0, 0, 0),
	LightingBrightness = 0,
	Ambient = Color3.fromRGB(48, 88, 199),
	TimeOfDay = 0
}
v4.CaveCrystal = {
	TintColor = Color3.fromRGB(197, 179, 255),
	Saturation = 0.3,
	Brightness = 0,
	FogColor = Color3.fromRGB(0, 6, 48),
	FogStart = 50,
	FogEnd = 180,
	Ambient = Color3.fromRGB(179, 228, 255),
	TimeOfDay = 0,
	LightingBrightness = 0
}
v4.CaveCrystalBright = {
	TintColor = Color3.fromRGB(197, 179, 255),
	Saturation = 0.3,
	Brightness = 0,
	FogColor = Color3.fromRGB(0, 6, 48),
	FogStart = 50,
	FogEnd = 180,
	Ambient = Color3.fromRGB(179, 228, 255),
	TimeOfDay = 0,
	LightingBrightness = 0
}
v4.CaveCrystalDim = {
	TintColor = Color3.fromRGB(203, 201, 255),
	Saturation = -0.25,
	Brightness = 0,
	FogStart = 30,
	FogEnd = 100,
	FogColor = Color3.fromRGB(0, 0, 0),
	LightingBrightness = 0,
	Ambient = Color3.fromRGB(33, 0, 163),
	ColorShift_Top = Color3.fromRGB(159, 42, 255),
	OutdoorAmbient = Color3.fromRGB(0, 0, 0),
	TimeOfDay = 0
}
v4.CaveCrystalGreen = {
	TintColor = Color3.fromRGB(225, 255, 231),
	Saturation = 0.3,
	Brightness = 0.01,
	FogColor = Color3.fromRGB(24, 48, 26),
	FogStart = 50,
	FogEnd = 180,
	Ambient = Color3.fromRGB(202, 239, 255),
	TimeOfDay = 0,
	LightingBrightness = 0
}

function SetCaveCrystalLighting(value)
	local v7 = math.clamp(value, 0, 1)
	local caveCrystalBright = v4.CaveCrystalBright
	local caveCrystalDim = v4.CaveCrystalDim
	v4.CaveCrystal = {
		TintColor = caveCrystalBright.TintColor:Lerp(caveCrystalDim.TintColor, v7),
		Saturation = caveCrystalBright.Saturation + (caveCrystalDim.Saturation - caveCrystalBright.Saturation) * v7,
		Brightness = caveCrystalBright.Brightness + (caveCrystalDim.Brightness - caveCrystalBright.Brightness) * v7,
		FogColor = caveCrystalBright.FogColor:Lerp(caveCrystalDim.FogColor, v7),
		FogStart = caveCrystalBright.FogStart + (caveCrystalDim.FogStart - caveCrystalBright.FogStart) * v7,
		FogEnd = caveCrystalBright.FogEnd + (caveCrystalDim.FogEnd - caveCrystalBright.FogEnd) * v7,
		Ambient = caveCrystalBright.Ambient:Lerp(caveCrystalDim.Ambient, v7),
		TimeOfDay = caveCrystalBright.TimeOfDay + (caveCrystalDim.TimeOfDay - caveCrystalBright.TimeOfDay) * v7,
		LightingBrightness = caveCrystalBright.LightingBrightness + (caveCrystalDim.LightingBrightness - caveCrystalBright.LightingBrightness) * v7
	}
end

function AdjustCaveLight()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		while Client.CaveLightingClient.PlayerInLight and v6 == "CaveCrystal" do
			if localPlayer.Character and localPlayer.Character.PrimaryPart and Client.CaveLightingClient.PlayerInLight.PrimaryPart and Client.CaveLightingClient.PlayerInLight:FindFirstChild("TouchZone") then
				local v7 = math.clamp(
					(Vector3.new(
						localPlayer.Character.PrimaryPart.Position.X,
						0,
						localPlayer.Character.PrimaryPart.Position.Z
					) - Vector3.new(
						Client.CaveLightingClient.PlayerInLight.PrimaryPart.Position.X,
						0,
						Client.CaveLightingClient.PlayerInLight.PrimaryPart.Position.Z
					)).Magnitude / (Client.CaveLightingClient.PlayerInLight.TouchZone.Size.Y / 2) - 0.5,
					0,
					0.5
				)
				SetCaveCrystalLighting(v7)
			end

			updateLighting()
			wait(0.5)
		end

		flag = false
	end)
end

function ColorCorrectionLightingClient.ForceUpdate()
	updateLighting()
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function isDayClock(p)
	return p > 6 and p < 20
end

function updateLighting(value, p)
	local v7, _ = calculateLightingState()
	local day = v4[v7]

	if not day then
		print("Warning: No config found for state:", v7)
		day = v4.Day
		v7 = "Day"
	end

	local v8 = v7 == "MeteorShower" and 15 or value or 0.4

	if v7 == "HedgeMaze" and v6 == "HedgeMaze" then
		v8 = 0.2

		if v.isNightcrawler then
			day.FogStart = 90
			day.FogEnd = 250
		elseif v.flashlight then
			day.FogStart = 75
			day.FogEnd = 125
		else
			day.FogStart = 30
			day.FogEnd = 96
		end
	end

	local timeOfDay = day.TimeOfDay or v.timeOfDay == "Day" and 14.5 or 0

	if isDayClock(game.Lighting.ClockTime) ~= isDayClock(timeOfDay) then
		v8 = math.max(v8, 3)
	end

	local v9 = applyClassModifications(day, v7)
	ColorCorrectionLightingClient.ChangeColorCorrection(v7, v9, p and 0 or v8)
end

function ColorCorrectionLightingClient.GetBiome()
	return v.biome
end

function ColorCorrectionLightingClient.SetTimeOfDay(timeOfDay)
	v.timeOfDay = timeOfDay
	updateLighting()
end

function ColorCorrectionLightingClient.SetBiome(biome, p)
	v.biome = biome
	updateLighting(nil, p)
end

function ColorCorrectionLightingClient.OverrideLightingConfig(p, items)
	for k, item in pairs(items) do
		v4[p][k] = item
	end

	updateLighting()
end

function ColorCorrectionLightingClient.SetWeather(weather)
	v.weather = weather
	updateLighting()
end

function ColorCorrectionLightingClient.SetFlashlightActive(p, p2)
	task.spawn(function()
		if p2 and p2 == "Admin Flashlight" then
			game.Lighting.AdminFlashlightColorCorrection.Enabled = p
		end
	end)
	v.flashlight = p
	updateLighting()
end

function ColorCorrectionLightingClient.ToggleFire(nearFire)
	v.nearFire = nearFire
	updateLighting()
end

function ColorCorrectionLightingClient.SetAlien()
	v.isAlien = true
	updateLighting()
end

function ColorCorrectionLightingClient.SetMeteors(isMeteors)
	v.isMeteors = isMeteors
	updateLighting()
end

function ColorCorrectionLightingClient.SetRiftSpawning(isRiftSpawning)
	v.isRiftSpawning = isRiftSpawning
	updateLighting()
end

function ColorCorrectionLightingClient.ClearAlien()
	v.isAlien = false
	updateLighting()
end

local function updateNecromancerVision()
	local v7 = math.clamp(localPlayer:GetAttribute("NecromancerBonusVision") or 0, 0, 1)

	if v7 > 0 and localPlayer:GetAttribute("Class") == "Necromancer" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 3 then
		local v8 = {
			TintColor = Color3.fromRGB(187, 142, 255),
			Saturation = -0.3,
			Brightness = -0.05,
			FogStart = 30,
			FogEnd = 90
		}
		local v9 = {
			TintColor = Color3.fromRGB(179, 228, 255),
			Saturation = 0.3,
			Brightness = 0.03,
			FogStart = 70,
			FogEnd = 200
		}
		v.isNecromancer = true
		v4.Necromancer = {
			TintColor = v8.TintColor:Lerp(v9.TintColor, v7),
			Saturation = v8.Saturation + (v9.Saturation - v8.Saturation) * v7,
			Brightness = v8.Brightness + (v9.Brightness - v8.Brightness) * v7,
			FogStart = v8.FogStart + (v9.FogStart - v8.FogStart) * v7,
			FogEnd = v8.FogEnd + (v9.FogEnd - v8.FogEnd) * v7
		}
	else
		v.isNecromancer = false
	end

	updateLighting()
end

local function updateClassAbilities()
	local biome = workspace:GetAttribute("Biome")
	local hasElementalVision

	if localPlayer:GetAttribute("Class") == "Elemental" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 3 and biome ~= nil then
		hasElementalVision = v.biome == biome
	else
		hasElementalVision = false
	end

	v.hasCamperVision = localPlayer:GetAttribute("Class") == "Camper" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 2 or (Client.Utility.HasTalent(
		localPlayer,
		"IncreasedVisibility"
	) or hasElementalVision)
	v.hasElementalVision = hasElementalVision
	v.isVampire = localPlayer:GetAttribute("Class") == "Vampire" and localPlayer:GetAttribute("ClassLevel") >= 2
	v.isNightcrawler = localPlayer:GetAttribute("Class") == "Nightcrawler"
	v.isBunny = localPlayer:GetAttribute("Class") == "Bunny"

	if localPlayer:GetAttribute("Class") == "Bunny" then
		ChangeBunnyVision(localPlayer:GetAttribute("CarrotsEatenPct") or 0)
	end

	updateNecromancerVision()
	updateLighting()
end

function BaseLightingChanges(data, duration)
	if data.FogColor then
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			FogColor = data.FogColor
		}):Play()
	elseif v.timeOfDay == "Day" then
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			FogColor = Color3.fromRGB(139, 139, 139)
		}):Play()
	else
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			FogColor = Color3.fromRGB(44, 40, 66)
		}):Play()
	end

	if data.LightingBrightness then
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Brightness = data.LightingBrightness
		}):Play()
	elseif v.timeOfDay == "Day" then
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Brightness = 1
		}):Play()
	else
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Brightness = 2.5
		}):Play()
	end

	if data.Ambient then
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Ambient = data.Ambient
		}):Play()
	elseif v.timeOfDay == "Day" then
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Ambient = Color3.fromRGB(191, 191, 191)
		}):Play()
	else
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Ambient = Color3.fromRGB(255, 255, 255)
		}):Play()
	end

	if data.ColorShift_Top then
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ColorShift_Top = data.ColorShift_Top
		}):Play()
	else
		if v.timeOfDay == "Day" then
		end

		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ColorShift_Top = Color3.fromRGB(0, 0, 0)
		}):Play()
	end

	if data.OutdoorAmbient then
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			OutdoorAmbient = data.OutdoorAmbient
		}):Play()
	elseif v.timeOfDay == "Day" then
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			OutdoorAmbient = Color3.fromRGB(70, 70, 70)
		}):Play()
	else
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			OutdoorAmbient = Color3.fromRGB(52, 40, 67)
		}):Play()
	end

	if data.TimeOfDay then
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ClockTime = data.TimeOfDay
		}):Play()
	elseif v.timeOfDay == "Day" then
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ClockTime = 14.5
		}):Play()
	else
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ClockTime = 0
		}):Play()
	end

	if data.Contrast then
		TweenService:Create(
			game.Lighting.ColorCorrection,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				Contrast = data.Contrast
			}
		):Play()
	else
		if v.timeOfDay == "Day" then
		end

		TweenService:Create(
			game.Lighting.ColorCorrection,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				Contrast = 0
			}
		):Play()
	end

	if data.ExposureCompensation then
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ExposureCompensation = data.ExposureCompensation
		}):Play()
	else
		TweenService:Create(game.Lighting, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ExposureCompensation = 0
		}):Play()
	end
end

function ColorCorrectionLightingClient.ChangeColorCorrection(p, data, value)
	v6 = p
	local v7 = value or 0.4
	local colorCorrection = game.Lighting.ColorCorrection

	if v6 == "CaveCrystal" then
		AdjustCaveLight()
	end

	if data.TintColor then
		TweenService:Create(colorCorrection, TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			TintColor = data.TintColor
		}):Play()
	end

	if data.Brightness then
		TweenService:Create(colorCorrection, TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Brightness = data.Brightness
		}):Play()
	end

	if data.Saturation then
		TweenService:Create(colorCorrection, TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Saturation = data.Saturation
		}):Play()
	end

	if data.FogStart then
		TweenService:Create(game.Lighting, TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			FogStart = data.FogStart
		}):Play()
	end

	if data.FogEnd then
		TweenService:Create(game.Lighting, TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			FogEnd = data.FogEnd
		}):Play()
	end

	if data.Skybox then
		local clone = ReplicatedStorage.Assets.Skyboxes:FindFirstChild(data.Skybox):Clone()

		if v2 then
			v2:Destroy()
			v2 = nil
		end

		if clone then
			v2 = clone

			for _, sky in pairs(game.Lighting:GetChildren()) do
				if sky:IsA("Sky") then
					sky:Destroy()
				end
			end

			clone.Parent = game.Lighting
			table.insert(clones, clone)
		end
	elseif v2 then
		Client.Events.ResetSkybox:FireServer()
	end

	BaseLightingChanges(data, v7)
end

Client.Events.ResetSkybox:Connect(function(childName)
	if childName == "All" then
		for _, v7 in pairs(clones) do
			v7:Destroy()
		end
	else
		if v2 then
			v2:Destroy()
		end

		v2 = nil

		for _, sky in pairs(game.Lighting:GetChildren()) do
			if sky:IsA("Sky") then
				sky:Destroy()
			end
		end

		local clone = ReplicatedStorage.Assets.Skyboxes:FindFirstChild(childName):Clone()
		clone.Parent = game.Lighting
		table.insert(clones, clone)
	end
end)

function ChangeBunnyVision(p)
	local v7 = 1 - (1 - p) ^ 3
	local v8 = {
		TintColor = Color3.fromRGB(187, 142, 255),
		Saturation = -0.3,
		Brightness = -0.05,
		FogColor = Color3.fromRGB(44, 40, 66),
		FogStart = 30,
		FogEnd = 90
	}
	local v9 = {
		TintColor = Color3.fromRGB(161, 163, 255),
		Saturation = 0.3,
		Brightness = 0,
		FogColor = Color3.fromRGB(41, 54, 88),
		FogStart = 70,
		FogEnd = 250
	}
	v4.Bunny = {
		TintColor = v8.TintColor:Lerp(v9.TintColor, v7),
		Saturation = v8.Saturation + (v9.Saturation - v8.Saturation) * v7,
		Brightness = v8.Brightness + (v9.Brightness - v8.Brightness) * v7,
		FogColor = v8.FogColor:Lerp(v9.FogColor, v7),
		FogStart = v8.FogStart + (v9.FogStart - v8.FogStart) * v7,
		FogEnd = v8.FogEnd + (v9.FogEnd - v8.FogEnd) * v7
	}
	updateLighting()
end

function ColorCorrectionLightingClient.Init()
	workspace:GetAttributeChangedSignal("State"):Connect(function()
		v.timeOfDay = workspace:GetAttribute("State") or "Day"
		updateLighting()
	end)
	workspace:GetAttributeChangedSignal("Pollinating"):Connect(function()
		v.isPollinating = workspace:GetAttribute("Pollinating") == true
		updateLighting()
	end)
	workspace:GetAttributeChangedSignal("Biome"):Connect(updateClassAbilities)
	localPlayer:GetAttributeChangedSignal("Class"):Connect(updateClassAbilities)
	localPlayer:GetAttributeChangedSignal("ClassLevel"):Connect(updateClassAbilities)
	localPlayer:GetAttributeChangedSignal("CarrotCake"):Connect(function()
		v.hasCarrotCake = localPlayer:GetAttribute("CarrotCake") or false
		updateLighting(1)
	end)
	localPlayer:GetAttributeChangedSignal("NecromancerBonusVision"):Connect(updateNecromancerVision)
	localPlayer:GetAttributeChangedSignal("CaveCrystal"):Connect(function()
		if localPlayer:GetAttribute("CaveCrystal") then
			v.nearCrystal = true
		else
			v.nearCrystal = false
		end

		updateLighting()
	end)
	localPlayer:GetAttributeChangedSignal("CarrotsEatenPct"):Connect(function()
		ChangeBunnyVision(localPlayer:GetAttribute("CarrotsEatenPct"))
	end)
	Client.Events.BiomeEntered:Connect(function(p)
		ColorCorrectionLightingClient.SetBiome(p)
		updateClassAbilities()
	end)
	Client.Events.WeatherActive:Connect(function(p)
		ColorCorrectionLightingClient.SetWeather(p)
	end)
	local thread = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ccDebounce()
		if thread then
			task.cancel(thread)
		end

		thread = task.delay(6, function()
			v3 = false
		end)
	end

	Client.Events.ChangeColorCorrection:Connect(function(p, p2)
		if p == "Day" then
			if v.timeOfDay == "Night" then
				v3 = true
				ccDebounce() -- equivalent call inferred; original call site unknown
			end

			v.timeOfDay = "Day"

			if v6 ~= "HedgeMaze" then
				Client.Events.ChangeDayOrNight:Fire("Day")
			end
		elseif p == "Night" then
			if v.timeOfDay == "Day" then
				v3 = true
				ccDebounce() -- equivalent call inferred; original call site unknown
			end

			v.timeOfDay = "Night"
			Client.Events.ChangeDayOrNight:Fire("Night")
		end

		updateLighting(p2)
	end)
	v.timeOfDay = workspace:GetAttribute("State") or "Day"
	v.isPollinating = workspace:GetAttribute("Pollinating") == true
	v.hasCarrotCake = localPlayer:GetAttribute("CarrotCake") or false
	task.spawn(function()
		task.wait(1)
		updateClassAbilities()
		updateLighting()
	end)
end

ColorCorrectionLightingClient.FlashlightActive = false
local setFlashlightActive = ColorCorrectionLightingClient.SetFlashlightActive

function ColorCorrectionLightingClient.SetFlashlightActive(flashlightActive, p)
	ColorCorrectionLightingClient.FlashlightActive = flashlightActive
	setFlashlightActive(flashlightActive, p)
end

return ColorCorrectionLightingClient