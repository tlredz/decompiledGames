game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerScripts = localPlayer.PlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.packages.Net)
local PlayerController = {}

function PlayerController.SetCFrame(_, cFrame: CFrame)
	local character = localPlayer.Character

	if not character then
		return
	end

	local primaryPart = character.PrimaryPart

	if not primaryPart then
		return
	end

	primaryPart.CFrame = cFrame
end

function PlayerController.ToggleControls(_, flag: boolean)
	local PlayerModule = require(playerScripts:WaitForChild("PlayerModule"))
	local controls = PlayerModule:GetControls()

	if flag == true then
		controls:Enable()
	else
		controls:Disable()
	end
end

return PlayerController