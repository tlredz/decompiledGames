local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.packages.vide)
return {
	keyboardEnabled = vide.source(false),
	touchscreenEnabled = vide.source(false),
	controllerEnabled = vide.source(false),
	region = vide.source("ocean"),
	cinematic = vide.source(false),
	windowRoute = vide.source(false),
	serverInfoEnabled = vide.source(false),
	serverUptime = vide.source(0),
	serverRegion = vide.source("N/A"),
	serverCountryCode = vide.source("N/A"),
	serverCity = vide.source("N/A"),
	serverVersion = vide.source("N/A")
}