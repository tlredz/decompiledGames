local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local isServer = RunService:IsServer()
local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
local AchievementGiver = isServer and require(ServerStorage.SharedModules.AchievementGiver)
return {
	MetaInfo = {
		TabText = "Gigi",
		MissionNumber = 5,
		Title = "Toon of the Week - Gigi",
		Description = "MISSION: Fill the capsule by completing quests to unlock limited rewards!",
		Note = "<b>TO DO:</b> Complete all quests in order to claim the Golden Gacha skin!",
		GamepassModule = "Gigi_TOTW_GamepassSkin",
		ToonIcon = "rbxassetid://83513644571335",
		ToonThumbnail = "rbxassetid://137585655770438",
		ThumbnailSizeOverride = UDim2.fromScale(1.332, 0.582),
		ThumbnailPositionOverride = UDim2.fromScale(-0.105, 0.3),
		GamepassRender = "rbxassetid://115430786973179",
		GamepassSketch = "rbxassetid://140618916303500",
		PromoBackground = "rbxassetid://108161022092945",
		GiftType = "GAMEPASS_GIGI_TOTW",
		QuestsBanner = "",
		QuestsBanner2 = "rbxassetid://115363952188438",
		ButtonIcon = "rbxassetid://83513644571335",
		ButtonBackground = "rbxassetid://101333461412931",
		TL = "rbxassetid://124474653983689",
		TR = "rbxassetid://85939519866474",
		BL = "rbxassetid://125750793298563",
		BR = "rbxassetid://73718973791344"
	},
	List = {
		{
			Path = script.Name .. ".Arcade",
			Title = "Player One",
			Description = "Find Gigi's arcade game on Vee's floor.",
			Requirement = 1,
			LayoutOrder = 3,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("VisitStoryTrigger", function(p2, p3)
					if p3.Args[1] ~= "GigiArcadeMachine" then
						return
					end

					print(("[GigiMissions] quest 1 credit: %s (%s) visited %s"):format(
						p2.Name,
						tostring(p3.ToonName),
						"GigiArcadeMachine"
					))
					AchievementGiver:IncrementMission(p2, p.Path, false, 1, p.Requirement)
				end)
			end
		},
		{
			Path = script.Name .. ".Prizes",
			Title = "Prize Winner",
			Description = "Acquire 30 items from Gigi's ability.",
			Requirement = 30,
			LayoutOrder = 2,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("ReceiveItem", function(p2, p3)
					if not (p3.Args[2] == "Ability" and p3.ToonName == "Gigi") then
						return
					end

					AchievementGiver:IncrementMission(p2, p.Path, false, 1, p.Requirement)
				end)
			end
		},
		{
			Path = script.Name .. ".Stash",
			Title = "Finders Keepers",
			Description = "Retrieve 10 items from Twisted Gigi's stash.",
			Requirement = 10,
			LayoutOrder = 1,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("StashRetrieve", function(p2, p3)
					print(("[GigiMissions] quest 3 credit: %s released %s from Twisted Gigi's stash"):format(
						p2.Name,
						(tostring(p3.Args[1]))
					))
					AchievementGiver:IncrementMission(p2, p.Path, false, 1, p.Requirement)
				end)
			end
		}
	},
	Rewards = {
		{
			Type = "Title",
			Value = "GigiFan",
			BonusIchor = 100
		},
		{
			Type = "Sticker",
			Value = "GoldenGigiSticker"
		},
		{
			Type = "Skin",
			Value = "GoldenGacha",
			Image = "rbxassetid://123797537338842"
		}
	}
}