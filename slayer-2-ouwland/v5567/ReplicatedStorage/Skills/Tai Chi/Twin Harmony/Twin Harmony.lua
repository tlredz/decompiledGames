local Config = require(script.Parent.Config)
local v = nil
local TwinHarmony = {}
TwinHarmony.Id = 0

function TwinHarmony.Hold(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	if v then
		v:Stop()
		v = nil
	end

	local track = humanoid.Animator:LoadAnimation(script.TaiChiTwinHarmonyMain)
	v = track
	track:Play()
	track:AdjustSpeed(0.16666666666666666 / Config.STARTUP)
	task.delay(Config.STARTUP, function()
		if v == track then
			track:AdjustSpeed(1)
		end
	end)
end

function TwinHarmony.UnHold(player)
	if v then
		v:Stop()
		v = nil
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local track = humanoid.Animator:LoadAnimation(script.TaiChiTwinHarmonyMain)
	track:Play()
	track.Stopped:Wait()
end

function TwinHarmony.Cancel(_)
	if v then
		v:Stop()
		v = nil
	end
end

return TwinHarmony