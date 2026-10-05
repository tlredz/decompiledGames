local class = {}
class.__index = class
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
require(ReplicatedStorage:WaitForChild("Director"))
local localPlayer = Players.LocalPlayer

function class:Init()
	self.FixThread = task.spawn(function()
		while true do
			task.wait(1)
			local playerFromCharacter = Players:GetPlayerFromCharacter(self.Instance.Parent and self.Instance.Parent.Parent)

			if not playerFromCharacter then
				continue
			end

			for _, proximityPrompt in self.ProximityPrompts do
				if localPlayer == playerFromCharacter then
					proximityPrompt.MaxActivationDistance = 0
				elseif playerFromCharacter:HasTag("Ally" .. localPlayer.Name) and localPlayer:HasTag("Ally" .. playerFromCharacter.Name) or playerFromCharacter.Team == Teams.Marines and localPlayer.Team == Teams.Marines then
					proximityPrompt.MaxActivationDistance = 10
				else
					proximityPrompt.MaxActivationDistance = 0
				end
			end
		end
	end)
end

function class.Destroy(p)
	if p.FixThread then
		pcall(task.cancel, p.FixThread)
	end
end

return {
	new = function(instance, _)
		return (setmetatable({
			Instance = instance,
			ProximityPrompts = {},
			FixThread = nil
		}, class))
	end,
	ancestor = workspace
}