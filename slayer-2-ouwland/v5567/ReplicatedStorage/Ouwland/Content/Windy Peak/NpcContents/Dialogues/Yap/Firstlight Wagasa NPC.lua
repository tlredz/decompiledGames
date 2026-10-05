local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
return {
	["Wagasa Maker Genzo"] = {
		BeforeRun = function(_, _)
			local data = Utility.GetData(Players.LocalPlayer)
			local worldEvents

			if data ~= nil then
				worldEvents = data:FindFirstChild("WorldEvents") or nil
			end

			if worldEvents ~= nil and worldEvents:FindFirstChild("FirstlightWagasa_Schematic") ~= nil then
				return "Wagasa_Done"
			end

			local inventory = data ~= nil and data.Inventory.Inventory or nil

			if inventory == nil or inventory:FindFirstChild("Damascus Bladed Wagasa") == nil then
				return "Wagasa_NoWagasa"
			end

			return nil
		end,
		Text = "You pushed a rock the whole way up here. Most of them turn back at the gates.",
		Answers = true,
		IfTrue = "Wagasa_2"
	},
	Wagasa_2 = {
		Text = "Nobody comes this high. That was rather the point of me stopping here.",
		Answers = {
			["What is that umbrella?"] = "Wagasa_3",
			Close = ""
		}
	},
	Wagasa_3 = {
		Text = `Mine. Thirty ribs of hammered {nameTag("scrap")}, folded until they are thin as paper, under a canopy of oiled {nameTag("silk")}.`,
		Answers = {
			["How is one made?"] = "Wagasa_4",
			Close = ""
		}
	},
	Wagasa_4 = {
		Text = "Slowly. Every rib comes off the same stone. One ground short and the whole thing opens crooked, and it never sits true again after.",
		Answers = true,
		IfTrue = "Wagasa_5"
	},
	Wagasa_5 = {
		Text = "The silk goes on wet. It draws tight as it dries and pulls the frame straight for you, if you set the ribs honestly.",
		Answers = {
			["And the blade?"] = "Wagasa_6"
		}
	},
	Wagasa_6 = {
		Text = "You do not forge a new one. You draw the blade off the wagasa you already carry and set it in last, once the canopy is on.",
		Answers = {
			["Could I make one?"] = "Wagasa_7",
			Close = ""
		}
	},
	Wagasa_7 = {
		Text = "You carried a rock up a mountain to ask me. I'd say you could. Let me put the order of it on paper while it is in my head.",
		Answers = {
			["Take the drawings"] = "WagasaTakeSchematic",
			["Not yet"] = ""
		}
	},
	Wagasa_Given = {
		Text = "Take it to a smith with the scrap, the silk, and the old umbrella you mean to replace. He will want coin for his trouble.",
		Answers = {
			Close = ""
		}
	},
	Wagasa_NoWagasa = {
		Text = `Come back when you carry a {nameTag("Damascus")} wagasa. I have nothing to teach a man holding a market piece.`,
		Answers = {
			Close = ""
		}
	},
	Wagasa_Done = {
		Text = `You have the {nameTag("drawings")} already. I only wrote them once.`,
		Answers = {
			Close = ""
		}
	}
}