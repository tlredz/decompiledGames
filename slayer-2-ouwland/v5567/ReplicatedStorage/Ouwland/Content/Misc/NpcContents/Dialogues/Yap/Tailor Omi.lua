local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return {
	["Tailor Omi"] = {
		BeforeRun = function(_, _)
			local data = Utility.GetData(Players.LocalPlayer)
			local inventory

			if data ~= nil then
				inventory = data.Inventory.Inventory
			end

			if inventory == nil then
				return nil
			end

			if inventory:FindFirstChild("Firstlight Haori Schematic") ~= nil then
				return "Haori_Done"
			end

			if inventory:FindFirstChild("Lost Outfit") == nil then
				return nil
			end

			return "Haori_Offer"
		end,
		Text = "Every stitch I know, I learned off a dead man's coat.",
		Answers = true,
		IfTrue = "Haori_2"
	},
	Haori_2 = {
		Text = "There is one seam I never learned. It only turns up on clothes that came back from somewhere they should not have been.",
		Answers = {
			Close = ""
		}
	},
	Haori_Offer = {
		Text = "Those clothes. Set them on the table. The seam is in there, under all of that.",
		Answers = {
			["Hand them over"] = "HaoriTrade",
			["Not yet"] = ""
		}
	},
	Haori_Given = {
		Text = "Fifty years, and there it was. I have put it on paper for you, seam by seam. Find a smith for the rest.",
		Answers = {
			Close = ""
		}
	},
	Haori_NoPiece = {
		Text = "My eyes are old, but not that old. Those are not the clothes.",
		Answers = true
	},
	Haori_Done = {
		Text = `You carry the {Utility.NameTag("drawings")}. My hands would not manage them twice.`,
		Answers = {
			Close = ""
		}
	}
}