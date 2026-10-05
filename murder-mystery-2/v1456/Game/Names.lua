local localPlayer = game.Players.LocalPlayer
local game2 = script.Parent:WaitForChild("Game")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrentRoundClient = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))
local mouse = localPlayer:GetMouse()
local targetCodeName = game2.TargetCodeName
local CodeImages = require(game.ReplicatedStorage.CodeImages)
local v = game.PlaceId == 333740520 or game.PlaceId == 335132309

if not v then
	return
end

function Update(_: number)
	pcall(function()
		local target = mouse.Target

		if target == nil or not v then
			targetCodeName.Visible = false
		else
			local playerFromCharacter = game.Players:GetPlayerFromCharacter(target.Parent)

			if playerFromCharacter == nil then
				targetCodeName.Visible = false
			elseif CurrentRoundClient.PlayerData[playerFromCharacter.Name] == nil or CurrentRoundClient.PlayerData[localPlayer.Name] == nil then
				targetCodeName.Visible = false
			elseif CurrentRoundClient.PlayerData[localPlayer.Name].Dead == false and target.Parent.UpperTorso.Transparency == 0 then
				targetCodeName.Image = CodeImages[CurrentRoundClient.PlayerData[playerFromCharacter.Name].CodeName]
				targetCodeName.ImageColor3 = CurrentRoundClient.PlayerData[playerFromCharacter.Name].Color.Color
				targetCodeName.Visible = true
			end
		end
	end)
end

local RunService = game:GetService("RunService")
RunService.PreSimulation:Connect(Update)