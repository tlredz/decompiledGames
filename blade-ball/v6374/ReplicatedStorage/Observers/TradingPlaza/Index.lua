local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Packages.Replion)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Controllers.ShowRoomController)
local IndexController = require(ReplicatedStorage.Controllers.Trading.IndexController)
require(ReplicatedStorage.ServerInfo)
local _ = Players.LocalPlayer
return Observers.observeTag("Index", function(instance)
	local maid = Trove.new()
	local proximityPrompt = instance:FindFirstChildWhichIsA("ProximityPrompt", true)

	if proximityPrompt then
		maid:Add(proximityPrompt.Triggered:Connect(function()
			IndexController:Open()
		end))
	end

	return function()
		maid:Destroy()
	end
end, { workspace })