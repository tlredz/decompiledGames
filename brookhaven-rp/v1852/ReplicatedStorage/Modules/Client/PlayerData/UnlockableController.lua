local UnlockableController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local ReplicatedDataController2 = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local UnlockState = require(ReplicatedStorage.Modules.Shared.PlayerData.UnlockState)
local ItemUnlockedPrompt = require(ReplicatedStorage.Modules.Client.Components.UI.ItemUnlockedPrompt)
local ItemUnlockedPromptWithDescription = require(ReplicatedStorage.Modules.Client.Components.UI.ItemUnlockedPromptWithDescription)
local PopupQueue = require(ReplicatedStorage.Modules.Client.UI.PopupQueue)
require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
UnlockableController.OnItemUnlocked = Signal.new()

function UnlockableController.IsFeatureUnlocked(p: string, p2)
	if p2 == nil or not GamepassController.IsOwned(p2) then
		return UnlockableController.GetFeatureUnlockState(p):HasAccess()
	end

	return true
end

function UnlockableController.GetFeatureUnlockState(p: string)
	local expect = ReplicatedDataController2.GetClientReplicaPromise():expect()
	local v = expect.Data.unlockedExpiringFeatures[p] or {}
	local v2 = expect.Data.unlockedFeatures[p] or {}

	if next(v2) then
		v = TableUtil.Reconcile(v, v2)
	end

	return UnlockState.new(v)
end

function UnlockableController.GetAllFeaturesUnlockedWithExpiration()
	return ReplicatedDataController2.GetClientReplicaPromise():expect().Data.unlockedExpiringFeatures
end

function UnlockableController.FrameworkInit() end

function UnlockableController.FrameworkStart()
	PopupQueue.RegisterHandler("MainGUIHandler", "ItemUnlockedPrompt", function(p)
		ItemUnlockedPrompt:WaitForInstance((Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGUIHandler"):WaitForChild("ItemUnlockedPrompt"))):expect():SetData(p)
	end)
	PopupQueue.RegisterHandler("MainGUIHandler", "ItemUnlockedPromptWithDescription", function(p)
		ItemUnlockedPromptWithDescription:WaitForInstance((Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGUIHandler"):WaitForChild("ItemUnlockedPromptWithDescription"))):expect():SetData(p)
	end)
	Remotes.connect("UnlockableController_ShowUnlockPrompt", function(p)
		if p.description then
			PopupQueue.Dispatch("MainGUIHandler", "ItemUnlockedPromptWithDescription", p)
		else
			PopupQueue.Dispatch("MainGUIHandler", "ItemUnlockedPrompt", p)
		end
	end)
	ReplicatedDataController.GetClientReplicaPromise():andThen(function(object)
		object:OnChange(function(p: string, list, _, _)
			if p ~= "Set" then
				return
			end

			if list[1] == "unlockedExpiringFeatures" or list[1] == "unlockedFeatures" and #list == 2 then
				UnlockableController.OnItemUnlocked:Fire(list[2])
			end
		end)
	end):catch(warn)
end

return UnlockableController