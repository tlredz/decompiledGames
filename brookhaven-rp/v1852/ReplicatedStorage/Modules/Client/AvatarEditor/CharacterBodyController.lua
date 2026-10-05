local CharacterBodyController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local AvatarEditorRequests = require(ReplicatedStorage.Modules.Shared.Game.AvatarEditorRequests)
CharacterBodyController.OnBodySizeChanged = Signal.new()

function CharacterBodyController.IncrementBodySize(flag: boolean)
	Remotes.fireServer(AvatarEditorRequests.INCREMENT_BODY_SIZE, flag)
end

function CharacterBodyController.ChangeCharacterBody(p)
	return Remotes.invokeServer(AvatarEditorRequests.CHANGE_CHARACTER_BODY, p)
end

function CharacterBodyController.ChangeBodyColor(p: string)
	Remotes.fireServer(AvatarEditorRequests.CHANGE_BODY_COLOR, p)
end

function CharacterBodyController.FrameworkInit() end

function CharacterBodyController.FrameworkStart()
	Remotes.connect(AvatarEditorRequests.BODY_SIZE_CHANGED, function(p)
		CharacterBodyController.OnBodySizeChanged:Fire(p)
	end)
end

return CharacterBodyController