local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sound = require(ReplicatedStorage.Util.Sound)
local CelestialTransitionEffect = require(ReplicatedStorage.Controllers.MapServices.Transitions.CelestialTransitionEffect)
local flag = false
local celestialAwakenTransition = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CelestialAwakenTransition", 60)

if not celestialAwakenTransition then
	return
end

local function playTransition(value: number?)
	if flag then
		return
	end

	flag = true
	local v = Sound:Play("GravFruit_M1_Meteor_IncomingLoop_01_V2", workspace._WorldOrigin)

	if v then
		v.PlaybackSpeed = 0.75
		v.Volume = 0.65
	end

	task.spawn(function()
		CelestialTransitionEffect.Play()
	end)
	task.delay(value or 3, function()
		CelestialTransitionEffect.StopEarly()

		if v then
			task.spawn(function()
				Sound:FadeOut(v)
				v:Destroy()
			end)
		end

		flag = false
	end)
end

celestialAwakenTransition.OnClientEvent:Connect(function(p: number?)
	playTransition(p)
end)