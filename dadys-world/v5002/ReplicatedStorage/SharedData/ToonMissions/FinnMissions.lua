local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local isServer = RunService:IsServer()
local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
local AchievementGiver = isServer and require(ServerStorage.SharedModules.AchievementGiver)
return {
	MetaInfo = {
		TabText = "Finn",
		MissionNumber = 2,
		Title = "Toon of the Week - Finn",
		Description = "MISSION: Fill the capsule by completing quests to unlock limited rewards!",
		Note = "<b>TO DO:</b> Complete all quests in order to claim the Golden Finn skin!",
		GamepassModule = "Finn_TOTW_GamepassSkin",
		ToonIcon = "rbxassetid://132147587363256",
		ToonThumbnail = "rbxassetid://89002893800302",
		GamepassRender = "rbxassetid://98402108744294",
		GamepassSketch = "rbxassetid://132162212777492",
		PromoBackground = "rbxassetid://99068012558001",
		QuestsBanner = "rbxassetid://116744090955829",
		ButtonIcon = "rbxassetid://132147587363256",
		ButtonBackground = "rbxassetid://120436783057585",
		TL = "rbxassetid://121913987973346",
		TR = "rbxassetid://116801195313445",
		BL = "rbxassetid://104936705090886",
		BR = "rbxassetid://139497011084085"
	},
	List = {
		{
			Path = script.Name .. ".Machines",
			Title = "Reeled In",
			Description = "Complete 10 machines in a run with the Fishing Rod trinket equipped.",
			Requirement = 1,
			LayoutOrder = 3,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("ExtractCompleted", function(player, p2)
					if p2.Trinket1 ~= "FishingRod" and p2.Trinket2 ~= "FishingRod" or not player.Character then
						return
					end

					local v = (player.Character:GetAttribute("_QuestExtractionsCompleted") or 0) + 1
					player.Character:SetAttribute("_QuestExtractionsCompleted", v)

					if v == 10 then
						AchievementGiver:IncrementMission(player, p.Path, false, 1, p.Requirement)
					end
				end)
			end
		},
		{
			Path = script.Name .. ".Floor",
			Title = "What a Mess!",
			Description = "Encounter the Ichor Leak Floor Event playing as Finn.",
			Requirement = 1,
			LayoutOrder = 2,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("ExperiencedFloorEvent", function(p2, p3)
					if not (p3.Args[1] == "IchorSpill" and p3.ToonName == "Finn") then
						return
					end

					AchievementGiver:IncrementMission(p2, p.Path, false, 1, p.Requirement)
				end)
			end
		},
		{
			Path = script.Name .. ".Encounter",
			Title = "Face your future",
			Description = "Encounter Twisted Finn 3 times.",
			Requirement = 3,
			LayoutOrder = 1,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("EncounterTwisted", function(p2, p3)
					if (p3.Args[1] or "") ~= "FinnMonster" then
						return
					end

					AchievementGiver:IncrementMission(p2, p.Path, false, 1, p.Requirement)
				end)
			end
		}
	},
	Rewards = {
		{
			Type = "Title",
			Value = "FinnFan",
			BonusIchor = 100
		},
		{
			Type = "Sticker",
			Value = "GoldenFinnSticker"
		},
		{
			Type = "Skin",
			Value = "GoldenFishbowl",
			Image = "rbxassetid://108180717637231"
		}
	}
}