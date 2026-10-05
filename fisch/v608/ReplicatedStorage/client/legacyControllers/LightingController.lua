local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Hook = require(ReplicatedStorage.shared.modules.Hook)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local LightingController = {
	PropertyStyles = {
		Terrain = {
			WaterWaveSize = "instant"
		},
		Sky = {
			StarCount = "instant"
		},
		Lighting = {
			ClockTime = "instant",
			GeographicLatitude = "instant",
			Brightness = "instant"
		}
	},
	Defaults = {
		Atmosphere = {
			Density = 0.35,
			Offset = 0,
			Color = Color3.fromRGB(255, 255, 255),
			Decay = Color3.fromRGB(216, 240, 255),
			Glare = 0,
			Haze = 0
		},
		ColorCorrectionEffect = {
			Brightness = -0.025,
			Contrast = 0,
			Saturation = 0.1,
			TintColor = Color3.fromRGB(255, 255, 255)
		},
		Terrain = {
			WaterWaveSize = 0.15,
			WaterWaveSpeed = 10
		},
		Clouds = {
			Density = 0,
			Cover = 0,
			Color = Color3.fromRGB(255, 255, 255)
		},
		Sky = {
			StarCount = 3000,
			MoonTextureId = "rbxasset://sky/moon.jpg",
			MoonAngularSize = 6,
			SunTextureId = "rbxasset://sky/sun.jpg",
			SunAngularSize = 10,
			SkyboxBk = "rbxassetid://91458024",
			SkyboxDn = "rbxassetid://91457980",
			SkyboxFt = "rbxassetid://91458024",
			SkyboxLf = "rbxassetid://91458024",
			SkyboxRt = "rbxassetid://91458024",
			SkyboxUp = "rbxassetid://91458002",
			SkyboxOrientation = vector.create(0, 0, 0)
		},
		BloomEffect = {
			Intensity = 0.4,
			Size = 24,
			Threshold = 1
		},
		BlurEffect = {
			Size = 0
		},
		DepthOfFieldEffect = {
			FarIntensity = 1,
			FocusDistance = 0.5,
			InFocusRadius = 350,
			NearIntensity = 0
		},
		SunRaysEffect = {
			Intensity = 0.147,
			Spread = 0.831
		},
		Lighting = {
			ClockTime = function()
				return (Lighting:GetAttribute("CurrentTime") or 12.5) / 60
			end,
			GeographicLatitude = 41.733,
			EnvironmentDiffuseScale = 1,
			EnvironmentSpecularScale = 1,
			ExposureCompensation = -0.2,
			Ambient = Color3.fromRGB(138, 138, 138),
			OutdoorAmbient = Color3.fromRGB(63, 63, 63),
			ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
			ColorShift_Top = Color3.fromRGB(0, 0, 0),
			Brightness = function()
				return math.cos((Lighting:GetAttribute("CurrentTime") or 12.5) / 60 * 0.2617993877991494 + 3.141592653589793) + 2
			end
		}
	},
	LastTargetProperties = {}
}
local v = false

for k in LightingController.Defaults do
	LightingController.LastTargetProperties[k] = {}
end

LightingController.ObjectMap = {
	Atmosphere = Lighting:WaitForChild("atmos"),
	ColorCorrectionEffect = Lighting:WaitForChild("location"),
	Terrain = workspace.Terrain,
	Clouds = workspace.Terrain:WaitForChild("Clouds"),
	Sky = Lighting:WaitForChild("Sky"),
	BloomEffect = Lighting:WaitForChild("bloom"),
	BlurEffect = Lighting:WaitForChild("lightingBlur"),
	DepthOfFieldEffect = Lighting:WaitForChild("dof"),
	SunRaysEffect = Lighting:WaitForChild("sunrays"),
	Lighting = Lighting
}
LightingController.HookLighting = Hook.new(function()
	local copy = GeneralUtils.copy(LightingController.Defaults, true)

	for _, v2 in copy do
		for k, v3 in v2 do
			if typeof(v3) == "function" then
				v2[k] = v3()
			end
		end
	end

	return copy
end)

function LightingController.UpdateLighting(duration: number)
	local lastTargetProperties = LightingController.HookLighting:InvokeAsync()
	lastTargetProperties.ColorCorrectionEffect.Saturation = math.max(
		lastTargetProperties.ColorCorrectionEffect.Saturation,
		-1
	)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad)
	debug.profilebegin("LightingController::UpdateLighting")

	for k, v3 in lastTargetProperties do
		debug.profilebegin(k)
		local propertyStyle = LightingController.PropertyStyles[k]

		for k2, v4 in v3 do
			if LightingController.LastTargetProperties[k][k2] == v4 then
				continue
			end

			local v5 = propertyStyle and propertyStyle[k2]
			local v6 = LightingController.ObjectMap[k]

			if v5 == "instant" or typeof(v4) == "string" then
				v6[k2] = v4
			else
				GeneralUtils.fastTween(v6, tweenInfo, {
					[k2] = v4
				})
			end
		end

		debug.profileend()
	end

	LightingController.LastTargetProperties = lastTargetProperties
	local clockTime = lastTargetProperties.Lighting.ClockTime
	v = clockTime >= 18 or clockTime < 6.5
	debug.profileend()
end

function LightingController.UpdateCycleLighting()
	local v2 = LightingController.HookLighting:InvokeAsync()
	debug.profilebegin("LightingController::UpdateCycleLighting")
	local clockTime = v2.Lighting.ClockTime
	local v3 = clockTime >= 18 or clockTime < 6.5

	if v3 == v then
		Lighting.ClockTime = clockTime
		Lighting.GeographicLatitude = v2.Lighting.GeographicLatitude
		Lighting.Brightness = v2.Lighting.Brightness
	else
		v = v3
		LightingController.UpdateLighting(1)
	end

	debug.profileend()
end

function LightingController:Start()
	Lighting:GetAttributeChangedSignal("CurrentTime"):Connect(LightingController.UpdateCycleLighting)
	LightingController.UpdateLighting(0)

	for _, child in script:GetChildren() do
		local v2 = child
		task.defer(function()
			local module = require(v2)
			module:Start()
		end)
	end
end

return LightingController