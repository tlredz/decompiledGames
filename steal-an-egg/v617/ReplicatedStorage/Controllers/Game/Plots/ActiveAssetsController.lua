local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ActiveAssetIncomePopup = require(script.Parent.Parent.Parent.GUI.ActiveAssetIncomePopup)
local ActiveAssetPerformanceTest = require(script.ActiveAssetPerformanceTest)
local ActiveAssetPerformanceTestConfig = require(script.ActiveAssetPerformanceTestConfig)
local AssetBillboardController = require(script.AssetBillboardController)
local AssetChatBubble = require(ReplicatedStorage.Client.UI.AssetChatBubble)
local AssetComponent = require(script.AssetComponent)
local AssetHoverDataDisplay = require(script.Parent.Parent.Parent.GUI.AssetHoverDataDisplay)
local AssetMovementBatch = require(script.AssetMovementBatch)
local AssetPlacementHints = require(script.AssetPlacementHints)
local AssetRoster = require(ReplicatedStorage.Client.AssetRoster)
require(ReplicatedStorage.Shared.Types.AssetRuntime)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local ModelCameraOcclusion = require(ReplicatedStorage.Client.ModelCameraOcclusion)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Preferences = require(ReplicatedStorage.Shared.Preferences)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = AssetMovementBatch.new()
local maid = AssetBillboardController.new()
local v2 = {}
local v3 = {}
local v4 = false
local isOn = Preferences.IsOn("HideOtherPets")
local isOn2 = Preferences.IsOn("HideSelfPets")
local v5 = false
local folder = Instance.new("Folder")
folder.Name = "ClientRenderedAssets"
folder.Parent = workspace
local ActiveAssetsController = {
	ItemAdded = Signal.new(),
	ItemRemoved = Signal.new(),
	CashCollected = Signal.new(),
	InitialLoadCompleted = Signal.new()
}

-- equivalent calls inferred from this helper; original call sites unknown
local function makeKey(p: number, k: string)
	return (`{p}:{k}`)
end

local function recordForComponent(key: string, item)
	if item.IsFirstPlacement ~= true then
		return item
	end

	if v3[key] ~= true then
		v3[key] = true
		return item
	end

	local clone = table.clone(item)
	local clone2 = table.clone(item.ItemData)
	clone2.Mutations = table.clone(item.ItemData.Mutations)
	clone.ItemData = clone2
	clone.IsFirstPlacement = nil
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isOwnerHidden(ownerUserId: number)
	if ownerUserId == Players.LocalPlayer.UserId then
		return isOn2
	end

	return isOn
end

local function syncHoverEntry(object)
	local ownerUserId = object:GetOwnerUserId()
	local uid = object:GetUid()

	-- equivalent call inferred; original call site unknown
	if isOwnerHidden(ownerUserId) then
		AssetHoverDataDisplay.RemoveEntry(ownerUserId, uid)
		return
	end

	local runtimeRecord = object:GetRuntimeRecord()
	AssetHoverDataDisplay.SetEntry({
		Record = runtimeRecord,
		Model = object:GetModel()
	})
end

local function applyComponentHiddenState(object)
	local v6 = v5

	if not v6 then
		if object:GetOwnerUserId() == Players.LocalPlayer.UserId then
			v6 = isOn2
		else
			v6 = isOn
		end
	end

	if object:IsHidden() == v6 then
		return
	end

	local model = object:GetModel()

	if v6 then
		ModelCameraOcclusion.SetIgnored(model, true)
		object:SetHidden(true)
		maid:SetSuppressed(model, true)
	else
		object:SetHidden(false)
		maid:SetSuppressed(model, false)
		ModelCameraOcclusion.SetIgnored(model, false)
	end
end

local function setHideOtherPets(flag: boolean)
	if isOn == flag then
		return
	end

	isOn = flag

	if flag then
		v:SetForeignPresentationSuppressed(true)
	end

	for _, v6 in pairs(v2) do
		if v6 == nil then
			continue
		end

		applyComponentHiddenState(v6)
		syncHoverEntry(v6)
	end

	if not flag then
		v:SetForeignPresentationSuppressed(false)
	end
end

local function setHideSelfPets(flag: boolean)
	if isOn2 == flag then
		return
	end

	isOn2 = flag

	for _, v6 in pairs(v2) do
		if v6 == nil then
			continue
		end

		applyComponentHiddenState(v6)
		syncHoverEntry(v6)
	end
end

function ActiveAssetsController.SetAllPetsHidden(flag: boolean)
	if v5 == flag then
		return
	end

	v5 = flag

	for _, v6 in pairs(v2) do
		if v6 == nil then
			continue
		end

		applyComponentHiddenState(v6)
		syncHoverEntry(v6)
	end
end

local function destroyComponent(p: string)
	local v6 = v2[p]

	if v6 == nil then
		return
	end

	local model = v6:GetModel()
	maid:Remove(model)
	AssetHoverDataDisplay.RemoveEntry(v6:GetOwnerUserId(), v6:GetUid())
	v6:Destroy()
	v2[p] = nil
	ActiveAssetsController.ItemRemoved:Fire(model)
end

