local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.DayAndNightHandler)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
cleanit.new()
return {
	Properties = {
		Ambient = Color3.fromRGB(126, 105, 105),
		Brightness = 3,
		ColorShift_Bottom = Color3.new(),
		ColorShift_Top = Color3.fromRGB(202, 141, 56),
		EnvironmentDiffuseScale = 0.808,
		EnvironmentSpecularScale = 0.718,
		GlobalShadows = true,
		OutdoorAmbient = Color3.fromRGB(70, 70, 70),
		ShadowSoftness = 0.2,
		ClockTime = 11.378,
		GeographicLatitude = 20.347,
		ExposureCompensation = 0
	},
	Instances = script:GetChildren()
}