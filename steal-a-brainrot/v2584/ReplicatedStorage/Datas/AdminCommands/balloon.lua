local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local count = 0
return {
	name = "balloon",
	icon = "rbxassetid://122227641631583",
	cooldown = 30,
	description = "You will jump higher for 15 seconds!",
	effects = {
		Victim = function()
			local v = ServerData.IsJumpLTMServer() and 1 or 0.15
			count += 1
			local v2 = count
			workspace.Gravity = v * 196.2
			task.delay(15, function()
				if v2 == count then
					workspace.Gravity = 196.2
				end
			end)
		end
	}
}