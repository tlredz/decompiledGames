local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Tool)
local mouse = Players.LocalPlayer:GetMouse()
return {
	Activated = function(object)
		object:FireEvent("EggStaffAttack", mouse.Target)
	end
}