local function clearOwner(p: number)
	for k, v6 in pairs(v2) do
		if v6 ~= nil and v6:GetOwnerUserId() == p then
			destroyComponent(k)
		end
	end
end

local function reconcileOwner(p: number, items)
	local playerByUserId = Players:GetPlayerByUserId(p)

	if playerByUserId == nil then
		clearOwner(p)
		return
	end

	local penArea = AssetRoster.FindPenArea(playerByUserId)

	if penArea == nil then
		return
	end

	local v6 = {}

	for k, item in pairs(items) do
		local key = makeKey(p, k) -- equivalent call inferred; original call site unknown
		v6[key] = true
		local v7 = recordForComponent(key, item)
		local v8 = v2[key]

		if v8 ~= nil and table.concat(v8:GetRuntimeRecord().ItemData.Mutations, ",") ~= table.concat(
			item.ItemData.Mutations,
			","
		) then
			destroyComponent(key)
			v8 = nil
		end

		if v8 == nil then
			local v9

			if playerByUserId == Players.LocalPlayer then
				v9 = AssetPlacementHints.ConsumeFrontPlacement(k, penArea)
			end

			v8 = AssetComponent.new(v7, playerByUserId, penArea, folder, maid, v, v9)
			v2[key] = v8
			maid:Add(v8:GetModel(), v7.ItemData, v7.MoneyPerSecond)
			ActiveAssetsController.ItemAdded:Fire(v8:GetModel())
		else
			if playerByUserId == Players.LocalPlayer then
				AssetPlacementHints.ClearFrontPlacement(k)
			end

			v8:SetRuntimeRecord(v7)
			v8:SetAssetArea(penArea)
			maid:UpdateMoneyPerSecond(v8:GetModel(), v7.MoneyPerSecond)
		end

		applyComponentHiddenState(v8)
		syncHoverEntry(v8)
	end

	for k, v7 in pairs(v2) do
		if v7 ~= nil and v7:GetOwnerUserId() == p and v6[k] ~= true then
			destroyComponent(k)
		end
	end
end

local function reconcileSnapshot(list)
	local v6 = {}

	for _, v7 in ipairs(list) do
		v6[v7.OwnerUserId] = true
		reconcileOwner(v7.OwnerUserId, v7.Records)
	end

	for k, v7 in pairs(v2) do
		if v7 ~= nil and v6[v7:GetOwnerUserId()] ~= true then
			destroyComponent(k)
		end
	end
end

function ActiveAssetsController.GetModelByUID(p: string)
	for _, v6 in pairs(v2) do
		if v6 ~= nil and v6:GetUid() == p then
			return v6:GetModel()
		end
	end

	return nil
end

function ActiveAssetsController.GetAll()
	local modelsByUid = {}

	for _, v6 in pairs(v2) do
		if v6 ~= nil then
			modelsByUid[v6:GetUid()] = v6:GetModel()
		end
	end

	return modelsByUid
end

function ActiveAssetsController.GetActiveModels()
	local result = {}

	for _, v6 in pairs(ActiveAssetsController.GetAll()) do
		table.insert(result, v6)
	end

	return result
end

AssetRoster.SnapshotRefreshed:Connect(reconcileSnapshot)
AssetRoster.OwnerRefreshed:Connect(reconcileOwner)
AssetRoster.OwnerCleared:Connect(clearOwner)
ActiveAssetsController.ItemAdded:Connect(function(p)
	ModelCameraOcclusion.Register(p, 1)
end)
ActiveAssetsController.ItemRemoved:Connect(ModelCameraOcclusion.Forget)
Preferences.Observe("HideOtherPets", setHideOtherPets)
Preferences.Observe("HideSelfPets", setHideSelfPets)
Remotes.Treadmill.AssignedBeltShifted.OnClientEvent:Connect(function(p: string?)
	v4 = p ~= nil
	ModelCameraOcclusion.SetEnabled(v4)
	AssetChatBubble.PinAbove(not v4)
end)
AssetRoster.PenAreaChanged:Connect(function(p)
	reconcileOwner(p.UserId, AssetRoster.ReadOwnerPen(p.UserId))
end)
Players.PlayerRemoving:Connect(function(player)
	clearOwner(player.UserId)
end)
Remotes.PenRoster.CoinsGathered.OnClientEvent:Connect(function(list)
	for _, v6 in ipairs(list) do
		local uid = v6.uid

		if uid == nil then
			continue
		end

		ActiveAssetsController.CashCollected:Fire(uid)

		if v5 then
			continue
		end

		assert(v6.amount > 0, (`Active asset income popup requires positive amount for uid "{uid}"`))
		local v7 = assert(
			ActiveAssetsController.GetModelByUID(uid),
			(`Active asset income popup missing rendered model for uid "{uid}"`)
		)
		ActiveAssetIncomePopup.Show(v7, v6.amount, {
			alwaysOnTop = not v4
		})
	end
end)

if ActiveAssetPerformanceTestConfig.Enabled and Constants.IS_STUDIO then
	ActiveAssetPerformanceTest.Start(folder, maid, v)
end

v:SetForeignPresentationSuppressed(isOn)
reconcileSnapshot(AssetRoster.ReadSnapshot())
ActiveAssetsController.InitialLoadCompleted:Fire()
return ActiveAssetsController