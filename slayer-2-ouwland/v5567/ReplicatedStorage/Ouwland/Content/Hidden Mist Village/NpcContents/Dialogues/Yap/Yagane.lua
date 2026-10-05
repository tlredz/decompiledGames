local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Blacksmith

if RunService:IsClient() then
	Blacksmith = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Blacksmith)
end

local content

if Blacksmith ~= nil then
	content = Blacksmith({
		Station = "Hidden Mist"
	}) or nil
end

return {
	Yagane = {
		BeforeRun = function(_, _)
			local data = Utility.GetData(Players.LocalPlayer)
			local inventory = data ~= nil and data.Inventory.Inventory or nil

			if inventory == nil or inventory:FindFirstChild("Crude Iron Ingot") == nil then
				return "Yagane_NoIron"
			end

			return nil
		end,
		Text = "Armoury. I issue first blades. What do you need?",
		Answers = {
			["Forge me a blade"] = "Yagane_Forge",
			Farewell = "Yagane_Bye"
		}
	},
	Yagane_NoIron = {
		Text = "No ingot in your kit. Nothing leaves the rack.",
		Answers = true,
		IfTrue = "Yagane_NoIron2"
	},
	Yagane_NoIron2 = {
		Text = "[Crude Iron]<Color=(.31,.73,1)> is issued at [Final Selection]<Color=(1,.3,.3)>. Not here.",
		Answers = true
	},
	Yagane_Forge = {
		Content = content,
		Text = "Choose a pattern. Same weight, same edge.",
		Answers = {
			Back = "Yagane",
			Farewell = "Yagane_Bye"
		}
	},
	Yagane_Bye = {
		Text = "Take care with Corps property.",
		Answers = 1
	}
}