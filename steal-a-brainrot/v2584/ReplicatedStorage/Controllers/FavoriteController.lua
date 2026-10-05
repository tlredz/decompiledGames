local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage.Packages
local Synchronizer = require(packages.Synchronizer)
local localPlayer = Players.LocalPlayer
return {
	Start = function(_)
		Synchronizer:WaitAndCall(localPlayer, function(object)
			if object:Get("TimesJoined") <= 1 then
				task.delay(RunService:IsStudio() and 10 or 600, function()
					local AvatarEditorService = game:GetService("AvatarEditorService")
					AvatarEditorService:PromptSetFavorite(game.PlaceId, Enum.AvatarItemType.Asset, true)
				end)
			end
		end)
	end
}