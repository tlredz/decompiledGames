local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.Parent.AssetBillboardController)
local AssetComponent = require(script.Parent.AssetComponent)
local AssetEarnings = require(ReplicatedStorage.Shared.Util.AssetEarnings)
local AssetGender = require(ReplicatedStorage.Shared.Util.AssetGender)
require(script.Parent.AssetMovementBatch)
local AssetRuntime = require(ReplicatedStorage.Shared.Types.AssetRuntime)
local Assets = require(ReplicatedStorage.Data.Assets)
local ActiveAssetPerformanceTestConfig = require(script.Parent.ActiveAssetPerformanceTestConfig)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local Log = require(ReplicatedStorage.Packages.Log)
local PlotState = require(ReplicatedStorage.Client.PlotState)
local v = Log.new()
local random = Random.new()
local v2 = {}
local v3 = {}
local maid = nil
local folder = nil
local v4 = nil

for k in pairs(Assets.Directory) do
	if k ~= "Frigo Camelo" then
		table.insert(v2, k)
	end
end

table.sort(v2)
assert(#v2 > 0, "Active asset performance test requires at least one eligible category")

local function buildRuntimeRecord(p: number, i: number)
	local v5 = v2[random:NextInteger(1, #v2)]
	local egg = EggRecords.NewEgg(v5, random)
	egg.AssetGender = AssetGender.Settle(v5, nil, random)
	local assetItemData = EggRecords.ToAssetItemData(egg)
	assetItemData.HasBeenFirstPlaced = true
	local formatted = `PERFORMANCE_TEST_{p}_{i}`
	local v6 = {
		OwnerUserId = Players.LocalPlayer.UserId,
		UID = formatted,
		ItemData = assetItemData,
		MoneyPerSecond = AssetEarnings.LiveRatePerSecond(assetItemData),
		Seed = random:NextInteger(1, 2147483647)
	}
	assert(AssetRuntime.SchemaValidation.RuntimeAssetRecord(v6), "Invalid performance-test asset record")
	return v6
end

local function destroySlot(p: number)
	local v5 = v3[p]

	if v5 == nil then
		return
	end

	v3[p] = nil

	for _, component in ipairs(v5.Components) do
		maid:Remove(component:GetModel())
		component:Destroy()
	end

	v5.Container:Destroy()
end

local function activateSlot(p: number, area)
	local folder2 = Instance.new("Folder")
	folder2.Name = `Plot{p}`
	folder2.Parent = folder
	local components = {}

	for i = 1, ActiveAssetPerformanceTestConfig.PetsPerPlot do
		local runtimeRecord = buildRuntimeRecord(p, i)
		local v6 = AssetComponent.new(runtimeRecord, Players.LocalPlayer, area, folder2, maid, v4, nil)
		maid:Add(v6:GetModel(), runtimeRecord.ItemData, runtimeRecord.MoneyPerSecond)
		table.insert(components, v6)
	end

	v3[p] = {
		Area = area,
		Components = components,
		Container = folder2
	}
	v:AtInfo():Log((`Created {ActiveAssetPerformanceTestConfig.PetsPerPlot} performance-test pets for plot {p}`))
end

local function syncSlot(name: number)
	local area = nil
	local folder2 = PlotState.ResolveFolder()
	local v6

	if folder2 == nil then
		v6 = false
	else
		local child = folder2:FindFirstChild((tostring(name)))
		v6 = child ~= nil
		local toUpdate

		if child ~= nil then
			toUpdate = child:FindFirstChild("ToUpdate")
		end

		local petArea

		if not (toUpdate == nil or not toUpdate:IsA("Model")) then
			petArea = toUpdate:FindFirstChild("PetArea")
		end

		if petArea ~= nil and petArea:IsA("BasePart") then
			area = petArea
		end
	end

	local v7 = v3[name]

	if not v6 then
		destroySlot(name)
		return
	end

	if area == nil then
		return
	end

	if v7 == nil then
		activateSlot(name, area)
		return
	end

	if v7.Area == area then
		return
	end

	v7.Area = area

	for _, component in ipairs(v7.Components) do
		component:SetAssetArea(area)
	end
end

local function syncAllSlots()
	local folder2 = PlotState.ResolveFolder()
	local v5 = {}

	if folder2 ~= nil then
		for _, child in ipairs(folder2:GetChildren()) do
			local name = tonumber(child.Name)

			if name == nil then
				continue
			end

			v5[name] = true
			syncSlot(name)
		end
	end

	for k in pairs(v3) do
		if v5[k] ~= true then
			destroySlot(k)
		end
	end
end

return {
	Start = function(parent, p, p2)
		local v5

		if ActiveAssetPerformanceTestConfig.PetsPerPlot > 0 then
			v5 = ActiveAssetPerformanceTestConfig.PetsPerPlot % 1 == 0
		else
			v5 = false
		end

		assert(v5, "PetsPerPlot must be a positive integer")
		maid = p
		v4 = p2
		folder = Instance.new("Folder")
		folder.Name = "PerformanceTestAssets"
		folder.Parent = parent
		PlotState.PlotChanged:Connect(syncSlot)
		PlotState.FolderChanged:Connect(syncAllSlots)
		syncAllSlots()
	end
}