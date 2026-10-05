local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local v = {}
local FriendController = {}

function FriendController.AddFriendRequest(p: number, p2: string)
	v[p] = p2
end

function FriendController.FrameworkInit() end

function FriendController.FrameworkStart()
	Players.PlayerRemoving:Connect(function(player)
		v[player.UserId] = nil
	end)
	StarterGui:GetCore("PlayerFriendedEvent").Event:Connect(function(p)
		local trigger = v[p.UserId]

		if trigger == nil then
			return
		end

		v[p.UserId] = nil
		TelemetryController.SendClientInteraction("acceptFriendRequest", {
			receiverID = p.UserId,
			trigger = trigger
		})
	end)
end

return FriendController