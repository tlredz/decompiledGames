local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Refinement

if RunService:IsClient() then
	Refinement = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Refinement)
end

return {
	["Refiner Hagane"] = {
		Text = "Steel remembers every strike. Bring me your weapons and rods, and I will draw more out of them.",
		Answers = true,
		IfTrue = "Hagane_Forge"
	},
	Hagane_Forge = {
		Content = Refinement ~= nil and Refinement() or nil,
		Text = "Pick a piece, and we will see what the forge says.",
		Answers = {
			Farewell = "Hagane_Bye"
		}
	},
	Hagane_Bye = {
		Text = "Keep your edge, slayer.",
		Answers = 1
	}
}