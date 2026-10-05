local createVector = vector.create
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local Holiday = require(ReplicatedStorage.Modules.Holiday)
local Parametric = require(ReplicatedStorage.Modules.Parametric)
local cframe = CFrame.new(0, 100, 0)
local atmosphere = Lighting:WaitForChild("Atmosphere")
local tweenInfo = TweenInfo.new(0)
local tweenInfo2 = TweenInfo.new(10)
local tweenInfo3 = TweenInfo.new(0.2)
local sky = Lighting:FindFirstChildOfClass("Sky")
local sky2 = script:FindFirstChildOfClass("Sky")
local clouds = Instance.new("Clouds")
clouds.Name = "Clouds"
clouds.Parent = workspace.Terrain
clouds.Density = 1
local v = {
	[Lighting:WaitForChild("ColorCorrection")] = {
		TintColor = Color3.fromRGB(255, 255, 255),
		Brightness = 0,
		Contrast = 0,
		Saturation = 1
	},
	[Lighting:WaitForChild("Atmosphere")] = {
		Offset = 0
	},
	[workspace.Terrain.Clouds] = {
		Density = 1
	},
	[Lighting] = {}
}
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 18)),
	ColorSequenceKeypoint.new(0.041666666666666664, Color3.fromRGB(20, 20, 20)),
	ColorSequenceKeypoint.new(0.125, Color3.fromRGB(49, 49, 49)),
	ColorSequenceKeypoint.new(0.16666666666666666, Color3.fromRGB(33, 36, 70)),
	ColorSequenceKeypoint.new(0.20833333333333334, Color3.fromRGB(60, 48, 72)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(63, 43, 72)),
	ColorSequenceKeypoint.new(0.2708333333333333, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.7083333333333334, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(50, 29, 10)),
	ColorSequenceKeypoint.new(0.7583333333333333, Color3.fromRGB(170, 105, 60)),
	ColorSequenceKeypoint.new(0.7708333333333334, Color3.fromRGB(155, 105, 85)),
	ColorSequenceKeypoint.new(0.8333333333333334, Color3.fromRGB(90, 95, 120)),
	ColorSequenceKeypoint.new(0.875, Color3.fromRGB(28, 30, 31)),
	ColorSequenceKeypoint.new(0.9583333333333334, Color3.fromRGB(20, 20, 20)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 18))
})
local v2 = {
	Clear = {
		CloudBaseColor = Color3.new(1, 1, 1),
		CloudTimeAlpha = 1,
		CloudCoverage = NumberRange.new(0.5, 0.75),
		Density = 0.23,
		Glare = 0.35,
		Haze = 2,
		RainIntensity = NumberRange.new(0, 0),
		SnowIntensity = NumberRange.new(0, 0),
		WindStrength = NumberRange.new(5, 20),
		ThunderChance = 0,
		ForceTime = nil,
		CelestialBodySize = 11
	},
	Rain = {
		CloudBaseColor = Color3.new(0.286275, 0.313725, 0.380392),
		CloudTimeAlpha = 0.35,
		CloudCoverage = NumberRange.new(0.75, 0.85),
		Density = 0.45,
		Glare = 0,
		Haze = 3,
		RainIntensity = NumberRange.new(0.2, 0.7),
		SnowIntensity = NumberRange.new(0, 0),
		WindStrength = NumberRange.new(40, 70),
		ThunderChance = 0,
		ForceTime = nil,
		CelestialBodySize = 11
	},
	Storm = {
		CloudBaseColor = Color3.new(0.262745, 0.32549, 0.4),
		CloudTimeAlpha = 0.3,
		CloudCoverage = NumberRange.new(0.85, 0.95),
		Density = 0.55,
		Glare = 0,
		Haze = 4,
		RainIntensity = NumberRange.new(0.75, 1),
		SnowIntensity = NumberRange.new(0, 0),
		WindStrength = NumberRange.new(90, 120),
		ThunderChance = 30,
		ForceTime = nil,
		CelestialBodySize = 11
	},
	Snow = {
		CloudBaseColor = Color3.new(0.2, 0.231373, 0.301961),
		CloudTimeAlpha = 0.4,
		CloudCoverage = NumberRange.new(0.85, 0.95),
		Density = 0.55,
		Glare = 0,
		Haze = 4,
		RainIntensity = NumberRange.new(0, 0),
		SnowIntensity = NumberRange.new(0.85, 1),
		WindStrength = NumberRange.new(35, 60),
		ThunderChance = 0,
		ForceTime = nil,
		CelestialBodySize = 11
	},
	Halloween = {
		CloudBaseColor = Color3.fromRGB(80, 28, 28),
		CloudTimeAlpha = 0,
		CloudCoverage = NumberRange.new(0.775, 0.775),
		Density = 0.3,
		Glare = 3.9,
		Haze = 10,
		RainIntensity = NumberRange.new(0.75, 1),
		WindStrength = NumberRange.new(90, 120),
		SnowIntensity = NumberRange.new(0, 0),
		ThunderChance = 30,
		ForceTime = 22,
		CelestialBodySize = 80,
		CustomProperties = {
			[Lighting] = {
				Ambient = Color3.fromRGB(99, 99, 99),
				Brightness = 0.59,
				OutdoorAmbient = Color3.fromRGB(66, 40, 66)
			},
			[Lighting:WaitForChild("ColorCorrection")] = {
				Brightness = 0.05,
				Contrast = 0.1,
				Saturation = 1.25,
				TintColor = Color3.fromRGB(203, 206, 247)
			},
			[Lighting:WaitForChild("Atmosphere")] = {
				Offset = 0.5,
				Color = Color3.fromRGB(59, 15, 12)
			},
			[workspace.Terrain.Clouds] = {
				Density = 0.317
			}
		}
	},
	Blackout = {
		CloudBaseColor = Color3.new(0.207843, 0.207843, 0.309804),
		CloudTimeAlpha = 0,
		CloudCoverage = NumberRange.new(0.95, 0.95),
		Density = 0.65,
		Glare = 0,
		Haze = 10,
		RainIntensity = NumberRange.new(0, 0),
		WindStrength = NumberRange.new(90, 120),
		SnowIntensity = NumberRange.new(0, 0),
		ThunderChance = 0,
		ForceTime = nil,
		CelestialBodySize = 0
	},
	Venue = {
		CloudBaseColor = Color3.new(0.521569, 0.521569, 0.780392),
		CloudTimeAlpha = 0,
		CloudCoverage = NumberRange.new(0, 0),
		Density = 0.4,
		Glare = 0.45,
		Haze = 1.7,
		RainIntensity = NumberRange.new(0, 0),
		WindStrength = NumberRange.new(90, 120),
		SnowIntensity = NumberRange.new(0, 0),
		ThunderChance = 0,
		ForceTime = 6,
		CelestialBodySize = 0,
		ExposureCompensation = 0,
		CustomProperties = {
			[Lighting] = {
				Ambient = Color3.fromRGB(0, 0, 0),
				Brightness = 0.5,
				ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
				ColorShift_Top = Color3.fromRGB(255, 129, 25),
				EnvironmentDiffuseScale = 1,
				EnvironmentSpecularScale = 1,
				OutdoorAmbient = Color3.fromRGB(80, 75, 116),
				GeographicLatitude = 55.701
			},
			[Lighting:WaitForChild("ColorCorrection")] = {
				Brightness = 0,
				Contrast = 0.01,
				Saturation = 0.2,
				TintColor = Color3.fromRGB(255, 242, 234)
			},
			[Lighting:WaitForChild("Atmosphere")] = {
				Offset = 0.6,
				Color = Color3.fromRGB(134, 103, 238),
				Decay = Color3.fromRGB(58, 104, 220)
			},
			[workspace.Terrain.Clouds] = {
				Density = 0
			}
		}
	}
}
local Icon = require(ReplicatedStorage.Modules.Icon)
local v7 = Icon.new()
v7:setOrder(101)
v7:lock()
v7:setEnabled(false)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace:FindFirstChild("Places") or workspace:FindFirstChild("Map") }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local currentCamera = workspace.CurrentCamera
local clone = ReplicatedStorage.Assets.Misc.Rain:Clone()
local weather = SoundService.Weather
local v8 = {
	Storming = "rbxassetid://15706999553",
	Raining = "rbxassetid://15706999731",
	Snowing = "rbxassetid://15706999254",
	Sunny = "rbxassetid://15706999377",
	Night = "rbxassetid://15706999079"
}
local ambient = nil
local brightness = nil
local outdoorAmbient = nil
local color = nil
local v9 = {
	{ 0.25, "Weak" },
	{ 0.75, "Medium" },
	{ 1, "Strong" }
}
local v10 = {
	RainIntensity = 0,
	CloudCoverage = 0,
	WindStrength = 0
}
local v11 = nil

