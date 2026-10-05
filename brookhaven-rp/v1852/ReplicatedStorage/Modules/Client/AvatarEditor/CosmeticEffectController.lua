local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local AvatarEditorRequests = require(ReplicatedStorage.Modules.Shared.Game.AvatarEditorRequests)
local CosmeticEffectController = {}

function CosmeticEffectController.ApplyEmmiter(p: number, p2: string)
	local v, v2 = Remotes.invokeServer(AvatarEditorRequests.APPLY_EMMITER, p, p2)

	if not v then
		NotificationController.NotifyEditor(v2)
	end

	return v
end

function CosmeticEffectController.FrameworkInit() end

function CosmeticEffectController.FrameworkStart() end

return CosmeticEffectController