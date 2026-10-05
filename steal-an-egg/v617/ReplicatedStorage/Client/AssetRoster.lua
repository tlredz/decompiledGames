local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetRuntime = require(ReplicatedStorage.Shared.Types.AssetRuntime)
local Log = require(ReplicatedStorage.Packages.Log)
local PlotState = require(ReplicatedStorage.Client.PlotState)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local penRoster = Remotes.PenRoster
local AssetRoster = {
	SnapshotRefreshed = Signal.new(),
	OwnerRefreshed = Signal.new(),
	OwnerCleared = Signal.new(),
	PenAreaChanged = Signal.new()
}
local v = Log.new()
local v2 = {}
local v3 = {}
local count = 0

local function copyContents(items)
	local result = {}

	for k, item in items do
		local clone = table.clone(item.ItemData)
		clone.Mutations = table.clone(item.ItemData.Mutations)
		result[k] = {
			OwnerUserId = item.OwnerUserId,
			UID = item.UID,
			ItemData = clone,
			MoneyPerSecond = item.MoneyPerSecond,
			Seed = item.Seed,
			IsFirstPlacement = item.IsFirstPlacement
		}
	end

	return result
end

local function everyPen()
	local result = {}

	for k, v4 in v2 do
		table.insert(result, {
			OwnerUserId = k,
			Records = copyContents(v4)
		})
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function announce()
	AssetRoster.SnapshotRefreshed:Fire((everyPen()))
end

local function adopt(result, p: number)
	local v4 = {}

	for k, v5 in v2 do
		local v6

		if p < (v3[k] or 0) then
			v6 = copyContents(v5)
		end

		v4[k] = v6
	end

	for _, v5 in ipairs(result) do
		local v6 = (v3[v5.OwnerUserId] or 0) <= p
		local ownerUserId = v5.OwnerUserId
		local v7

		if v6 then
			v7 = copyContents(v5.Records)
		else
			v7 = v4[v5.OwnerUserId]
		end

		v4[ownerUserId] = v7
	end

	v2 = v4
	announce() -- equivalent call inferred; original call site unknown
end

local pullUntilAnswered

pullUntilAnswered = function()
	local v4 = count
	local success, result = pcall(function()
		return penRoster.AskLiveSnapshot:InvokeServer()
	end)
	local v5 = false
	local v6

	if not success then
		v6 = tostring(result)
	end

	if success then
		v5, v6 = AssetRuntime.SchemaValidation.RuntimeAssetSnapshot(result)
	end

	if v5 then
		adopt(result, v4)
		return
	end

	v:AtError():Log((`pen roster snapshot never landed, going round again: {v6}`))
	task.delay(5, pullUntilAnswered)
end

local function outcome(p, value)
	local selected = p == true

	if typeof(value) == "string" then
		return selected, value
	end

	return selected, nil
end

local function confirmed(object)
	return object:InvokeServer() == true
end

function AssetRoster.WearAsset(p: string)
	local v4, selected, v6 = penRoster.AskWear:InvokeServer(p)
	local v7 = v4 == true

	if typeof(selected) ~= "string" then
		selected = nil
	end

	if typeof(v6) == "string" then
		return v7, selected, v6
	end

	return v7, selected, nil
end

function AssetRoster.DoffAsset(p: string)
	return outcome(penRoster.AskDoff:InvokeServer(p))
end

function AssetRoster.ReadWearLimit()
	local v4 = penRoster.AskWearLimit:InvokeServer()

	if typeof(v4) == "number" then
		return v4
	end

	return 0
end

function AssetRoster.AckPetsBadge()
	return penRoster.ConfirmPetsBadge:InvokeServer() == true
end

function AssetRoster.AckEquipBestBadge()
	return penRoster.ConfirmEquipBestBadge:InvokeServer() == true
end

function AssetRoster.ReadSnapshot()
	return (everyPen())
end

function AssetRoster.ReadOwnerPen(p: number)
	local v4 = v2[p]

	if v4 == nil then
		return {}
	end

	return (copyContents(v4))
end

function AssetRoster.FindPenArea(p)
	local plot = PlotState.ResolvePlot(p)

	if plot == nil then
		return nil
	end

	return plot.PetArea
end

local v4 = {
	{
		feed = penRoster.OwnerShifted,
		vet = AssetRuntime.SchemaValidation.RuntimeAssetOwnerUpdate,
		complaint = "pen roster owner write turned away",
		apply = function(p)
			v2[p.OwnerUserId] = copyContents(p.Records)
			AssetRoster.OwnerRefreshed:Fire(p.OwnerUserId, (copyContents(p.Records)))
		end
	},
	{
		feed = penRoster.OwnerDropped,
		vet = AssetRuntime.SchemaValidation.RuntimeAssetOwnerClear,
		complaint = "pen roster owner erase turned away",
		apply = function(p)
			v2[p.OwnerUserId] = nil
			AssetRoster.OwnerCleared:Fire(p.OwnerUserId)
		end
	}
}

for _, v5 in ipairs(v4) do
	local v6 = v5
	v5.feed.OnClientEvent:Connect(function(p)
		local vet, v7 = v6.vet(p)

		if not vet then
			v:AtError():Log((`{v6.complaint}: {v7}`))
			return
		end

		count += 1
		v3[p.OwnerUserId] = count
		v6.apply(p)
		announce() -- equivalent call inferred; original call site unknown
	end)
end

PlotState.PlotChanged:Connect(function(_: number, p: number?)
	local playerByUserId

	if p ~= nil then
		playerByUserId = Players:GetPlayerByUserId(p)
	end

	if playerByUserId ~= nil then
		AssetRoster.PenAreaChanged:Fire(playerByUserId, AssetRoster.FindPenArea(playerByUserId))
	end
end)
task.spawn(pullUntilAnswered)
return AssetRoster