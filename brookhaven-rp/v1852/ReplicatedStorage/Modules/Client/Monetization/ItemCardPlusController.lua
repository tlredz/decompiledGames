local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NewUserDataController = require(ReplicatedStorage.Modules.Client.Util.NewUserDataController)
local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)
local PopupQueue = require(ReplicatedStorage.Modules.Client.UI.PopupQueue)
local ProfileFlagController = require(ReplicatedStorage.Modules.Client.PlayerData.ProfileFlagController)
local ProfileFlags = require(ReplicatedStorage.Modules.Shared.PlayerData.ProfileFlags)
local ItemCardPlusController = {}

function ItemCardPlusController.FrameworkInit() end

function ItemCardPlusController.FrameworkStart()
	if ProfileFlagController.IsCompleted(ProfileFlags.ROBLOX_PLUS_POPUP_SHOWN) or not PlayerFlag.IsEnabled("roblox-plus-popup") then
		return
	end

	local newUserData, _, v = NewUserDataController.GetNewUserData()

	if not newUserData or v == nil then
		return
	end

	if Players.LocalPlayer.HasRobloxSubscription then
		ProfileFlagController.Complete(ProfileFlags.ROBLOX_PLUS_POPUP_SHOWN)
		return
	end

	if (DateTime.now().UnixTimestampMillis - v) / 86400000 < 7 then
		return
	end

	PopupQueue.RegisterHandler("MainGUIHandler", "ItemCardPlus", function() end)
	ProfileFlagController.Complete(ProfileFlags.ROBLOX_PLUS_POPUP_SHOWN)
	PopupQueue.Dispatch("MainGUIHandler", "ItemCardPlus")
end

return ItemCardPlusController