for _, sound in weather.Rain:GetDescendants() do
	if sound:IsA("Sound") then
		sound.SoundGroup = weather
	end
end

for _, emitter in clone:GetChildren() do
	if not emitter:IsA("ParticleEmitter") then
		continue
	end

	for _, part in clone:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local clone_2 = emitter:Clone()
		clone_2.Parent = part
	end

	emitter:Destroy()
end

clone.Parent = workspace

local function UpdateWeatherIcon(p: string)
	v7:setLabel((`{p}`))
	v7:setImage(v8[p])
end

local function GetCurrentWeatherPresetName()
	local weatherChoice = Players.LocalPlayer:GetAttribute("WeatherChoice")

	if Players.LocalPlayer:GetAttribute("State") == 7 then
		if sky.Parent == Lighting then
			sky.Parent = script
		end

		if sky2.Parent ~= Lighting then
			sky2.Parent = Lighting
		end

		return "Venue"
	else
		if sky.Parent ~= Lighting then
			sky.Parent = Lighting
		end

		if sky2.Parent ~= script then
			sky2.Parent = script
		end

		if _G.Blackout then
			return "Blackout"
		end

		if weatherChoice == 1 then
			local currentHoliday = Holiday:GetCurrentHoliday()

			if currentHoliday.Name == "Christmas" then
				return "Snow"
			end

			if currentHoliday.Name == "Halloween" then
				return "Halloween"
			end

			local serverTimeNow = workspace:GetServerTimeNow()
			local v12 = tonumber(os.date("%H", serverTimeNow)) or 0

			if serverTimeNow % 1800 < 600 then
				if v12 % 2 == 0 then
					return "Storm"
				end

				return "Rain"
			else
				return "Clear"
			end
		else
			if weatherChoice == 2 then
				return "Clear"
			elseif weatherChoice == 3 then
				return "Rain"
			elseif weatherChoice == 4 then
				return "Storm"
			end

			return "Clear"
		end
	end
