local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local isServer = RunService:IsServer()
local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
local AchievementGiver = isServer and require(ServerStorage.SharedModules.AchievementGiver)
return {
	MetaInfo = {
		TabText = "Tisha",
		MissionNumber = 3,
		Title = "Toon of the Week - Tisha",
		Description = "MISSION: Fill the capsule by completing quests to unlock limited rewards!",
		Note = "<b>TO DO:</b> Complete all quests in order to claim the Golden Tissues skin!",
		GamepassModule = "Tisha_TOTW_GamepassSkin",
		ToonIcon = "rbxassetid://86092870815677",
		ToonThumbnail = "rbxassetid://105278101122787",
		GamepassRender = "rbxassetid://135903541867399",
		GamepassSketch = "rbxassetid://77189843761846",
		PromoBackground = "rbxassetid://129436807583348",
		QuestsBanner = "rbxassetid://102508486959594",
		ButtonIcon = "rbxassetid://86092870815677",
		ButtonBackground = "rbxassetid://129040154042514",
		TL = "rbxassetid://126861052218422",
		TR = "rbxassetid://94239722732665",
		BL = "rbxassetid://75956571325986",
		BR = "rbxassetid://100433923039877"
	},
	List = {
		{
			Path = script.Name .. ".Encounter",
			Title = "Reflection",
			Description = "Encounter Twisted Tisha 5 times.",
			Requirement = 5,
			LayoutOrder = 3,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("EncounterTwisted", function(p2, p3)
					if (p3.Args[1] or "") ~= "TishaMonster" then
						return
					end

					AchievementGiver:IncrementMission(p2, p.Path, false, 1, p.Requirement)
				end)
			end
		},
		{
			Path = script.Name .. ".Stamina",
			Title = "Spick and Span",
			Description = "Restore 300 Stamina with the Feather Duster trinket.",
			Requirement = 300,
			LayoutOrder = 2,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("TriggerTrinket", function(p2, p3)
					if p3.Args[1] ~= "FeatherDuster" then
						return
					end

					local v = tonumber(p3.Args[2]) or 0

					if v <= 0 then
						return
					end

					local v2 = math.ceil(v)
					AchievementGiver:IncrementMission(p2, p.Path, false, v2, p.Requirement)
				end)
			end
		},
		{
			Path = script.Name .. ".Puddles",
			Title = "Tidy Up!",
			Description = "Clean 3 ichor puddles with Tisha's \"Tidy Up!\" ability.",
			Requirement = 3,
			LayoutOrder = 1,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("UseActiveAbility", function(p2, p3)
					if p3.ToonName ~= "Tisha" then
						return
					end

					local v = tonumber(p3.Args[1]) or 0

					if v <= 0 then
						return
					end

					AchievementGiver:IncrementMission(p2, p.Path, false, v, p.Requirement)
				end)
			end
		}
	},
	Rewards = {
		{
			Type = "Title",
			Value = "TishaFan",
			BonusIchor = 100
		},
		{
			Type = "Sticker",
			Value = "GoldenTishaSticker"
		},
		{
			Type = "Skin",
			Value = "GoldenTissues",
			Image = "rbxassetid://101918920210424"
		}
	}
}