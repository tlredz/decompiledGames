local WingkeeperBarTracking = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local module = require("./PassiveHandler")

local function isDayTime()
	return ReplicatedStorage.world.cycle.Value == "Day"
end

function WingkeeperBarTracking.Morph(p, _, object)
	local config = p.config
	task.spawn(function()
		object:WaitUntilReady()
		p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
			if not (object.active and ReplicatedStorage.world.cycle.Value == "Day") then
				return
			end

			local v = object.fishPosition - object.barPosition
			object.core.rod.CurrentVelocity += math.sign(v) * config.TrackingSpeed * 5 * p2
		end))
	end)
end

setmetatable(WingkeeperBarTracking, module)
return WingkeeperBarTracking