local now = os.clock()

local function provide(p: number)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local ClientTimingsController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("Telemetry"):WaitForChild("ClientTimingsController"))
	ClientTimingsController.Provide("GameLoaded", now, p)
end

if game:IsLoaded() then
	task.spawn(provide, os.clock())
else
	game.Loaded:Connect(function()
		task.spawn(provide, os.clock())
	end)
end