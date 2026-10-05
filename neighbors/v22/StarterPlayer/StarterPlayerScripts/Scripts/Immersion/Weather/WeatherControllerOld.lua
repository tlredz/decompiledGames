local createVector = vector.create
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
game:GetService("UserInputService")
local Holiday = require(ReplicatedStorage.Modules.Holiday)
local cframe = CFrame.new(0, 100, 0)
local tweenInfo = TweenInfo.new(0)
local tweenInfo2 = TweenInfo.new(10)
local tweenInfo3 = TweenInfo.new(0.2)
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
	ColorSequenceKeypoint.new(0.7583333333333333, Color3.fromRGB(93, 65, 71)),
	ColorSequenceKeypoint.new(0.7708333333333334, Color3.fromRGB(111, 74, 92)),
	ColorSequenceKeypoint.new(0.8333333333333334, Color3.fromRGB(113, 67, 79)),
	ColorSequenceKeypoint.new(0.875, Color3.fromRGB(28, 30, 31)),
	ColorSequenceKeypoint.new(0.9583333333333334, Color3.fromRGB(20, 20, 20)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 18))
})
local v = {
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
		CloudBaseColor = Color3.new(0.282353, 0.282353, 0.282353),
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
		CloudBaseColor = Color3.new(0.533333, 0.533333, 0.533333),
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
		CloudBaseColor = Color3.new(0.278431, 0.0313725, 0.0313725),
		CloudTimeAlpha = 0,
		CloudCoverage = NumberRange.new(0.95, 0.95),
		Density = 0.5,
		Glare = 0,
		Haze = 10,
		RainIntensity = NumberRange.new(0.75, 1),
		WindStrength = NumberRange.new(90, 120),
		SnowIntensity = NumberRange.new(0, 0),
		ThunderChance = 30,
		ForceTime = 22,
		CelestialBodySize = 80
	}
}
local Icon = require(ReplicatedStorage.Modules.Icon)
local v2 = Icon.new()
v2:setOrder(101)
v2:lock()
v2:setEnabled(false)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace:FindFirstChild("Places") or workspace:FindFirstChild("Map") }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local currentCamera = workspace.CurrentCamera
local clone = ReplicatedStorage.Assets.Misc.Rain:Clone()
local weather = SoundService.Weather
local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "Atmosphere"
atmosphere.Parent = Lighting
local clouds = Instance.new("Clouds")
clouds.Name = "Clouds"
clouds.Parent = workspace.Terrain
clouds.Density = 1
local v3 = {
	Storming = "rbxassetid://15706999553",
	Raining = "rbxassetid://15706999731",
	Snowing = "rbxassetid://15706999254",
	Sunny = "rbxassetid://15706999377",
	Night = "rbxassetid://15706999079"
}
local v4 = {
	{ 0.25, "Weak" },
	{ 0.75, "Medium" },
	{ 1, "Strong" }
}
local v5 = {
	RainIntensity = 0,
	CloudCoverage = 0,
	WindStrength = 0
}
local v6 = nil
local color = nil
local v7 = {}

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
	v2:setLabel((`{p}`))
	v2:setImage(v3[p])
end

local function GetCurrentWeatherPresetName()
	local weatherChoice = Players.LocalPlayer:GetAttribute("WeatherChoice")

	if weatherChoice == 1 then
		local currentHoliday = Holiday:GetCurrentHoliday()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v8 = tonumber(os.date("%H", serverTimeNow)) or 0

		if currentHoliday.Name == "Christmas" then
			return "Snow"
		end

		if currentHoliday.Name == "Halloween" then
			return "Halloween"
		end

		if serverTimeNow % 1800 < 600 then
			if v8 % 2 == 0 then
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

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCurrentWeatherConfig()
	workspace:SetAttribute("CurrentWeatherPreset", (GetCurrentWeatherPresetName()))
	return v[GetCurrentWeatherPresetName()]
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

		local v8 = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return Color3.new(
			(keypoint2.Value.R - keypoint.Value.R) * v8 + keypoint.Value.R,
			(keypoint2.Value.G - keypoint.Value.G) * v8 + keypoint.Value.G,
			(keypoint2.Value.B - keypoint.Value.B) * v8 + keypoint.Value.B
		)
	end

	return colorSequence2.Keypoints[1].Value
end

local function UpdateParticleEmittersRate(p: string, rate: number)
	for _, emitter in clone:GetDescendants() do
		if emitter:IsA("ParticleEmitter") and emitter.Name == p then
			emitter.Rate = rate
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

-- equivalent calls inferred from this helper; original call sites unknown
local function DistanceFromGround()
	local position = currentCamera.CFrame.Position
	local blockcast = workspace:Blockcast(
		CFrame.new(position),
		createVector(150, 0, 150),
		createVector(-0, -150, -0),
		raycastParams
	)
	return blockcast and blockcast.Instance.Transparency < 1 and blockcast.Distance or 150
end

