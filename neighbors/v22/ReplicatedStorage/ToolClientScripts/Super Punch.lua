local SuperPunch = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.Tool)
local _ = Players.LocalPlayer
local mouse = Players.LocalPlayer:GetMouse()

function SuperPunch.Initialize(_) end

function SuperPunch.Activated(object)
	object:FireEvent("Fire", mouse.Target)
end

function SuperPunch.Equipped(_) end

function SuperPunch.Unequipped(_) end

function SuperPunch.Destroyed(_) end

return SuperPunch