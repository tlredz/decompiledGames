local ExperienceNotificationService = game:GetService("ExperienceNotificationService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local TestLibrary = require(ReplicatedStorage.Modules.TestLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ShootingRangeController = require(Players.LocalPlayer.PlayerScripts.Controllers.ShootingRangeController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local DuelController = require(Players.LocalPlayer.PlayerScripts.Controllers.DuelController)
local testAttribute = TestLibrary:GetTestAttribute("StudioSkipOnboarding")
local lobbyElements = Players.LocalPlayer.PlayerScripts.Modules.LobbyElements
local v = {
	"StarterBundleBoards",
	"LeaderboardDisplays",
	"EliminationsDisplays",
	"DuelsDisplays",
	"DuelsGarageDoor",
	"LikeBoards",
	"LooseWeaponDisplays",
	"Miscellaneous",
	"DuelsSign",
	"RotatingBundleDisplay",
	"WeaponReleaseSchedule",
	"ToyTrainPaths",
	"Teleporters",
	"DailyShopSkinHolograms",
	"LobbyPortals",
	"LobbyAnimations",
	"UpdateCountdowns",
	"TopPlayerRewards",
	"ProximityPageOpeners",
	"BillboardVideoAdBoards",
	"OnlyAppearWhens"
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.LocalFighter = nil
	self.Elements = {}
	self._renderstep_connection = nil
	self._textures_deleted = false
	self._attempted_to_favorite = false
	self:_Init()
	return self
end

function class.ToDuels(_)
	if FighterController.LocalFighter and FighterController.LocalFighter:Get("IsInShootingRange") then
		ShootingRangeController:Leave(true)
	elseif FighterController.LocalFighter and not FighterController.LocalFighter:Get("IsInDuel") and FighterController.LocalFighter:IsAlive() then
		FighterController.LocalFighter.Entity.Model:PivotTo(CollectionService:GetTagged("LobbyDuels")[1].CFrame)
	end
end

function class:_RemoveSuperStarterBundleHolograms()
	local v2

	if ServerOsTime:Get() < PlayerDataController:Get("SuperStarterBundleStartTime") + MonetizationLibrary.SUPER_STARTER_BUNDLE_OFFER_DURATION then
		v2 = not PlayerDataController:Get("SuperStarterBundlePurchased")
	else
		v2 = false
	end

	if v2 then
		return
	end

	for _, v3 in pairs(CollectionService:GetTagged("LobbySuperStarterBundleHologram")) do
		task.defer(v3.Destroy, v3)
	end
end

function class:_RemoveGiftHolograms()
	if not PlayerDataController:Get("ClaimedGroupReward") then
		return
	end

	for _, v2 in pairs(CollectionService:GetTagged("LobbyFreeRewardsHologram")) do
		task.defer(v2.Destroy, v2)
	end
end

function class:_PromptStuff()
	if testAttribute then
		return
	end

	wait(1)

	if DuelController:GetDuel(Players.LocalPlayer) then
		return
	end

	local statistic = PlayerDataController:GetStatistic("StatisticDuelsPlayed")
	local statistic2 = PlayerDataController:GetStatistic("StatisticDuelsWon")

	if self._attempted_to_favorite or statistic ~= 5 and statistic2 ~= 1 then
		if not PlayerDataController:Get("PromptedNotificationPrompt") and (statistic >= 8 or statistic2 == 2) then
			local success, result = pcall(
				ExperienceNotificationService.CanPromptOptInAsync,
				ExperienceNotificationService
			)

			if not success then
				warn("Failed to check if user can prompt notifications:", result)
			elseif result then
				ReplicatedStorage.Remotes.Data.PromptedNotificationPrompt:FireServer()
				ExperienceNotificationService:PromptOptIn()
			end
		end
	else
		self._attempted_to_favorite = true
		AvatarEditorService:PromptSetFavorite(CONSTANTS.HUB_PLACE_ID, Enum.AvatarItemType.Asset, true)
	end
end

function class:_UpdateEnabled()
	if self._renderstep_connection then
		self._renderstep_connection:Disconnect()
		self._renderstep_connection = nil
	end

	local v2 = self.LocalFighter and not (self.LocalFighter:Get("IsInDuel") or self.LocalFighter:Get("IsInShootingRange"))

	for _, element in pairs(self.Elements) do
		element:SetEnabled(v2)
	end

	if v2 then
		self._renderstep_connection = RunService.RenderStepped:Connect(function(dt)
			for _, element in pairs(self.Elements) do
				element:Update(dt)
			end
		end)
	end

	if v2 then
		task.defer(self._PromptStuff, self)
	end
end

function class:_UpdateShadows()
	Lighting.GlobalShadows = not PlayerDataController:GetSetting("Shadows Disabled")

	if self._shadows_deleted or not PlayerDataController:GetSetting("Shadows Disabled") then
		return
	end

	self._shadows_deleted = true

	for _, v2 in pairs(CollectionService:GetTagged("LobbyFolder")) do
		Utility:DisableShadows(v2)
	end
end

function class:_UpdateTextures()
	if self._textures_deleted or not PlayerDataController:GetSetting("Textures Disabled") then
		return
	end

	self._textures_deleted = true

	for _, v2 in pairs(CollectionService:GetTagged("LobbyFolder")) do
		Utility:DisableTextures(v2)
	end
end

function class:_Setup()
	self.LocalFighter = FighterController:WaitForLocalFighter()
	self.LocalFighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_UpdateEnabled()
	end)
	self.LocalFighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_UpdateEnabled()
	end)

	for _, v2 in pairs(v) do
		local v3 = v2
		task.defer(function()
			table.insert(self.Elements, require(lobbyElements[v3]))
		end)
	end

	task.defer(self._UpdateEnabled, self)
end

function class:_Init()
	PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
		self:_PromptStuff()
	end)
	PlayerDataController:GetSettingChangedSignal("Textures Disabled"):Connect(function()
		self:_UpdateTextures()
	end)
	PlayerDataController:GetSettingChangedSignal("Shadows Disabled"):Connect(function()
		self:_UpdateShadows()
	end)
	PlayerDataController:GetDataChangedSignal("SuperStarterBundlePurchased"):Connect(function()
		self:_RemoveSuperStarterBundleHolograms()
	end)
	PlayerDataController:GetDataChangedSignal("ClaimedGroupReward"):Connect(function()
		self:_RemoveGiftHolograms()
	end)
	CollectionService:GetInstanceAddedSignal("LobbyFreeRewardsHologram"):Connect(function()
		self:_RemoveGiftHolograms()
	end)
	DuelController.LocalPlayerLeftDuel:Connect(function()
		self:_PromptStuff()
	end)
	self:_UpdateTextures()
	task.spawn(self._Setup, self)
	task.defer(self._UpdateShadows, self)
	task.defer(self._RemoveGiftHolograms, self)
	task.defer(self._RemoveSuperStarterBundleHolograms, self)
end

return class._new()