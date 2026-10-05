local IntroController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
IntroController.OnPlayButtonPressed = Signal.new()
local v = false

function IntroController.FrameworkInit() end

function IntroController.HasPassedIntro()
	return v
end

function IntroController.FrameworkStart() end

function IntroController.NotifyPlayButtonPressed()
	v = true
	IntroController.OnPlayButtonPressed:Fire()
end

return IntroController