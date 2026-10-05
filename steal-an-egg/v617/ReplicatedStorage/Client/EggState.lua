local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local AreaEggs = require(ReplicatedStorage.Shared.Types.AreaEggs)
local Log = require(ReplicatedStorage.Packages.Log)
local Eggs = require(ReplicatedStorage.Shared.Types.Eggs)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local AreaEggResetCycle = require(ReplicatedStorage.Shared.Types.AreaEggResetCycle)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Promise = require(ReplicatedStorage.Packages.Promise)
local OnboardingTiming = require(ReplicatedStorage.Shared.Util.OnboardingTiming)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local t = require(ReplicatedStorage.Packages.t)
local eggWorld = Remotes.EggWorld
local EggState = {
	SnapshotRefreshed = Signal.new(),
	OwnerRefreshed = Signal.new(),
	OwnerCleared = Signal.new(),
	FieldRefreshed = Signal.new(),
	FieldShifted = Signal.new(),
	FieldGone = Signal.new(),
	CarryChanged = Signal.new(),
	FieldClaimed = Signal.new(),
	ResetCountdown = Signal.new(),
	RarityRevealed = Signal.new(),
	RarityPresented = Signal.new(),
	ResetFade = Signal.new()
}
local strict = t.strict(t.string)
local strict2 = t.strict(t.number)
local strict3 = t.strict(t.boolean)
local strict4 = t.strict(t.optional(t.string))
local strict5 = t.strict(t.CFrame)
local v = Log.new()
local localPlayer = Players.LocalPlayer
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local count = 0
local count2 = 0
local v6 = nil
local v7 = {}
local v8 = nil
local v9 = false
local copy = {
	IsCarrying = false
}

