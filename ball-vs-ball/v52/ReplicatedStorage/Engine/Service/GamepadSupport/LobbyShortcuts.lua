local Players = game:GetService("Players")
local parentModule = require(script.Parent)
return {
	IsAvailable = function(_)
		local localPlayer = Players.LocalPlayer

		if parentModule.IsBlocked() or localPlayer:GetAttribute("InDuelTable") == true then
			return false
		end

		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
		return humanoid ~= nil and humanoid.Health > 0
	end
}