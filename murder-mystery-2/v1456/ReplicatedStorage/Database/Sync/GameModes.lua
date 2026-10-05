local v = game.GameId == 119460199
local currentEventEnding = workspace:GetAttribute("CurrentEventEnding")
local v2

if workspace:GetAttribute("CurrentEvent") == "Halloween" then
	v2 = not currentEventEnding
else
	v2 = false
end

local GameModes = {
	Standard = {
		DisplayName = "Standard",
		Image = "rbxassetid://14148051887",
		PlaceID = 142823291,
		TestID = 188331334,
		Popular = true,
		PlayerCount = 0,
		Description = { "• Standard MM2 Gamemode", "• All cosmetics and avatars enabled", "• Full XP and coins" },
		Order = 10
	},
	Disguises = {
		DisplayName = "Disguises",
		Image = "rbxassetid://14156478096",
		PlaceID = 335132309,
		TestID = 333740520,
		PlayerCount = 0,
		Description = {
			"• Standard MM2 Gamemode",
			"• Player avatars are disguised",
			"• Some cosmetics are disabled",
			"• Full XP and coins"
		},
		Order = 20
	},
	Assassin = {
		DisplayName = "Assassin",
		Image = "rbxassetid://14167876198",
		PlaceID = 636649648,
		TestID = 594100598,
		PlayerCount = 0,
		Description = {
			"• Custom game mode",
			"• All players get a knife, hunt down your target",
			"• Alternate XP, full Coins",
			"• All cosmetics and avatars enabled"
		},
		Order = 30
	},
	VampireHunt = {
		DisplayName = "Vampire Hunt",
		Image = "rbxassetid://117092830478669",
		PlaceID = 73210641948512,
		TestID = 124544126418603,
		LimitedTime = true,
		PlayerCount = 0,
		Description = {
			"• 24 player servers",
			"• Teams of 3 vampires and 3 hunters",
			"• Vampires get custom perk",
			"• Full XP and coins"
		},
		Order = 40,
		Hidden = true
	}
}

if v2 then
	GameModes.VampireHunt.Hidden = false
end

if v then
	for _, v3 in GameModes do
		v3.PlaceID = v3.TestID
	end
end

local function isGameMode(p: string)
	if GameModes[p] then
		return game.PlaceId == GameModes[GameModes].PlaceID
	end
end

return GameModes