local function GetClockTime()
	local serverTimeNow = math.floor((workspace:GetServerTimeNow()))
	local timeOfDay = game.Players.LocalPlayer:GetAttribute("TimeOfDay") or 1

	if timeOfDay == 2 then
		local v8 = os.date("*t")
		return v8.hour + (v8.min + v8.sec / 60) / 60
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

	return (GetCurrentWeatherConfig()).ForceTime or serverTimeNow / 60 % 24
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCloudColor()
	local currentWeatherConfig = GetCurrentWeatherConfig() -- equivalent call inferred; original call site unknown
	local cloudBaseColor = currentWeatherConfig.CloudBaseColor
	local cloudTimeAlpha = currentWeatherConfig.CloudTimeAlpha
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

-- equivalent calls inferred from this helper; original call sites unknown
local function SetCloudCoverage(cover: number)
	local firstTweenInfo = GetFirstTweenInfo() -- equivalent call inferred; original call site unknown
	TweenService:Create(clouds, firstTweenInfo or tweenInfo2, {
		Cover = cover
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetRainIntensity(p: number)
	UpdateParticleEmittersRate("Rain", p * 200)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetSnowIntensity(p: number)
	UpdateParticleEmittersRate("Snow", p * 100)
end

local function FindBestRainType(value: number)
	local v8 = math.clamp(value, 0, 1)
	local v9 = 0

	for _, v10 in v4 do
		local v11 = v10[1]
		local v12 = v10[2]

		if v9 <= v8 and v8 <= v11 then
			return v12
		else
			v9 = v11
		end
	end

	return 0
end

local function ApplyWeather()
	local currentWeatherConfig = GetCurrentWeatherConfig() -- equivalent call inferred; original call site unknown
	local v9 = math.floor(workspace:GetServerTimeNow() / 600) * 600
	local random = Random.new(v9)
	local rainIntensity = random:NextInteger(
		currentWeatherConfig.RainIntensity.Min * 100,
		currentWeatherConfig.RainIntensity.Max * 100
	) / 100
	local v11 = random:NextInteger(
		currentWeatherConfig.SnowIntensity.Min * 100,
		currentWeatherConfig.SnowIntensity.Max * 100
	) / 100
	local cloudCoverage = random:NextInteger(
		currentWeatherConfig.CloudCoverage.Min * 100,
		currentWeatherConfig.CloudCoverage.Max * 100
	) / 100
	local integer = random:NextInteger(currentWeatherConfig.WindStrength.Min, currentWeatherConfig.WindStrength.Max)
	v5 = {
		RainIntensity = rainIntensity,
		CloudCoverage = cloudCoverage,
		WindStrength = integer,
		ThunderChance = currentWeatherConfig.ThunderChance
	}
	SetRainIntensity(rainIntensity) -- equivalent call inferred; original call site unknown
	SetSnowIntensity(v11) -- equivalent call inferred; original call site unknown
	SetCloudCoverage(cloudCoverage) -- equivalent call inferred; original call site unknown
	UpdateAtmosphere(currentWeatherConfig.Density, currentWeatherConfig.Haze, currentWeatherConfig.Glare) -- equivalent call inferred; original call site unknown
	local unitVector = random:NextUnitVector()
	local vector2 = Vector3.new(unitVector.X, math.abs(unitVector.Y), unitVector.Z)
	workspace.GlobalWind = vector2 * integer
	local v13 = v5.RainIntensity > 0
	local v14 = v5.ThunderChance > 0

	if v13 and not v14 then
		v2:setLabel("Raining")
		v2:setImage(v3.Raining)
	elseif v13 and v14 then
		v2:setLabel("Storming")
		v2:setImage(v3.Storming)
	elseif GetClockTime() > 6 and GetClockTime() < 18 then
		v2:setLabel("Sunny")
		v2:setImage(v3.Sunny)
	else
		v2:setLabel("Night")
		v2:setImage(v3.Night)
	end
end

local function UpdateRainSound()
	local _ = GetCurrentWeatherConfig() -- equivalent call inferred; original call site unknown
	local v8 = math.clamp(v5.RainIntensity, 0, 1)
	local v9 = 0
	local flag = true
	local v10

	for _, v11 in v4 do
		local v12 = v11[1]
		v10 = v11[2]

		if v9 <= v8 and v8 <= v12 then
			flag = false
			break
		else
			v9 = v12
		end
	end

	if flag then
		v10 = 0
	end

	local position = currentCamera.CFrame.Position
	local raycastResult = workspace:Raycast(position, createVector(0, 50, 0), raycastParams)
	local v11 = raycastResult and raycastResult.Instance:IsA("BasePart") and raycastResult.Instance.Transparency < 1
	local distanceFromGround = DistanceFromGround() -- equivalent call inferred; original call site unknown

	for _, emitter in clone.PrimaryPart:GetChildren() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if v11 then
			emitter.Transparency = NumberSequence.new(1)
		else
			emitter.Transparency = NumberSequence.new(0.8, 0.2)
		end
	end

	local v13 = weather.Rain[v11 and "Indoor" or "Outdoor"][v10]
	v13.Playing = true
	v13.Looped = true
	local v14 = 0.2 * (1 - (v11 and 0 or distanceFromGround) / 150)

	if v13 then
		TweenService:Create(v13, tweenInfo3, {
			Volume = v5.RainIntensity > 0 and v14 or 0
		}):Play()
	end

	if v6 and v6 ~= v13 and v6.Volume ~= 0 then
		TweenService:Create(v6, tweenInfo3, {
			Volume = 0
		}):Play()
		v6 = nil
	end

	v6 = v13
end

local function UpdateRainAcceleration()
	local acceleration = workspace.GlobalWind.Unit * 35 - createVector(0, 50, 0)

	for _, emitter in clone:GetDescendants() do
		if emitter:IsA("ParticleEmitter") and emitter.Name == "Rain" then
			emitter.Acceleration = acceleration
		end
	end
end

local function Lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function RenderUpdate(p: number)
	clone:PivotTo(CFrame.new(currentCamera.CFrame.Position) * cframe)
	local v8 = math.clamp(p * (workspace.DistributedGameTime < 5 and 100000 or 1), 0, 1)
	clouds.Color = clouds.Color:Lerp(GetCloudColor(), v8)
	atmosphere.Color = atmosphere.Color:Lerp(GetCloudColor(), v8)
	atmosphere.Decay = Color3.new(0, 0, 0)
	Lighting.Brightness = 3
	local parent = Lighting
	local ambient = color

	if not ambient then
		ambient = (GetCloudColor()):Lerp(Color3.new(0.1, 0.1, 0.1), 0.35)
	end

	parent.Ambient = ambient
	local parent2 = Lighting
	local outdoorAmbient = color

	if not outdoorAmbient then
		outdoorAmbient = (GetCloudColor()):Lerp(Color3.new(0.3, 0.3, 0.6), 0.7)
	end

	parent2.OutdoorAmbient = outdoorAmbient
	local currentWeatherConfig = GetCurrentWeatherConfig() -- equivalent call inferred; original call site unknown
	local sky = Lighting:FindFirstChildOfClass("Sky")

	if sky then
		local moonAngularSize = sky.MoonAngularSize
		sky.MoonAngularSize = moonAngularSize + (currentWeatherConfig.CelestialBodySize - moonAngularSize) * v8
	end

	local disableShadows = Players.LocalPlayer:GetAttribute("DisableShadows") or false
	Lighting.GlobalShadows = not disableShadows
	UpdateRainSound()
	UpdateRainAcceleration()
end

ApplyWeather()
RunService:BindToRenderStep("WeatherRenderUpdate", Enum.RenderPriority.Camera.Value + 1, RenderUpdate)

if Holiday:GetCurrentHoliday().Name == "Christmas" then
	for _, folder in workspace.Places:GetChildren() do
		for _, part in folder:GetDescendants() do
			if not (part:IsA("BasePart") and part:GetAttribute("SnowySurface")) then
				continue
			end

			local clone2 = part:Clone()
			clone2.Material = Enum.Material.Snow
			clone2.Color = Color3.fromRGB(255, 237, 233)
			clone2.Transparency = 0
			clone2.Parent = part.Parent
			clone2.CanCollide = false
			clone2.CanTouch = false
			clone2.CanQuery = false
			clone2.CastShadow = false
			clone2.Name = `{part.Name}_SnowySurface`
			clone2.CFrame = part.CFrame
			clone2.CFrame *= CFrame.new(clone2.CFrame.UpVector * (part:GetAttribute("InvertSnow") and -0.3 or 0.3))
			clone2.Size *= 1.005
			table.insert(v7, clone2)
		end
	end
end

task.spawn(function()
	while true do
		ApplyWeather()
		TweenService:Create(Lighting, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			ClockTime = GetClockTime()
		}):Play()
		task.wait(1)
	end
end)
task.spawn(function()
	while true do
		local thunderChance = (GetCurrentWeatherConfig()).ThunderChance

		if thunderChance <= 0 then
			task.wait()
		else
			local random = Random.new((math.floor((workspace:GetServerTimeNow()))))

			if random:NextInteger(1, 100) <= thunderChance then
				for _ = 1, random:NextInteger(3, 6) do
					color = Color3.fromRGB(172, 190, 221)
					task.wait(random:NextInteger(5, 13) / 100)
					color = nil
					task.wait(0.05)
				end

				task.wait(0.1)
				local v8 = random:NextUnitVector() * createVector(1, 0, 1)
				local integer = random:NextInteger(100, 300)
				local v9 = workspace.CurrentCamera.CFrame.Position + v8 * (integer * 2)
				local part = Instance.new("Part", workspace)
				part.Position = v9 + createVector(0, 100, 0)
				part.Anchored = true
				part.Transparency = 1
				part.CanQuery = false
				part.CanCollide = false
				part.CanTouch = false
				local v10 = integer > 200
				local v11 = weather.Thunder[v10 and "Far" or "Close"]
				local clone2 = v11:GetChildren()[math.random(1, #v11:GetChildren())]:Clone()
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
				color = nil
			end

			task.wait(5)
		end
	end
end)