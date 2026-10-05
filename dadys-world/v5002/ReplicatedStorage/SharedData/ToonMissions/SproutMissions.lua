local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local isServer = RunService:IsServer()
local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
local AchievementGiver = isServer and require(ServerStorage.SharedModules.AchievementGiver)
return {
	MetaInfo = {
		TabText = "Sprout",
		MissionNumber = 1,
		Title = "Toon of the Week - Sprout",
		Description = "MISSION: Fill the capsule by completing quests to unlock limited rewards!",
		Note = "<b>TO DO:</b> Complete all quests in order to claim the Golden Sprout skin!",
		GamepassModule = "Sprout_TOTW_GamepassSkin",
		ToonIcon = "rbxassetid://111767803170367",
		ToonThumbnail = "rbxassetid://102684646768530",
		GamepassRender = "rbxassetid://120754899928505",
		GamepassSketch = "rbxassetid://91966019453223",
		ButtonIcon = "rbxassetid://91903385739812",
		ButtonBackground = "rbxassetid://110608371123541"
	},
	List = {
		{
			Path = script.Name .. ".Trinket",
			Title = "Unsavory Situation",
			Description = "Activate the Savory Charm Trinket on Floor 10 or higher.",
			Requirement = 1,
			LayoutOrder = 3,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("TriggerTrinket", function(p2, p3)
					if p3.Args[1] ~= "Savory Charm" or p3.FloorNumber < 10 then
						return
					end

					AchievementGiver:IncrementMission(p2, p.Path, false, 1, p.Requirement)
				end)
			end
		},
		{
			Path = script.Name .. ".Floor",
			Title = "We're here!",
			Description = "Complete floor 10 as Sprout or with at least 1 Sprout in your run.",
			Requirement = 1,
			LayoutOrder = 2,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("CompleteFloor", function(p2, data)
					if data.FloorNumber < 10 then
						return
					end

					local v = data.ToonName == "Sprout"

					if not v then
						for _, v3 in pairs(data.PlayingWith) do
							if v3 ~= "Sprout" then
								continue
							end

							v = true
							break
						end
					end

					if not v then
						return
					end

					AchievementGiver:IncrementMission(p2, p.Path, false, 1, p.Requirement)
				end)
			end
		},
		{
			Path = script.Name .. ".Encounter",
			Title = "Face your future",
			Description = "Encounter Twisted Sprout 3 times.",
			Requirement = 3,
			LayoutOrder = 1,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("EncounterTwisted", function(p2, p3)
					if (p3.Args[1] or "") ~= "SproutMonster" then
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
			Value = "SproutFan",
			BonusIchor = 100
		},
		{
			Type = "Sticker",
			Value = "GoldenSproutSticker"
		},
		{
			Type = "Skin",
			Value = "GoldenBerry",
			Image = "rbxassetid://134350272384939"
		}
	}
}