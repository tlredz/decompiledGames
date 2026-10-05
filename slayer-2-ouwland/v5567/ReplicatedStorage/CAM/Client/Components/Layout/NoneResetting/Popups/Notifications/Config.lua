local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
return {
	OutInfo = faye.Info(0.2),
	InInfo = faye.SpringInfo(0.35, 1, 0.75),
	Types = {
		Default = "rbxassetid://117953321901489",
		Success = "rbxassetid://82709198238868",
		Warn = "rbxassetid://109855620542480",
		Suggest = "rbxassetid://131282726468841",
		Denied = "rbxassetid://121494857794481"
	},
	DefaultDurations = {
		Success = 3,
		Suggest = 5,
		Warn = 3,
		Denied = 3,
		Default = 3
	},
	ColorsLight = {
		Success = Color3.fromRGB(105, 255, 135),
		Suggest = Color3.fromRGB(105, 173, 255),
		Warn = Color3.fromRGB(255, 192, 83),
		Denied = Color3.fromRGB(255, 94, 66),
		Default = Color3.fromRGB(255, 255, 255)
	},
	Colors = {
		Success = Color3.fromRGB(17, 42, 22),
		Suggest = Color3.fromRGB(29, 48, 70),
		Warn = Color3.fromRGB(66, 50, 21),
		Denied = Color3.fromRGB(66, 24, 17),
		Default = Color3.fromRGB(50, 50, 50)
	},
	DefaultColor = Color3.fromRGB(255, 255, 255),
	DefaultTxt = "Default"
}