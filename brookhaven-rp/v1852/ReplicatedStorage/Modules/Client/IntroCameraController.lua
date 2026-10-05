local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Permissions = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Permissions"))
local EventFunnelController = require(ReplicatedFirst:WaitForChild("EventFunnelController"))
local IntroCameraMediator = require(ReplicatedFirst:WaitForChild("IntroCameraMediator"))
local IntroCameraController = {}

function IntroCameraController.FrameworkInit()
	EventFunnelController.setSender(function(p, ...)
		Remotes.fireServer(p, ...)
	end)
end

function IntroCameraController.FrameworkStart()
	local localPlayer = Players.LocalPlayer

	if RunService:IsStudio() or not Permissions.hasAdminAccess(localPlayer) then
		return
	end

	local inputBeganConnection = nil
	inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.F5 then
			local skipIntroHandler = IntroCameraMediator.getSkipIntroHandler()

			if skipIntroHandler ~= nil then
				inputBeganConnection:Disconnect()
				skipIntroHandler()
			end
		end
	end)
end

return IntroCameraController