local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local extinguishParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ExtinguishParticles")
return function(cFrame)
	local clone = extinguishParticles:Clone()
	clone.CFrame = cFrame
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 10)
	Utility:CreateSound("rbxassetid://16812185839", 0.75, 1.3 + 0.2 * math.random(), clone, true)
	Utility:CreateSound("rbxassetid://16812389263", 0.75, 1.3 + 0.2 * math.random(), clone, true)
	Utility:PlayParticles(clone.Attachment)
end