local function twin(p)
	return TableUtil.Copy(p, true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stampOwner(p: number)
	count += 1
	v4[p] = count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stampField(p: string)
	count2 += 1
	v5[p] = count2
end

local function ownedRows()
	local result = {}

	for k, v10 in v2 do
		table.insert(result, {
			OwnerUserId = k,
			Records = TableUtil.Copy(v10, true)
		})
	end

	return result
end

local function fieldRows()
	local records = {}

	for _, v11 in v3 do
		table.insert(records, twin(v11))
	end

	return {
		Records = records,
		ServerTime = Workspace:GetServerTimeNow()
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tellOwned()
	EggState.SnapshotRefreshed:Fire((ownedRows()))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tellField()
	EggState.FieldRefreshed:Fire((fieldRows()))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropOwner(p: number)
	v2[p] = nil
	EggState.OwnerCleared:Fire(p)
	tellOwned() -- equivalent call inferred; original call site unknown
end

local function adoptOwned(list, p: number)
	local v10 = {}

	for k, v11 in v2 do
		local v12

		if p < (v4[k] or 0) then
			v12 = TableUtil.Copy(v11, true)
		end

		v10[k] = v12
	end

	for _, v11 in ipairs(list) do
		local v12 = (v4[v11.OwnerUserId] or 0) <= p
		local ownerUserId = v11.OwnerUserId
		local copy2

		if v12 then
			local records = v11.Records
			copy2 = TableUtil.Copy(records, true)
		else
			copy2 = v10[v11.OwnerUserId]
		end

		v10[ownerUserId] = copy2
	end

	v2 = v10
	tellOwned() -- equivalent call inferred; original call site unknown
end

local function adoptField(p, p2: number)
	local v10 = {}

	for k, v11 in v3 do
		local v12

		if p2 < (v5[k] or 0) then
			v12 = TableUtil.Copy(v11, true)
		end

		v10[k] = v12
	end

	for _, record in ipairs(p.Records) do
		local v11 = (v5[record.Uid] or 0) <= p2
		local uid = record.Uid
		local v12

		if v11 then
			v12 = TableUtil.Copy(record, true)
		else
			v12 = v10[record.Uid]
		end

		v10[uid] = v12
	end

	v3 = v10
	tellField() -- equivalent call inferred; original call site unknown
end

local keepAsking

keepAsking = function(p: string, callback)
	local success, result = pcall(callback)

	if success then
		return
	end

	v:AtError():Log((`{p} never landed, going round again: {result}`))
	task.delay(5, keepAsking, p, callback)
end

local function outcome(p, value)
	local selected = p == true

	if typeof(value) == "string" then
		return selected, value
	end

	return selected, nil
end

function EggState.FetchEggRecord(p: string)
	strict(p)
	local v10 = eggWorld.AskEggRecord:InvokeServer(p)

	if v10 == nil then
		return nil
	end

	local savedEgg, v11 = Eggs.SchemaValidation.SavedEgg(v10)

	if savedEgg then
		return twin(v10)
	end

	v:AtError():Log((`the egg record for {p} came back malformed: {v11}`))
	return nil
end

function EggState.SyncOwnedEggs()
	local v10 = count
	local v11 = eggWorld.AskLiveSnapshot:InvokeServer()
	local runtimeEggSnapshot, v12 = Eggs.SchemaValidation.RuntimeEggSnapshot(v11)
	assert(runtimeEggSnapshot, (`the owned egg snapshot failed validation: {v12}`))
	adoptOwned(v11, v10)
	return (ownedRows())
end

function EggState.SyncFieldEggs()
	local v10 = v8

	if v10 == nil then
		local v11 = count2
		v10 = Promise.try(function()
			local v12 = eggWorld.AskFieldEggSnapshot:InvokeServer()
			local areaEggSnapshot, v13 = AreaEggs.SchemaValidation.AreaEggSnapshot(v12)
			assert(areaEggSnapshot, (`the field egg snapshot failed validation: {v13}`))
			return v12
		end):timeout(30):andThen(function(p)
			v9 = true
			adoptField(p, v11)
			OnboardingTiming.Mark("FieldSnapshotReceived")
		end)
		v8 = v10
		v10:finally(function()
			if v8 == v10 then
				v8 = nil
			end
		end):catch(function() end)
	end

	local v11, v12 = v10:await()

	if not v11 then
		error(tostring(v12), 2)
	end

	return (fieldRows())
end

function EggState.FetchRarityShows()
	local v10, v11 = eggWorld.AskFieldEggRarityShows:InvokeServer()
	strict3(v10)

	if v10 ~= true or v11 == nil then
		return v10 == true, nil
	end

	local revealPayload, v12 = AreaEggResetCycle.SchemaValidation.RevealPayload(v11)
	assert(revealPayload, (`the rare spawn reveal payload failed validation: {v12}`))
	return true, v11
end

function EggState.WearEggTool(p: string)
	strict(p)
	return outcome(eggWorld.AskWearTool:InvokeServer(p))
end

function EggState.DoffEggTool(p: string?)
	strict4(p)
	return outcome(eggWorld.AskDoffTool:InvokeServer(p))
end

function EggState.CarryFieldEgg(uid: string, firstAreaSlotKey: string?)
	strict(uid)
	strict4(firstAreaSlotKey)
	return outcome(eggWorld.AskFieldEggCarry:InvokeServer({
		Uid = uid,
		FirstAreaSlotKey = firstAreaSlotKey
	}))
end

function EggState.DropFieldEgg(reason)
	local v10, v11 = AreaEggs.SchemaValidation.DropReason(reason)
	assert(reason == nil or v10, v11)
	return outcome(eggWorld.AskFieldEggDrop:InvokeServer({
		Reason = reason
	}))
end

function EggState.PlantEgg(uid: string, cframe: CFrame)
	strict(uid)
	strict5(cframe)
	v7[uid] = true
	local v10, v11 = eggWorld.AskPlaceEgg:InvokeServer({
		Uid = uid,
		LocalCFrame = cframe
	})
	local v12 = v10 == true

	if typeof(v11) ~= "string" then
		v11 = nil
	end

	if v12 ~= true then
		v7[uid] = nil
	end

	return v12, v11
end

function EggState.TakePlantCue(p: string)
	strict(p)
	local v10 = v7[p] == true
	v7[p] = nil
	return v10
end

function EggState.BeginSkipGrowth(p: string)
	strict(p)
	local v10, v11, selected = eggWorld.AskSkipGrowth:InvokeServer(p)

	if v10 == true then
		if typeof(selected) ~= "number" then
			selected = nil
		end

		if selected == nil then
			v:AtError():Log("skip-growth was granted but arrived without a product id")
			return false, "Invalid skip growth product", nil
		end

		v6 = p
		return true, nil, selected
	else
		if typeof(v11) ~= "string" then
			v11 = nil
		end

		return false, v11, nil
	end
end

function EggState.BeginHatch(p: string)
	strict(p)
	local v10, selected, v12 = eggWorld.AskHatch:InvokeServer(p)
	local v13 = v10 == true

	if typeof(selected) ~= "string" then
		selected = nil
	end

	if typeof(v12) == "string" then
		return v13, selected, v12
	end

	return v13, selected, nil
end

function EggState.FinishHatch(p: string)
	strict(p)
	local v10, v11, selected = eggWorld.AskFinishHatch:InvokeServer(p)

	if v10 == true then
		if typeof(selected) ~= "string" then
			selected = nil
		end

		if selected ~= nil then
			return true, nil, selected
		end

		v:AtError():Log("the hatch finished but the granted asset uid was not a string")
		return false, "Invalid granted asset UID", nil
	else
		if typeof(v11) ~= "string" then
			v11 = nil
		end

		return false, v11, nil
	end
end

function EggState.ReadChosenSkipUid()
	return v6
end

function EggState.ForgetChosenSkip()
	v6 = nil
end

function EggState.ReadOwnedEggs()
	return (ownedRows())
end

function EggState.ReadFieldEggs()
	return (fieldRows())
end

function EggState.HasFieldSnapshot()
	return v9
end

function EggState.ReadCarryState()
	return twin(copy)
end

function EggState.ReadOwnerEggs(p: number)
	strict2(p)
	local v10 = v2[p]

	if v10 == nil then
		return {}
	end

	return (TableUtil.Copy(v10, true))
end

function EggState.ReadOwnedEgg(p: number, p2: string)
	strict2(p)
	strict(p2)
	local v10 = v2[p]
	local v11

	if v10 ~= nil then
		v11 = v10[p2]
	end

	if v11 == nil then
		return nil
	end

	return (TableUtil.Copy(v11, true))
end

function EggState.ReadFieldEgg(p: string)
	strict(p)
	local v10 = v3[p]

	if v10 == nil then
		return nil
	end

	return (TableUtil.Copy(v10, true))
end

function EggState.IsReadyToHatch(p: string)
	strict(p)
	local ownedEgg = EggState.ReadOwnedEgg(localPlayer.UserId, p)

	if ownedEgg == nil or ownedEgg.Placement == nil then
		return false
	end

	local serverTimeNow = Workspace:GetServerTimeNow()
	local growthSpeedMultiplier = ownedEgg.GrowthSpeedMultiplier
	local currentNightCredit = EggRecords.CurrentNightCredit(ownedEgg, serverTimeNow, growthSpeedMultiplier)
	return EggRecords.IsGrown(ownedEgg, serverTimeNow, growthSpeedMultiplier, currentNightCredit, localPlayer)
end

function EggState.MayBuyChosenSkip()
	local v10 = v6

	if not v10 then
		return false, "No egg selected"
	end

	local ownedEgg = EggState.ReadOwnedEgg(localPlayer.UserId, v10)
	local v11

	if ownedEgg == nil then
		v11 = false
	else
		v11 = ownedEgg.Placement ~= nil
	end

	if not v11 then
		return false, "Egg not placed"
	end

	if EggState.IsReadyToHatch(v10) then
		return false, "Egg is already ready"
	end

	return true
end

function EggState.MayBuyGrowAll()
	for k, v10 in v2[localPlayer.UserId] or {} do
		if v10.Placement ~= nil and not EggState.IsReadyToHatch(k) then
			return true
		end
	end

	return false, "You have no growing eggs!"
end

local v10 = {
	{
		feed = eggWorld.OwnerShifted,
		vet = Eggs.SchemaValidation.RuntimeEggOwnerUpdate,
		complaint = "an owned egg write turned up malformed",
		apply = function(p)
			stampOwner(p.OwnerUserId) -- equivalent call inferred; original call site unknown
			local v11 = v2
			local ownerUserId2 = p.OwnerUserId
			local records = p.Records
			v11[ownerUserId2] = TableUtil.Copy(records, true)
			EggState.OwnerRefreshed:Fire(p.OwnerUserId, EggState.ReadOwnerEggs(p.OwnerUserId))
			tellOwned() -- equivalent call inferred; original call site unknown
		end
	},
	{
		feed = eggWorld.OwnerDropped,
		vet = Eggs.SchemaValidation.RuntimeEggOwnerClear,
		complaint = "an owned egg erase turned up malformed",
		apply = function(p)
			stampOwner(p.OwnerUserId) -- equivalent call inferred; original call site unknown
			dropOwner(p.OwnerUserId) -- equivalent call inferred; original call site unknown
		end
	},
	{
		feed = eggWorld.FieldEggShifted,
		vet = AreaEggs.SchemaValidation.AreaEggRecord,
		complaint = "a field egg write turned up malformed",
		apply = function(p)
			stampField(p.Uid) -- equivalent call inferred; original call site unknown
			v3[p.Uid] = TableUtil.Copy(p, true)
			EggState.FieldShifted:Fire((EggState.ReadFieldEgg(p.Uid)))
		end
	},
	{
		feed = eggWorld.FieldEggGone,
		vet = function(value)
			return typeof(value) == "string", "expected a uid string"
		end,
		complaint = "a field egg removal turned up malformed",
		apply = function(p)
			stampField(p) -- equivalent call inferred; original call site unknown
			v3[p] = nil
			EggState.FieldGone:Fire(p)
		end
	},
	{
		feed = eggWorld.FieldEggBatchShifted,
		vet = AreaEggs.SchemaValidation.AreaEggBatchUpdate,
		complaint = "a field egg batch turned up malformed",
		apply = function(p)
			for _, removedUid in ipairs(p.RemovedUids) do
				stampField(removedUid) -- equivalent call inferred; original call site unknown
				v3[removedUid] = nil
			end

			for _, updatedRecord in ipairs(p.UpdatedRecords) do
				stampField(updatedRecord.Uid) -- equivalent call inferred; original call site unknown
				v3[updatedRecord.Uid] = TableUtil.Copy(updatedRecord, true)
			end

			tellField() -- equivalent call inferred; original call site unknown
		end
	},
	{
		feed = eggWorld.FieldEggCarry,
		vet = AreaEggs.SchemaValidation.AreaEggCarryState,
		complaint = "a field egg carry state turned up malformed",
		apply = function(p)
			copy = TableUtil.Copy(p, true)
			EggState.CarryChanged:Fire(twin(copy))
		end
	},
	{
		feed = eggWorld.FieldEggRedeemVerdict,
		vet = AreaEggs.SchemaValidation.AreaEggClaimFeedback,
		complaint = "a field egg claim verdict turned up malformed",
		apply = function(p)
			v:AtInfo():Log("Area egg claim latency trace", {
				Stage = "CLIENT_FEEDBACK_RECEIVED",
				UserId = localPlayer.UserId,
				ServerTime = Workspace:GetServerTimeNow(),
				AssetCategory = p.AssetCategory,
				DisplayName = p.DisplayName
			})
			EggState.FieldClaimed:Fire(p)
		end
	},
	{
		feed = eggWorld.FieldEggCycleCountdown,
		vet = AreaEggResetCycle.SchemaValidation.SequencePayload,
		complaint = "a field egg reset sequence turned up malformed",
		apply = function(p)
			EggState.ResetCountdown:Fire(p)
		end
	},
	{
		feed = eggWorld.FieldEggRaritiesShown,
		vet = AreaEggResetCycle.SchemaValidation.RevealPayload,
		complaint = "a field egg rarity reveal turned up malformed",
		apply = function(p)
			EggState.RarityRevealed:Fire(p)
		end
	}
}

for _, v11 in ipairs(v10) do
	local v12 = v11
	v11.feed.OnClientEvent:Connect(function(p)
		local vet, v13 = v12.vet(p)

		if vet then
			v12.apply(p)
		else
			v:AtError():Log((`{v12.complaint}: {v13}`))
		end
	end)
end

Players.PlayerRemoving:Connect(function(player)
	stampOwner(player.UserId) -- equivalent call inferred; original call site unknown
	dropOwner(player.UserId) -- equivalent call inferred; original call site unknown
end)
task.spawn(keepAsking, "the owned egg snapshot", EggState.SyncOwnedEggs)
task.spawn(keepAsking, "the field egg snapshot", EggState.SyncFieldEggs)
return EggState