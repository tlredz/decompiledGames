local parent = script.Parent
local background = parent.Background
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
PeodizService.HeartbeatWait({
	Time = 300
}, function(_)
	if not parent.Parent then
		return true
	end

	if background.Rotation <= -360 then
		background.Rotation = 0
	end

	background.Rotation -= 1
end)