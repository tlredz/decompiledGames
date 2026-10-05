local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local thread = nil
local KickDetectionController = {}

function KickDetectionController.FrameworkInit() end

function KickDetectionController.FrameworkStart()
	Players.LocalPlayer.Idled:Connect(function(p: number)
		if thread then
			task.cancel(thread)
			thread = nil
		end

		if p < 900 then
			return
		end

		thread = task.delay(120, function()
			Remotes.fireServer("IdleNotificationService", 0)
			thread = nil
		end)
		Remotes.fireServer("IdleNotificationService", p)
	end)
end

return KickDetectionController