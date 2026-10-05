local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages:WaitForChild("Net"))
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local CutsceneController = require(legacyControllers.CutsceneController)
local PlayerController = require(legacyControllers.PlayerController)
local _ = Players.LocalPlayer
local remoteFunction = Net:RemoteFunction("RequestTeleportCFrame")
local remoteEvent = Net:RemoteEvent("TeleportService/RequestTeleport")
local TeleportController = {
	Request = function(self, p: string)
		task.spawn(function()
			local v = remoteFunction:InvokeServer(nil, p)

			if v then
				CutsceneController:Fade(2, 0.1, 0.1)
				task.wait(1)
				PlayerController:SetCFrame(v)
			end
		end)
	end
}

function TeleportController.Start(_)
	remoteEvent.OnClientEvent:Connect(function(...)
		TeleportController:Request(...)
	end)
end

return TeleportController