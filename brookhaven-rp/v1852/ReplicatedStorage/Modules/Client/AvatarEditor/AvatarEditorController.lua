local AvatarEditorController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local AvatarEditorRequests = require(ReplicatedStorage.Modules.Shared.Game.AvatarEditorRequests)
AvatarEditorController.OnResetCharacterAppearance = Signal.new()
AvatarEditorController.OnSearchStarted = Signal.new()

function AvatarEditorController.ResetCharacterAppearance()
	Remotes.fireServer(AvatarEditorRequests.RESET_CHARACTER_APPEARANCE)
end

function AvatarEditorController.InitializeCharacter()
	Remotes.fireServer(AvatarEditorRequests.INITIALIZE_CHARACTER)
end

function AvatarEditorController.FrameworkInit() end

function AvatarEditorController.FrameworkStart()
	local localPlayer = Players.LocalPlayer
	localPlayer.CharacterRemoving:Connect(function()
		if not localPlayer.Character then
			localPlayer.CharacterAdded:Wait()
		end

		AvatarEditorController.InitializeCharacter()
	end)
	Remotes.connect(AvatarEditorRequests.RESET_CHARACTER_APPEARANCE, function()
		AvatarEditorController.OnResetCharacterAppearance:Fire()
	end)
end

return AvatarEditorController