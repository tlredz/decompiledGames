local SavedSlotsController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local AvatarEditorRequests = require(ReplicatedStorage.Modules.Shared.Game.AvatarEditorRequests)
local v = {}
SavedSlotsController.OnSavedSlotsLoaded = Signal.new()

function SavedSlotsController.GetSavedSlots()
	return v
end

function SavedSlotsController.SaveOutfit(p: number, p2: string)
	local v2, v3 = Remotes.invokeServer(AvatarEditorRequests.SAVE_OUTFIT, p, p2)

	if v2 then
		return true, "Success"
	end

	return false, v3
end

function SavedSlotsController.LoadOutfit(p: number)
	local v2, v3 = Remotes.invokeServer(AvatarEditorRequests.LOAD_OUTFIT, p)

	if v2 then
		return true, v3
	end

	return false, v3
end

function SavedSlotsController.RenameSavedSlot(p: number, p2: string)
	local v2, v3, v4 = Remotes.invokeServer(AvatarEditorRequests.RENAME_SAVED_SLOT, p, p2)

	if v2 then
		return true, "Success", v4
	end

	return false, v3
end

function SavedSlotsController.FrameworkInit()
	Remotes.connect(AvatarEditorRequests.LOAD_SAVED_SLOTS, function(p)
		v = p
		SavedSlotsController.OnSavedSlotsLoaded:Fire(p)
	end)
end

function SavedSlotsController.FrameworkStart() end

return SavedSlotsController