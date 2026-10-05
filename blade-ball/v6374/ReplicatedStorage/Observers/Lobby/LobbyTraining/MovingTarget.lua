local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Observers = require(ReplicatedStorage.Packages.Observers)
local MovingTargets = require(ReplicatedStorage.Shared.LobbyTraining.MovingTargets)

local function easeInOutSine(p: number)
	return -(math.cos(3.141592653589793 * p) - 1) * 0.5
end

return Observers.observeTag("LobbyTrainingMovingTarget", function(instance)
	local movingTargets = MovingTargets(instance)
	local postSimulationConnection

	if pcall(movingTargets) then
		postSimulationConnection = RunService.PostSimulation:Connect(function()
			local character = localPlayer.Character

			if character and character.Parent ~= workspace.Dead then
				return
			end

			instance:PivotTo(movingTargets())
		end)
	else
		postSimulationConnection = nil
	end

	return function()
		if postSimulationConnection then
			postSimulationConnection:Disconnect()
			postSimulationConnection = nil
		end
	end
end, { workspace })