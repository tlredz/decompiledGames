local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileFlags = require(ReplicatedStorage.Modules.Shared.PlayerData.ProfileFlags)
local ProfileFlagController = require(ReplicatedStorage.Modules.Client.PlayerData.ProfileFlagController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local PopupQueue = require(ReplicatedStorage.Modules.Client.UI.PopupQueue)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local CompensationController = {}

function CompensationController.FrameworkInit() end

function CompensationController.FrameworkStart()
	GamepassController.WaitForGamepasses()
	PopupQueue.RegisterHandler("MainGUIHandler", "VehicleFacesUnlockedPanel", function() end)

	if GamepassController.IsOwned(Gamepasses.FACES_UNLOCKED) and not ProfileFlagController.IsCompleted(ProfileFlags.FACES_UNLOCKED_COMPENSATION_03102026) then
		PopupQueue.Dispatch("MainGUIHandler", "VehicleFacesUnlockedPanel")
	end
end

return CompensationController