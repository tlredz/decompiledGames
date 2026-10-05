local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("WavingNPC", function(instance)
	local humanoid = instance:WaitForChild("Humanoid", 60)

	if not humanoid then
		return
	end

	local animator = humanoid:WaitForChild("Animator", 60)

	if not animator then
		return
	end

	local wave = script.Wave
	local idle = instance:FindFirstChild("Idle", true)

	if not (idle and idle:IsA("Animation")) then
		idle = script.Idle
	end

	local track = animator:LoadAnimation(wave)
	local track2 = animator:LoadAnimation(idle)
	local waveDelay = instance:GetAttribute("WaveDelay") or 6
	track2:Play()
	local connection = Utils.Thread.Every(waveDelay, function()
		track:Play()
	end)
	return function()
		connection:Disconnect()
		track:Stop()
		track2:Stop()
		track:Destroy()
		track2:Destroy()
	end
end)