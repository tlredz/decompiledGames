local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag

local function holdsToll(inventory)
	for _, childName in { "Crustadon", "Krathulon" } do
		local child = inventory:FindFirstChild(childName)
		local amount

		if child ~= nil then
			amount = child:FindFirstChild("Amount") or nil
		end

		if child == nil or (amount == nil and 1 or amount.Value or 1) < 2 then
			return false
		end
	end

	return true
end

return {
	["Legendary Fisherman Isao"] = {
		BeforeRun = function(_, _)
			local data = Utility.GetData(Players.LocalPlayer)
			local inventory

			if data ~= nil then
				inventory = data.Inventory.Inventory or nil
			end

			if inventory == nil or inventory:FindFirstChild("Drowned Lure") == nil or inventory:FindFirstChild("Legendary Fishing Rod") ~= nil then
				return "Isao_Silent"
			end

			local worldEvents = data:FindFirstChild("WorldEvents")

			if worldEvents ~= nil and worldEvents:FindFirstChild("DrownedLine_Paid") ~= nil then
				return "Isao_Paid"
			end

			if holdsToll(inventory) then
				return nil
			end

			if inventory:FindFirstChild("Crustadon") == nil and inventory:FindFirstChild("Krathulon") == nil then
				return "Isao_Owed"
			end

			return "Isao_Short"
		end,
		Text = "That's my lure in your hand.",
		Answers = true,
		IfTrue = "Isao_2"
	},
	Isao_2 = {
		Text = "I went down with it, twenty years back. Never came up.",
		Answers = true,
		IfTrue = "Isao_3"
	},
	Isao_3 = {
		Text = `And you've brought what took me. Two {nameTag("Crustadon")}, two {nameTag("Krathulon")}.`,
		Answers = {
			Close = "",
			["What do you want from me?"] = "Isao_4"
		}
	},
	Isao_4 = {
		Text = "Nothing from you. There's a debt to the water in my name, and twenty years haven't paid it.",
		Answers = true,
		IfTrue = "Isao_5"
	},
	Isao_5 = {
		Text = "Settle it, and I'll tell you where my rod went down.",
		Answers = {
			Close = "",
			["Give the fish to the water"] = "IsaoTakeToll"
		}
	},
	Isao_Toll = {
		Text = "It's done. Twenty years.",
		Answers = true,
		IfTrue = "Isao_Toll2"
	},
	Isao_Toll2 = {
		Text = "My rod's on the bottom, downriver of where I worked. Past two drops.",
		Answers = true,
		IfTrue = "Isao_Toll3"
	},
	Isao_Toll3 = {
		Text = "There's a tree grown out over the ledge there. That's where I went in.",
		Answers = true,
		IfTrue = "Isao_Toll4"
	},
	Isao_Toll4 = {
		Text = "Raise it and keep it. I've no hands left for a rod.",
		Answers = true,
		IfTrue = "Isao_Toll5"
	},
	Isao_Toll5 = {
		Text = "The river knows my lure.",
		Answers = true,
		IfTrue = "Isao_Toll6"
	},
	Isao_Toll6 = {
		Text = "But the rod won't rise for someone trying to catch a fish. That was always my trouble.",
		Answers = true,
		IfTrue = "Isao_Toll7"
	},
	Isao_Toll7 = {
		Text = "Anything you pull up out there is the water telling you no. Anything at all.",
		Answers = true
	},
	Isao_Short = {
		Text = "That's my lure in your hand.",
		Answers = true,
		IfTrue = "Isao_Short2"
	},
	Isao_Short2 = {
		Text = "Two of each. That's what took me, and that's what the water's owed.",
		Answers = true
	},
	Isao_Owed = {
		Text = "That's my lure in your hand.",
		Answers = true,
		IfTrue = "Isao_Owed2"
	},
	Isao_Owed2 = {
		Text = "I went down with it, twenty years back. Never came up.",
		Answers = true,
		IfTrue = "Isao_Owed3"
	},
	Isao_Owed3 = {
		Text = `Two {nameTag("Crustadon")}, two {nameTag("Krathulon")}. That's what took me, and that's what the water's owed.`,
		Answers = true
	},
	Isao_Paid = {
		Text = "The water's been paid, and I've nothing new to say.",
		Answers = true,
		IfTrue = "Isao_Paid2"
	},
	Isao_Paid2 = {
		Text = "Downriver of where I worked. Past two drops, the tree over the ledge. It hasn't moved.",
		Answers = true
	},
	Isao_Silent = {
		Text = "...",
		Answers = 1
	}
}