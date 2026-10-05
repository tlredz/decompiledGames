local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.ServerInfo)
local elementalServer = v.isElementalServer()
local v2 = not (v.isTutorialServer() or v.isNewPlayerLobbyServer())

if not v.isTestGame() then
	RunService:IsStudio()
end

return {
	Modes = {
		NoAbilityFFA = {
			DisplayName = "No Abilities",
			DisabledInTraining = true
		},
		BonusLifeFFA = {
			DisplayName = "2 Lives",
			DisabledInTraining = true
		},
		FFA = {
			DisplayName = "Classic"
		},
		["2Teams"] = {
			DisplayName = "2 Teams"
		},
		["4Teams"] = {
			DisplayName = "4 Teams"
		},
		Randomizer = {
			DisplayName = "Randomizer",
			DisabledInTraining = true
		},
		Duo = {
			DisplayName = "Duos",
			DisabledInTraining = true
		},
		OneAbility = {
			DisplayName = "One Ability",
			DisabledInTraining = true
		},
		RobloxClassic = {
			DisplayName = "1x1x1x1",
			DisabledInTraining = true
		},
		Dragon = {
			DisplayName = "Dragon",
			DisabledInTraining = true
		},
		["2Ball"] = {
			DisplayName = "2 Ball"
		},
		RedLightGreenLight = {
			DisplayName = "Red Light Green Light",
			DisabledInTraining = true
		},
		Tag = {
			DisplayName = "Tag!",
			DisabledInTraining = true
		},
		AbilityGame = {
			DisplayName = "Ability Game",
			DisabledInTraining = true
		},
		Hovergoal = {
			DisplayName = "Hovergoal",
			DisabledInTraining = true
		},
		AbilityBlock = {
			DisplayName = "Ability Block",
			DisabledInTraining = true
		},
		Rebound = {
			DisplayName = "Rebound!",
			DisabledInTraining = true
		},
		Soccer = {
			DisplayName = "Soccer",
			DisabledInTraining = true
		}
	},
	Chances = {
		{
			FFA = 100
		},
		{
			["2Teams"] = elementalServer and 100 or v2 and 70 or 100,
			NoAbilityFFA = elementalServer and 0 or v2 and 30 or 0
		},
		{
			["4Teams"] = elementalServer and 100 or v2 and 35 or 100,
			Randomizer = elementalServer and 0 or v2 and 30 or 0
		}
	}
}