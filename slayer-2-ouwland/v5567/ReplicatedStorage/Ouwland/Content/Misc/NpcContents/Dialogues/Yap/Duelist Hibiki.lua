local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return {
	["Duelist Hibiki"] = {
		BeforeRun = function(_, _)
			local data = Utility.GetData(Players.LocalPlayer)
			local inventory

			if data ~= nil then
				inventory = data.Inventory.Inventory
			end

			if inventory == nil or inventory:FindFirstChild("Firstlight Sound Cleavers Schematic") == nil then
				return nil
			end

			return "Duel_Done"
		end,
		Text = "Hear that? No? Then nobody has drawn on me yet today. Stand there and listen a while.",
		Answers = true,
		IfTrue = "Duel_2"
	},
	Duel_2 = {
		Text = "These cleavers were mine, and they stay mine until somebody makes me put them down. One on one, nobody steps in, nobody steps out. Just you, me, and the noise.",
		Answers = {
			["Challenge him"] = "CleaverChallenge",
			["Not yet"] = ""
		}
	},
	Duel_Done = {
		Text = `You carry the {Utility.NameTag("drawings")}. I drew them once, and once was loud enough. Go and have them made.`,
		Answers = {
			Close = ""
		}
	}
}