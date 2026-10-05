local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local v = nil
local BackpackController = {
	States = {}
}

function BackpackController:Update()
	if v then
		v:SetBackpackEnabled(next(BackpackController.States) == nil)
	end
end

function BackpackController.SetEnabled(_, p: string, flag: boolean)
	BackpackController.States[p] = not flag or nil
	BackpackController:Update()
end

function BackpackController.Start(_)
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)
	Synchronizer:Wait(Players.LocalPlayer)
	local Satchel = require(script.Utils.Satchel)
	v = Satchel
	BackpackController:Update()
end

return BackpackController