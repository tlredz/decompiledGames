local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
local formatted = `[2,500]<Color=(1,1,1)> [#]<img={BunchaIcons.WenRaw}>`

local function rumourOpen()
	local data = Utility.GetData(Players.LocalPlayer)
	local worldEvents

	if data ~= nil then
		worldEvents = data:FindFirstChild("WorldEvents")
	end

	return worldEvents ~= nil and worldEvents:FindFirstChild("WarFansClue_2") ~= nil and worldEvents:FindFirstChild("WarFansClue_4") == nil
end

local function exit()
	if rumourOpen() then
		return "Retsu_Rumour"
	end

	return nil
end

return {
	["Old Trapper Retsu"] = {
		Text = "You feel this cold? [Cloth don't stop it.]<Color=(.6,.6,1)>",
		Answers = true,
		IfTrue = "Retsu_2"
	},
	Retsu_2 = {
		Text = "Thirty years I've trapped this valley. Wore the thickest fur there is. Cold still got through.",
		Answers = true,
		IfTrue = "Retsu_3"
	},
	Retsu_3 = {
		Text = `Saw one thing the cold don't touch. That was years back, down by {nameTag("Butterfly Estate")}.`,
		Answers = true,
		IfTrue = "Retsu_4"
	},
	Retsu_4 = {
		Text = "There's a fall down there that has never once frozen over.",
		Answers = true,
		IfTrue = "Retsu_4b"
	},
	Retsu_4b = {
		Text = "I got in behind it, out of the weather. There's a cave.",
		Answers = true,
		IfTrue = "Retsu_5"
	},
	Retsu_5 = {
		Text = "Something's standing in the ice inside it. Big, and white, and not one bit of frost gathered on it.",
		Answers = true,
		IfTrue = "Retsu_6"
	},
	Retsu_6 = {
		Text = "The folk who were here before me called it the [\"White Terror\"]<Color=(.6,.6,1)>.",
		Answers = {
			Close = exit,
			["Is it alive?"] = "Retsu_Alive",
			["Have you been back?"] = "Retsu_Back",
			["Lantern on your belt"] = "RetsuLanternEntry"
		}
	},
	Retsu_Alive = {
		Text = "Couldn't say. Ice like that don't let a thing rot.",
		Answers = true,
		IfTrue = "Retsu_Alive2"
	},
	Retsu_Alive2 = {
		Text = "Its chest is open, though. Whatever beat in there was cut out and carried off.",
		Answers = true,
		IfTrue = "Retsu_Riddle"
	},
	Retsu_Back = {
		Text = "Once was enough. I've thought on it every winter since, sat here freezing.",
		Answers = true,
		IfTrue = "Retsu_Riddle"
	},
	Retsu_Riddle = {
		Text = "The old folk had a line about it. Said it only wakes for [a heart frozen by eternal winter.]<Style=Fade,Color=(.8,.7,1)>",
		Answers = {
			Close = exit,
			["Where would I find that?"] = "Retsu_Where"
		}
	},
	Retsu_Where = {
		Text = "Not in my traps. A thing like that ends up with them that buy and sell.",
		Answers = true,
		IfTrue = "Retsu_Done"
	},
	Retsu_Done = {
		Text = "That's the whole of what I know. I trap animals, not riddles.",
		Answers = {
			Close = exit,
			["Lantern on your belt"] = "RetsuLanternEntry"
		}
	},
	Retsu_Lantern = {
		Text = "This one ain't got oil in it.",
		Answers = {
			Close = exit,
			["What lights it?"] = "Retsu_Lantern_2"
		}
	},
	Retsu_Lantern_2 = {
		Text = "It grows down in the cave. Small caps, close to the ground.",
		Answers = true,
		IfTrue = "Retsu_Lantern_3"
	},
	Retsu_Lantern_3 = {
		Text = "Saw it shine good one time.",
		Answers = true,
		IfTrue = "Retsu_Lantern_3b"
	},
	Retsu_Lantern_3b = {
		Text = "My oil was gone by then. Had been gone a while.",
		Answers = {
			Close = exit,
			["Where was that?"] = "Retsu_Lantern_Price"
		}
	},
	Retsu_Lantern_Price = {
		Text = `I can give you the place. Costs you {formatted}.`,
		Answers = {
			Close = exit,
			["Pay him"] = "RetsuTellFoxfire"
		}
	},
	Retsu_Lantern_Told = {
		Text = "Southeast, then up. There's a way into the cave near the top.",
		Answers = true,
		IfTrue = "Retsu_Lantern_Told2"
	},
	Retsu_Lantern_Told2 = {
		Text = "Filled my pouch there. Left my old lamp behind.",
		Answers = true,
		IfTrue = exit
	},
	Retsu_Lantern_Daylight = {
		Text = "Ask me after dark.",
		Answers = true,
		IfTrue = exit
	},
	Retsu_Lantern_Lit = {
		Text = "Put that lamp away if you're asking about mine.",
		Answers = true,
		IfTrue = exit
	},
	Retsu_Lantern_Broke = {
		Text = `Not enough coin. Come back with {formatted}.`,
		Answers = true,
		IfTrue = exit
	},
	Retsu_Lantern_Quiet = {
		Text = "Ask me another time.",
		Answers = true,
		IfTrue = exit
	},
	Retsu_Lantern_Wearing = {
		Text = "That's mine. The one I left in the cave.",
		Answers = true,
		IfTrue = "Retsu_Lantern_Wearing2"
	},
	Retsu_Lantern_Wearing2 = {
		Text = "Thirty years I meant to go back for it. Never did.",
		Answers = true,
		IfTrue = exit
	},
	Retsu_Rumour = {
		Text = "Woman come through here. Hands wrapped. Asked me where the snow lay deepest.",
		Answers = {
			Close = "",
			["Where did she go?"] = "WarFansClue3"
		}
	},
	Retsu_Rumour2 = {
		Text = "Pulled her out of a drift the winter before. She went back into the same one.",
		Answers = true,
		IfTrue = "Retsu_Rumour3"
	},
	Retsu_Rumour3 = {
		Text = "Last I saw her she was headed up to the settlement. Somebody up there sold her a coat.",
		Answers = true
	}
}