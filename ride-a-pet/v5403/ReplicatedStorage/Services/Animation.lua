local Animation = {}
game:GetService("Debris")

function Animation.LoadPlayAndCleanup(_, instance, animation, options)
	local v = options or {}
	local cleanupTime = v.CleanupTime
	local speed = v.Speed or 1
	local track = instance:WaitForChild("Humanoid"):FindFirstChildOfClass("Animator"):LoadAnimation(animation)
	task.spawn(function()
		local lastTime = os.time()

		while task.wait(0.1) and not (os.time() - lastTime >= 10 or track.Length > 0) do

		end

		track:Play()
		track:AdjustSpeed(speed)

		if track.Looped == false then
			cleanupTime = track.Length
		end

		if cleanupTime then
			task.delay(cleanupTime, function()
				track:Stop()
				track:Destroy()
			end)
		end
	end)
	return track
end

return Animation