local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NightIllumination = require(ReplicatedStorage.CAM.Client.Modules.NightIllumination)
local color = Color3.fromRGB(100, 100, 100)
local MinigameFinalSelection = {}
MinigameFinalSelection.Properties = {
	ClockTime = 5,
	ExposureCompensation = 0.75,
	Ambient = color,
	Brightness = 2.5,
	ColorShift_Bottom = Color3.new(),
	ColorShift_Top = Color3.new(),
	EnvironmentDiffuseScale = 1,
	EnvironmentSpecularScale = 1,
	OutdoorAmbient = Color3.fromRGB(70, 70, 70),
	GeographicLatitude = 30.753
}

function MinigameFinalSelection.Do()
	NightIllumination.Start({
		AlwaysNight = true,
		Night = {
			Ambient = color,
			ExposureCompensation = 0.75
		}
	})
end

function MinigameFinalSelection.Stop()
	NightIllumination.Stop()
end

MinigameFinalSelection.Instances = script:GetChildren()
return MinigameFinalSelection