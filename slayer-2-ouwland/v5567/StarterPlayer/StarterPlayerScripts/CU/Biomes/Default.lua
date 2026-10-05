local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DayAndNightHandler = require(ReplicatedStorage.CAM.Global.DayAndNightHandler)
local NightIllumination = require(ReplicatedStorage.CAM.Client.Modules.NightIllumination)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local color = Color3.fromRGB(70, 70, 70)
local Default = {}
Default.Properties = {
	Ambient = color,
	Brightness = 2.5,
	ColorShift_Bottom = Color3.new(),
	ColorShift_Top = Color3.new(),
	EnvironmentDiffuseScale = 1,
	EnvironmentSpecularScale = 1,
	GlobalShadows = true,
	OutdoorAmbient = Color3.fromRGB(70, 70, 70),
	ShadowSoftness = 0.4,
	ClockTime = 12.5,
	GeographicLatitude = 45,
	ExposureCompensation = 0.1,
	FogColor = Color3.fromRGB(192, 192, 192),
	FogEnd = 100000,
	FogStart = 0
}

function Default.Do()
	if not gameSettings.IsMinigame then
		NightIllumination.Start({
			Day = {
				Ambient = color,
				ExposureCompensation = 0.1
			}
		})
	end

	maid:Add(task.spawn(function()
		while true do
			DayAndNightHandler.Apply()
			task.wait(0.5)
		end
	end))
end

function Default.Stop()
	maid:Clean()
	NightIllumination.Stop()
	DayAndNightHandler:Reset()
end

Default.Instances = script:GetChildren()
return Default