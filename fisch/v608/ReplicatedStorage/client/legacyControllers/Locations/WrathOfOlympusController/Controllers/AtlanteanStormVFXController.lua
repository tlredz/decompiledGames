local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.packages.Trove)
local rain = require(ReplicatedStorage.shared.modules.rain)
local StormyLightningController = require(ReplicatedStorage.client.legacyControllers.StormyLightningController)
local v = {
	["Grand Reef"] = true,
	["Atlantean Storm"] = true
}
local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v2 = {
	{
		Clouds = {
			Density = 0.25,
			Cover = 0.4,
			Color = Color3.fromRGB(230, 230, 230)
		},
		Atmosphere = {
			Density = 0.36,
			Offset = 0.2,
			Color = Color3.fromRGB(245, 245, 250),
			Decay = Color3.fromRGB(225, 238, 252),
			Glare = 0,
			Haze = 0.1
		},
		ColorCorrection = {
			Brightness = -0.02,
			Contrast = -0.03,
			Saturation = -0.03,
			TintColor = Color3.fromRGB(252, 252, 255)
		}
	},
	{
		Clouds = {
			Density = 0.4,
			Cover = 0.6,
			Color = Color3.fromRGB(210, 210, 215)
		},
		Atmosphere = {
			Density = 0.4,
			Offset = 0.17,
			Color = Color3.fromRGB(230, 230, 238),
			Decay = Color3.fromRGB(215, 228, 248),
			Glare = 0,
			Haze = 0.25
		},
		ColorCorrection = {
			Brightness = -0.04,
			Contrast = -0.06,
			Saturation = -0.06,
			TintColor = Color3.fromRGB(245, 245, 252)
		},
		Rain = true,
		RainIntensity = 0.25,
		RainVolume = 0.12
	},
	{
		Clouds = {
			Density = 0.55,
			Cover = 0.75,
			Color = Color3.fromRGB(185, 185, 190)
		},
		Atmosphere = {
			Density = 0.44,
			Offset = 0.13,
			Color = Color3.fromRGB(215, 215, 225),
			Decay = Color3.fromRGB(200, 218, 240),
			Glare = 0,
			Haze = 0.45
		},
		ColorCorrection = {
			Brightness = -0.07,
			Contrast = -0.09,
			Saturation = -0.09,
			TintColor = Color3.fromRGB(238, 238, 248)
		},
		Rain = true,
		RainIntensity = 0.55,
		RainVolume = 0.3
	},
	{
		Clouds = {
			Density = 0.7,
			Cover = 0.88,
			Color = Color3.fromRGB(150, 150, 155)
		},
		Atmosphere = {
			Density = 0.48,
			Offset = 0.09,
			Color = Color3.fromRGB(190, 190, 205),
			Decay = Color3.fromRGB(170, 180, 200),
			Glare = 0,
			Haze = 0.65
		},
		ColorCorrection = {
			Brightness = -0.09,
			Contrast = -0.12,
			Saturation = -0.12,
			TintColor = Color3.fromRGB(228, 228, 242)
		},
		Rain = true,
		RainIntensity = 0.85,
		RainVolume = 0.5
	},
	{
		Clouds = {
			Density = 0.8,
			Cover = 0.95,
			Color = Color3.fromRGB(130, 130, 135)
		},
		Atmosphere = {
			Density = 0.52,
			Offset = 0.06,
			Color = Color3.fromRGB(175, 175, 190),
			Decay = Color3.fromRGB(155, 165, 185),
			Glare = 0,
			Haze = 0.9
		},
		ColorCorrection = {
			Brightness = -0.12,
			Contrast = -0.16,
			Saturation = -0.16,
			TintColor = Color3.fromRGB(218, 218, 238)
		},
		Rain = true,
		RainIntensity = 1,
		RainVolume = 0.6,
		Lightning = true,
		LightningInterval = { 3, 7 }
	},
	{
		Clouds = {
			Density = 0.88,
			Cover = 1,
			Color = Color3.fromRGB(100, 100, 110)
		},
		Atmosphere = {
			Density = 0.58,
			Offset = 0.03,
			Color = Color3.fromRGB(150, 150, 170),
			Decay = Color3.fromRGB(130, 140, 165),
			Glare = 0.1,
			Haze = 1.2
		},
		ColorCorrection = {
			Brightness = -0.15,
			Contrast = -0.2,
			Saturation = -0.2,
			TintColor = Color3.fromRGB(200, 200, 225)
		},
		Rain = true,
		RainIntensity = 1,
		RainVolume = 0.75,
		Lightning = true,
		LightningInterval = { 1.5, 4 }
	},
	{
		Clouds = {
			Density = 0.95,
			Cover = 1,
			Color = Color3.fromRGB(75, 75, 85)
		},
		Atmosphere = {
			Density = 0.65,
			Offset = 0,
			Color = Color3.fromRGB(130, 130, 150),
			Decay = Color3.fromRGB(110, 115, 140),
			Glare = 0.2,
			Haze = 1.6
		},
		ColorCorrection = {
			Brightness = -0.18,
			Contrast = -0.25,
			Saturation = -0.25,
			TintColor = Color3.fromRGB(185, 185, 215)
		},
		Rain = true,
		RainIntensity = 1,
		RainVolume = 0.9,
		Lightning = true,
		LightningInterval = { 0.8, 2.5 }
	}
}
local localPlayer = Players.LocalPlayer
local clientWeather = ReplicatedStorage:WaitForChild("world"):WaitForChild("clientWeather")
local flag = false
local v3 = nil
local v4 = {}
local v5 = {}
local volume = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentDay()
	return ReplicatedStorage:GetAttribute("WrathWeekDay") or 0
end

