local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local isServer = RunService:IsServer()
local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
local AchievementGiver = isServer and require(ServerStorage.SharedModules.AchievementGiver)
return {
	MetaInfo = {
		TabText = "Brusha",
		MissionNumber = 4,
		Title = "Toon of the Week - Brusha",
		Description = "MISSION: Fill the capsule by completing quests to unlock limited rewards!",
		Note = "<b>TO DO:</b> Complete all quests in order to claim the Golden Bristles skin!",
		GamepassModule = "Brusha_TOTW_GamepassSkin",
		ToonIcon = "rbxassetid://138034666766303",
		ToonThumbnail = "rbxassetid://133640206628258",
		GamepassRender = "rbxassetid://113448559221913",
		GamepassSketch = "rbxassetid://99022021200752",
		PromoBackground = "rbxassetid://78256048183305",
		QuestsBanner = "rbxassetid://72873965107440",
		ButtonIcon = "rbxassetid://138034666766303",
		ButtonBackground = "rbxassetid://109870718498684",
		TL = "rbxassetid://99684330272130",
		TR = "rbxassetid://134528342428298",
		BL = "rbxassetid://139650817786010",
		BR = "rbxassetid://78159972466466"
	},
	List = {
		{
			Path = script.Name .. ".Buffs",
			Title = "Fresh Coat",
			Description = "Complete 20 machine buffs using Artistic Inspiration.",
			Requirement = 20,
			LayoutOrder = 3,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("MachineBuffed", function(p2, p3)
					if p3.ToonName ~= "Brusha" then
						return
					end

					AchievementGiver:IncrementMission(p2, p.Path, false, 1, p.Requirement)
				end)
			end
		},
		{
			Path = script.Name .. ".Debuffed",
			Title = "Touch-Up",
			Description = "Complete a machine debuffed by Twisted Brusha.",
			Requirement = 1,
			LayoutOrder = 2,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("ExtractCompleted", function(p2, p3)
					local arg = p3.Args[2]

					if type(arg) ~= "table" or not arg.BrushaDebuffed then
						return
					end

					AchievementGiver:IncrementMission(p2, p.Path, false, 1, p.Requirement)
				end)
			end
		},
		{
			Path = script.Name .. ".ArtGallery",
			Title = "Gallery Opening",
			Description = "Visit the Art Gallery floor 3 times.",
			Requirement = 3,
			LayoutOrder = 1,
			GameSetup = function(p)
				ActionEvent:ListenForEvent("EnterFloor", function(p2, p3)
					if p3.Args[1] ~= "ArtGallery" then
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
			Value = "BrushaFan",
			BonusIchor = 100
		},
		{
			Type = "Sticker",
			Value = "GoldenBrushaSticker"
		},
		{
			Type = "Skin",
			Value = "GoldenBristles",
			Image = "rbxassetid://78151754135665"
		}
	}
}