require(game.ReplicatedStorage.NPCManager.Types)
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local Config = {
	ANIMATIONS_DISABLED_ATTRIBUTE = "NPCAnimationsDisabled",
	HIDDEN_ATTRIBUTE = "NPCHidden",
	NPC_LIMB_PARTS = {
		"UpperTorso",
		"LowerTorso",
		"RightUpperArm",
		"RightLowerArm",
		"RightHand",
		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand",
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot"
	},
	QuestInfo = {
		QUEST = {
			Color = Color3.fromRGB(255, 230, 0),
			Text = "QUEST",
			Type = 1
		},
		SHOP = {
			Color = Color3.fromRGB(0, 255, 0),
			Text = "SHOP",
			Type = 2
		},
		INVENTORY = {
			Color = Color3.fromRGB(255, 0, 255),
			Text = "INVENTORY",
			Type = 3
		},
		MISC = {
			Color = Color3.fromRGB(255, 255, 255),
			Text = "MISC.",
			Type = 4
		},
		ROLL = {
			Color = Color3.fromRGB(75, 255, 165),
			Text = "ROLL",
			Type = 5
		}
	},
	CullingDistance = 500
}
local highlight = Instance.new("Highlight")
highlight.FillTransparency = 0.7
highlight.FillColor = Color3.new(1, 1, 1)
highlight.OutlineTransparency = 0
highlight.Parent = game.Lighting
Config.Highlight = highlight
Config.IdleList = {
	"18884840386",
	"18884841590",
	"18884842887",
	"18884844203",
	"110180049276123"
}
Config.Actions = {
	Explain = "18884847573",
	Observe = "18884849844",
	Negative = "18884851323",
	Positive = "18884853165",
	Welcome = "18893533079",
	Bye = "18900892919",
	Pain = "18494061159",
	Scared = "72456085933288",
	Floating = "123413284963009",
	Injured = "98380961254067"
}
Config.NPCInfoRegistered = Signal.new()
return Config