local function getStageForDay(p: number)
	for i = p, 1, -1 do
		if v2[i] then
			return v2[i]
		end
	end

	return nil
end

local function takeSnapshot()
	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
	local cc = Lighting:FindFirstChild("cc")
	local weather = SoundService:FindFirstChild("weather")

	if clouds then
		v4 = {
			Density = clouds.Density,
			Cover = clouds.Cover,
			Color = clouds.Color
		}
	end

	if cc then
		v5 = {
			Brightness = cc.Brightness,
			Contrast = cc.Contrast,
			Saturation = cc.Saturation,
			TintColor = cc.TintColor
		}
	end

	if weather then
		volume = weather.Volume
	end
end

local function applyStage(data)
	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
	local cc = Lighting:FindFirstChild("cc")
	local weather = SoundService:FindFirstChild("weather")

	if data.Clouds and clouds then
		TweenService:Create(clouds, tweenInfo, data.Clouds):Play()
	end

	if data.ColorCorrection and cc then
		TweenService:Create(cc, tweenInfo, data.ColorCorrection):Play()
	end

	if data.Rain then
		rain:SetCollisionMode(rain.CollisionMode.Blacklist, workspace.zones.player:GetChildren())
		rain:SetIntensityRatio(data.RainIntensity or 1, tweenInfo)
		rain:Enable()

		if weather and data.RainVolume then
			TweenService:Create(weather, tweenInfo, {
				Volume = data.RainVolume
			}):Play()
		end
	end
end

local function restoreToCurrentWeather()
	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
	local cc = Lighting:FindFirstChild("cc")
	local weather = SoundService:FindFirstChild("weather")

	if clouds and next(v4) then
		TweenService:Create(clouds, tweenInfo2, v4):Play()
	end

	if cc and next(v5) then
		TweenService:Create(cc, tweenInfo2, v5):Play()
	end

	if weather then
		TweenService:Create(weather, tweenInfo2, {
			Volume = volume
		}):Play()
	end

	rain:SetIntensityRatio(1, tweenInfo2)
	rain:Disable()
	local value = clientWeather.Value
	clientWeather.Value = ""
	task.defer(function()
		clientWeather.Value = value
	end)
end

local function getStrikeTarget()
	local character = localPlayer.Character

	if not character then
		return nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local v6 = math.random() * 3.141592653589793 * 2
	local v7 = 30 + math.random() * 120
	local vector2 = Vector3.new(
		humanoidRootPart.Position.X + math.cos(v6) * v7,
		humanoidRootPart.Position.Y + 100,
		humanoidRootPart.Position.Z + math.sin(v6) * v7
	)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }
	local raycastResult = workspace:Raycast(vector2, createVector(0, -120, 0), raycastParams)

	if raycastResult then
		return raycastResult.Position
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startLightningLoop(maid, lightningInterval)
	local v6 = lightningInterval[1]
	local v7 = lightningInterval[2]
	maid:Add(task.spawn(function()
		while true do
			task.wait(v6 + math.random() * (v7 - v6))
			local strikeTarget = getStrikeTarget()

			if strikeTarget then
				task.spawn(StormyLightningController.Strike, StormyLightningController, strikeTarget, {
					SkipStrikingLock = true,
					NoPostFire = true
				})
			end
		end
	end), task.cancel)
end

local function enterZone()
	if flag then
		return
	end

	flag = true
	takeSnapshot()

	if v3 then
		v3:Destroy()
	end

	v3 = Trove.new()
	local flag2 = true
	local v6

	for i = getCurrentDay(), 1, -1 do
		if not v2[i] then
			continue
		end

		v6 = v2[i]
		flag2 = false
		break
	end

	if flag2 then
		v6 = nil
	end

	if not v6 then
		return
	end

	applyStage(v6)

	if v6.Lightning and v6.LightningInterval then
		startLightningLoop(v3, v6.LightningInterval) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function exitZone()
	if not flag then
		return
	end

	flag = false

	if v3 then
		v3:Destroy()
		v3 = nil
	end

	restoreToCurrentWeather()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getZoneName(value)
	if not value then
		return nil
	end

	local zonename = value:FindFirstChild("zonename")

	if zonename and zonename:IsA("ValueBase") then
		return zonename.Value
	end

	return value.Name
end

local function onZoneChanged(instance)
	local zone = instance:FindFirstChild("zone")

	if not zone then
		return
	end

	local zoneName = getZoneName(zone.Value) -- equivalent call inferred; original call site unknown

	if zoneName and v[zoneName] then
		enterZone()
		return
	end

	exitZone() -- equivalent call inferred; original call site unknown
end

return {
	Start = function(_)
		local function setupCharacter(instance)
			local zone = instance:WaitForChild("zone")

			if not zone then
				return
			end

			zone.Changed:Connect(function()
				local zone2 = instance:FindFirstChild("zone")

				if not zone2 then
					return
				end

				local zoneName = getZoneName(zone2.Value) -- equivalent call inferred; original call site unknown

				if zoneName and v[zoneName] then
					enterZone()
					return
				end

				exitZone() -- equivalent call inferred; original call site unknown
			end)
			task.defer(onZoneChanged, instance)
		end

		if localPlayer.Character then
			task.spawn(setupCharacter, localPlayer.Character)
		end

		localPlayer.CharacterAdded:Connect(function(character)
			exitZone() -- equivalent call inferred; original call site unknown
			task.spawn(setupCharacter, character)
		end)
		ReplicatedStorage:GetAttributeChangedSignal("WrathWeekDay"):Connect(function()
			if flag then
				exitZone() -- equivalent call inferred; original call site unknown
				task.wait(0.5)
				enterZone()
			end
		end)
	end
}