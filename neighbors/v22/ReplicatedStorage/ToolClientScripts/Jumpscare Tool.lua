local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local mouse = Players.LocalPlayer:GetMouse()
require(ReplicatedStorage.Modules.Tool)
return {
	Activated = function(object)
		local playerFromCharacter = Players:GetPlayerFromCharacter(mouse.Target:FindFirstAncestorWhichIsA("Model"))

		if not playerFromCharacter then
			return
		end

		script.beep:Play()
		object:FireEvent("JumpscarePlayer", playerFromCharacter)
	end
}