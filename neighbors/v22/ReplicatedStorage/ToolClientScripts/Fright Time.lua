local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.Tool)
local Utility = require(ReplicatedStorage.Modules.Utility)
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
return {
	Activated = function(object)
		local model = mouse.Target:FindFirstAncestorWhichIsA("Model")
		local playerFromCharacter = Players:GetPlayerFromCharacter(model)

		if Utility:IsToolCooldown(localPlayer, object.Tool) or not playerFromCharacter or playerFromCharacter == localPlayer or playerFromCharacter:GetAttribute("Protected") or playerFromCharacter:GetAttribute("Safezone") then
			return
		end

		ReplicatedStorage.Assets.Tools.Beep:Play()
		object:FireEvent("Scare", model)
	end
}