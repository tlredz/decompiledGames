local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Players2 = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local _1Avata1rEdito1rMessag1e = ReplicatedStorage.RE:WaitForChild("1Avata1rEdito1rMessag1e")
local characterAppearanceInfoAsync = nil

function ClientMessage(p: string)
	NotificationController.NotifyEditor(p)
end

_1Avata1rEdito1rMessag1e.OnClientEvent:Connect(function(p)
	if p == "MaxItems" then
		spawn(function()
			ClientMessage("Limit 4 Items")
		end)
	elseif p == "MaxItemsLeash" then
		spawn(function()
			ClientMessage("Limit 1 Animal")
		end)
	end
end)
pcall(function()
	characterAppearanceInfoAsync = Players2:GetCharacterAppearanceInfoAsync(localPlayer.UserId) or {}

	if characterAppearanceInfoAsync ~= nil and characterAppearanceInfoAsync.bodyColor3s ~= nil then
		characterAppearanceInfoAsync.bodyColor3s = nil
	end
end)