end

local function GetCurrentWeatherConfig()
	local currentWeatherPresetName = GetCurrentWeatherPresetName()
	return v2[currentWeatherPresetName], currentWeatherPresetName
end

local function EvaluateColorSequence(colorSequence2, p: number)
	if p == 0 then
		return colorSequence2.Keypoints[1].Value
	elseif p == 1 then
		return colorSequence2.Keypoints[#colorSequence2.Keypoints].Value
	end

	for i = 1, #colorSequence2.Keypoints - 1 do
		local keypoint = colorSequence2.Keypoints[i]
		local keypoint2 = colorSequence2.Keypoints[i + 1]

		if not (keypoint.Time <= p and p < keypoint2.Time) then
			continue
		end

		local v12 = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return Color3.new(
			(keypoint2.Value.R - keypoint.Value.R) * v12 + keypoint.Value.R,
			(keypoint2.Value.G - keypoint.Value.G) * v12 + keypoint.Value.G,
			(keypoint2.Value.B - keypoint.Value.B) * v12 + keypoint.Value.B
		)
	end

	return colorSequence2.Keypoints[1].Value
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateParticleEmittersRate(p: string, rate: number)
	for _, v12 in CollectionService:GetTagged("RainParticleEmitter") do
		if v12.Name == p then
			v12.Rate = rate
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetFirstTweenInfo()
	if workspace.DistributedGameTime < 10 then
		return tweenInfo
	end

	return nil
end

local function IsIndoors()
	local position = currentCamera.CFrame.Position
	local raycastResult = workspace:Raycast(position, createVector(0, 50, 0), raycastParams)
	return raycastResult and raycastResult.Instance:IsA("BasePart") and raycastResult.Instance.Transparency < 1
end

local function GetClockTime()
	local v13 = v2[GetCurrentWeatherPresetName()]

	if v13.ForceTime then
		return v13.ForceTime
	end

	local serverTimeNow = math.floor((workspace:GetServerTimeNow()))
	local timeOfDay = game.Players.LocalPlayer:GetAttribute("TimeOfDay") or 1

	if timeOfDay == 2 then
		local v14 = os.date("*t")
		return v14.hour + (v14.min + v14.sec / 60) / 60
	elseif timeOfDay == 3 then
		return 6.1
	elseif timeOfDay == 4 then
		return 6.2
	elseif timeOfDay == 5 then
		return 14
	elseif timeOfDay == 6 then
		return 17.9
	elseif timeOfDay == 7 then
		return 20.5
	elseif timeOfDay == 8 then
		return 0
	end

	return Lighting:GetAttribute("ClockTime") or serverTimeNow / 60 % 24
end

local v12 = {
	0,
	6,
	10,
	14,
	18,
	20,
	24
}
local _ = {
	Day = -0.2,
	Night = 0.8
}
local v13 = Parametric.new({
	Vector2.new(0, 0.8),
	Vector2.new(5, -0.2),
	Vector2.new(17, -0.2),
	Vector2.new(24, 0.8)
})

local function GetExposureCompensation()
	return v2[GetCurrentWeatherPresetName()].ExposureCompensation or v13:GetPositionAt((GetClockTime()))
end

local function GetImportantClockTime()
	local clockTime = GetClockTime()

	for k, v15 in next, v12, nil do
		if clockTime < v15 then
			return v12[k - 1] or v12[1]
		end
	end

	return v12[#v12]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCloudColor()
	local v15 = v2[GetCurrentWeatherPresetName()]
	local cloudBaseColor = v15.CloudBaseColor
	local cloudTimeAlpha = v15.CloudTimeAlpha
	return cloudBaseColor:Lerp(EvaluateColorSequence(colorSequence, Lighting.ClockTime / 24), cloudTimeAlpha)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateAtmosphere(density: number, haze: number, glare: number)
	local firstTweenInfo = GetFirstTweenInfo() -- equivalent call inferred; original call site unknown
	TweenService:Create(atmosphere, firstTweenInfo or tweenInfo2, {
		Density = density,
		Haze = haze,
		Glare = glare
	}):Play()
end

local function UpdateCustomProperties(customProperties)
	if customProperties[Lighting] then
		if customProperties[Lighting].Ambient then
			ambient = customProperties[Lighting].Ambient
		else
			ambient = nil
		end

		if customProperties[Lighting].Brightness then
			brightness = customProperties[Lighting].Brightness
		else
			brightness = nil
		end

		if customProperties[Lighting].OutdoorAmbient then
			outdoorAmbient = customProperties[Lighting].OutdoorAmbient
		else
			outdoorAmbient = nil
		end
	else
		ambient = nil
		brightness = nil
		outdoorAmbient = nil
	end

	if customProperties[atmosphere] then
		if customProperties[atmosphere].Color then
			color = customProperties[atmosphere].Color
		else
			color = nil
		end
	else
		color = nil
	end

	for k, item in customProperties do
		local firstTweenInfo = GetFirstTweenInfo() -- equivalent call inferred; original call site unknown
		TweenService:Create(k, firstTweenInfo or tweenInfo2, item):Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetCloudCoverage(cover: number)
	local firstTweenInfo = GetFirstTweenInfo() -- equivalent call inferred; original call site unknown
	TweenService:Create(clouds, firstTweenInfo or tweenInfo2, {
		Cover = cover
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetRainIntensity(p: number)
	UpdateParticleEmittersRate("Rain", p * 200) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetSnowIntensity(p: number)
	UpdateParticleEmittersRate("Snow", p * 100) -- equivalent call inferred; original call site unknown
end

local function FindBestRainType(value: number)
	local v14 = math.clamp(value, 0, 1)
	local v15 = 0

	for _, v16 in v9 do
		local v17 = v16[1]
		local v18 = v16[2]

		if v15 <= v14 and v14 <= v17 then
			return v18
		else
			v15 = v17
		end
	end

	return 0
end

local function ApplyWeather()
	local currentWeatherPresetName = GetCurrentWeatherPresetName()
	local v15 = v2[currentWeatherPresetName]

	if workspace:GetAttribute("CurrentWeatherPreset") ~= currentWeatherPresetName then
		workspace:SetAttribute("CurrentWeatherPreset", (GetCurrentWeatherPresetName()))
	end

	local v16 = math.floor(workspace:GetServerTimeNow() / 600) * 600
	local random = Random.new(v16)
	local rainIntensity = random:NextInteger(v15.RainIntensity.Min * 100, v15.RainIntensity.Max * 100) / 100
	local v18 = random:NextInteger(v15.SnowIntensity.Min * 100, v15.SnowIntensity.Max * 100) / 100
	local cloudCoverage = random:NextInteger(v15.CloudCoverage.Min * 100, v15.CloudCoverage.Max * 100) / 100
	local integer = random:NextInteger(v15.WindStrength.Min, v15.WindStrength.Max)
	v10 = {
		RainIntensity = rainIntensity,
		CloudCoverage = cloudCoverage,
		WindStrength = integer,
		ThunderChance = v15.ThunderChance
	}
	SetRainIntensity(rainIntensity) -- equivalent call inferred; original call site unknown
	SetSnowIntensity(v18) -- equivalent call inferred; original call site unknown
	SetCloudCoverage(cloudCoverage) -- equivalent call inferred; original call site unknown
	UpdateAtmosphere(v15.Density, v15.Haze, v15.Glare) -- equivalent call inferred; original call site unknown
	UpdateCustomProperties(v15.CustomProperties or v)
	local unitVector = random:NextUnitVector()
	local vector2 = Vector3.new(unitVector.X, math.abs(unitVector.Y), unitVector.Z)
	workspace.GlobalWind = vector2 * integer
	local v20 = v10.RainIntensity > 0
	local v21 = v10.ThunderChance > 0

	if v20 and not v21 then
		v7:setLabel("Raining")
		v7:setImage(v8.Raining)
	elseif v20 and v21 then
		v7:setLabel("Storming")
		v7:setImage(v8.Storming)
	elseif GetClockTime() > 6 and GetClockTime() < 18 then
		v7:setLabel("Sunny")
		v7:setImage(v8.Sunny)
	else
		v7:setLabel("Night")
		v7:setImage(v8.Night)
	end
end

local function UpdateRainSound()
	local v14 = math.clamp(v10.RainIntensity, 0, 1)
	local v15 = 0
	local flag = true
	local v16

	for _, v17 in v9 do
		local v18 = v17[1]
		v16 = v17[2]

		if v15 <= v14 and v14 <= v18 then
			flag = false
			break
		else
			v15 = v18
		end
	end

	if flag then
		v16 = 0
	end

	local position = currentCamera.CFrame.Position
	local raycastResult = workspace:Raycast(position, createVector(0, 50, 0), raycastParams)
	local v17 = raycastResult and raycastResult.Instance:IsA("BasePart") and raycastResult.Instance.Transparency < 1

	for _, emitter in clone.PrimaryPart:GetChildren() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if v17 then
			emitter.Transparency = NumberSequence.new(1)
		else
			emitter.Transparency = NumberSequence.new(0.8, 0.2)
		end
	end

	local v18 = weather.Rain[v17 and "Indoor" or "Outdoor"][v16]
	v18.Playing = true
	v18.Looped = true

	if v18 then
		TweenService:Create(v18, tweenInfo3, {
			Volume = v10.RainIntensity > 0 and 0.2 or 0
		}):Play()
	end

	if v11 and v11 ~= v18 and v11.Volume ~= 0 then
		TweenService:Create(v11, tweenInfo3, {
			Volume = 0
		}):Play()
		v11 = nil
	end

	v11 = v18
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateRainAcceleration()
	local acceleration = workspace.GlobalWind.Unit * 35 - createVector(0, 50, 0)

	for _, v15 in CollectionService:GetTagged("RainParticleEmitter") do
		if v15.Name == "Rain" then
			v15.Acceleration = acceleration
		end
	end
end

local function Lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function RenderUpdate(p: number)
	local _ = v2[GetCurrentWeatherPresetName()]
	clone:PivotTo(CFrame.new(currentCamera.CFrame.Position) * cframe)
	local v15 = math.clamp(p * (workspace.DistributedGameTime < 5 and 100000 or 1), 0, 1)
	clouds.Color = clouds.Color:Lerp(GetCloudColor(), v15)
	local v17 = atmosphere
	local color2 = color

	if not color2 then
		color2 = atmosphere.Color:Lerp(GetCloudColor(), v15)
	end

	v17.Color = color2
	atmosphere.Decay = Color3.new(0, 0, 0)
	Lighting.Brightness = brightness or 2 - clouds.Cover * 1.5
	local parent = Lighting
	local ambient2 = ambient

	if not ambient2 then
		ambient2 = (GetCloudColor()):Lerp(Color3.new(0, 0, 0), 0.65)
	end

	parent.Ambient = ambient2
	local parent2 = Lighting
	local outdoorAmbient2 = outdoorAmbient

	if not outdoorAmbient2 then
		outdoorAmbient2 = (GetCloudColor()):Lerp(Color3.new(0.247059, 0.286275, 0.490196), 0.5)
	end

	parent2.OutdoorAmbient = outdoorAmbient2
	local v24 = v2[GetCurrentWeatherPresetName()]
	local sky3 = Lighting:FindFirstChildOfClass("Sky")

	if sky3 then
		local moonAngularSize = sky3.MoonAngularSize
		sky3.MoonAngularSize = moonAngularSize + (v24.CelestialBodySize - moonAngularSize) * v15
	end

	local disableShadows = Players.LocalPlayer:GetAttribute("DisableShadows") or false
	Lighting.GlobalShadows = not disableShadows
	UpdateRainSound()
	UpdateRainAcceleration() -- equivalent call inferred; original call site unknown
end

ApplyWeather()
RunService:BindToRenderStep("WeatherRenderUpdate", Enum.RenderPriority.Camera.Value + 1, RenderUpdate)
task.spawn(function()
	local now = 0
	local timeOfDay = Players.LocalPlayer:GetAttribute("TimeOfDay") or 1
	local v14 = -1
	local v15, v16, timeOfDay2, v17, v18, clockTime, v20, v21, tweenInfo4, v22, v23

	if UserInputService.TouchEnabled then
		v15 = 1
		v16 = 1e999
	else
		v15 = 1
		v16 = 0
	end

	while true do
		ApplyWeather()
		timeOfDay2 = Players.LocalPlayer:GetAttribute("TimeOfDay")
		v17 = timeOfDay2 ~= timeOfDay
		v18 = GetClockTime()
		local flag = true

		for k, v24 in next, v12, nil do
			if not (v18 < v24) then
				continue
			end

			clockTime = v12[k - 1] or v12[1]
			flag = false
			break
		end

		if flag then
			clockTime = v12[#v12]
		end

		clockTime = GetClockTime()

		if UserInputService.TouchEnabled and v14 ~= clockTime then
			v17 = true
		end

		if v17 or v16 < os.time() - now then
			now = os.time()
			v20 = TweenService
			v21 = Lighting
			tweenInfo4 = TweenInfo.new(v17 and 1 or v15, Enum.EasingStyle.Linear)
			v22 = {
				ClockTime = clockTime,
				ExposureCompensation = 0
			}
			v23 = GetCurrentWeatherPresetName()
			v22.ExposureCompensation = v2[v23].ExposureCompensation or v13:GetPositionAt((GetClockTime()))
			v20:Create(v21, tweenInfo4, v22):Play()
			v14 = clockTime
			timeOfDay = timeOfDay2
		end

		task.wait(1)
	end
end)
task.spawn(function()
	while true do
		local thunderChance = v2[GetCurrentWeatherPresetName()].ThunderChance

		if thunderChance <= 0 then
			task.wait()
		else
			local random = Random.new((math.floor((workspace:GetServerTimeNow()))))

			if random:NextInteger(1, 100) <= thunderChance then
				local v15 = ambient

				for _ = 1, random:NextInteger(3, 6) do
					ambient = Color3.fromRGB(172, 190, 221)
					task.wait(random:NextInteger(5, 13) / 100)
					ambient = v15
					task.wait(0.05)
				end

				task.wait(0.1)
				local v16 = random:NextUnitVector() * createVector(1, 0, 1)
				local integer = random:NextInteger(100, 300)
				local v17 = workspace.CurrentCamera.CFrame.Position + v16 * (integer * 2)
				local part = Instance.new("Part", workspace)
				part.Position = v17 + createVector(0, 100, 0)
				part.Anchored = true
				part.Transparency = 1
				part.CanQuery = false
				part.CanCollide = false
				part.CanTouch = false
				local v18 = integer > 200
				local v19 = weather.Thunder[v18 and "Far" or "Close"]
				local clone2 = v19:GetChildren()[math.random(1, #v19:GetChildren())]:Clone()
				clone2.Parent = part
				local position = currentCamera.CFrame.Position
				local raycastResult = workspace:Raycast(position, createVector(0, 50, 0), raycastParams)

				if raycastResult and raycastResult.Instance:IsA("BasePart") and raycastResult.Instance.Transparency < 1 then
					local clone3 = weather.Muffle:Clone()
					clone3.Parent = clone2
					clone3.Enabled = true
				end

				clone2:Play()
				clone2.SoundGroup = weather
				clone2.Ended:Connect(function()
					part:Destroy()
				end)
				ambient = v15
			end

			task.wait(5)
		end
	end
end)