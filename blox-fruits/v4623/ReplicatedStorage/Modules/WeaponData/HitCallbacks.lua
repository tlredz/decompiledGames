local v = nil
local HitCallbacks = {}
task.spawn(function()
	local Util = require(game.ReplicatedStorage.Util)
	v = Util
end)
local v2 = {}

function HitCallbacks.PropelVictim(duration, p)
	return function(p2, p3)
		if v2[p3] then
			return
		end

		v2[p3] = true
		task.delay(duration, function()
			v2[p3] = nil
		end)
		local velocity = p2.HumanoidRootPart.CFrame.LookVector * p
		v.BodyMover.new(p3):Create("BodyVelocity", {
			Priority = -10,
			Velocity = velocity,
			Duration = duration
		})
	end
end

return HitCallbacks