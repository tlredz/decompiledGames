local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local FireworkConstants = require(ReplicatedStorage.Modules.Shared.Fireworks.FireworkConstants)
local Signal = require(ReplicatedStorage.Packages.Signal)
local FireworkController = {
	PaidRemainingUsesUpdated = Signal.new(),
	PlacedCountChanged = Signal.new()
}
local v = 0
local v2 = {
	GalaxySpiral = 0,
	HeartBurst = 0
}

-- equivalent calls inferred from this helper; original call sites unknown
local function setPlacedCount(p: number)
	v = p
	FireworkController.PlacedCountChanged:Fire(p)
end

local function getPurchaseCount(p)
	local countableProductForType = FireworkConstants.GetCountableProductForType(p)

	if countableProductForType == nil then
		return 0
	end

	return CountableDevProductController.GetCount(countableProductForType)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fireRemainingUsesUpdated(p)
	FireworkController.PaidRemainingUsesUpdated:Fire(p, FireworkController.GetPaidRemainingUses(p))
end

local function getConsumedCount(p)
	local clientReplica = ReplicatedDataController.clientReplica

	if clientReplica == nil or clientReplica.Data == nil then
		return v2[p] or 0
	end

	local liveOpsEventData = clientReplica.Data.LiveOpsEventData

	if liveOpsEventData ~= nil and liveOpsEventData[FireworkConstants.LIVE_OPS_EVENT_KEY] ~= nil then
		local v3 = FireworkConstants.CONSUMED_KEY_BY_TYPE[p]

		if v3 ~= nil then
			return liveOpsEventData[FireworkConstants.LIVE_OPS_EVENT_KEY][v3] or 0
		end
	end

	return v2[p] or 0
end

function FireworkController.GetPaidRemainingUses(p)
	if not FireworkConstants.RequiresInventory(p) then
		return 0
	end

	local countableProductForType = FireworkConstants.GetCountableProductForType(p)
	local v3 = countableProductForType == nil and 0 or CountableDevProductController.GetCount(countableProductForType)
	local clientReplica = ReplicatedDataController.clientReplica
	local v4

	if clientReplica == nil or clientReplica.Data == nil then
		v4 = v2[p] or 0
	else
		local liveOpsEventData = clientReplica.Data.LiveOpsEventData

		if liveOpsEventData == nil or liveOpsEventData[FireworkConstants.LIVE_OPS_EVENT_KEY] == nil then
			v4 = v2[p] or 0
		else
			local v5 = FireworkConstants.CONSUMED_KEY_BY_TYPE[p]

			if v5 == nil then
				v4 = v2[p] or 0
			else
				v4 = liveOpsEventData[FireworkConstants.LIVE_OPS_EVENT_KEY][v5] or 0
			end
		end
	end

	return (math.max(v3 * FireworkConstants.USES_PER_PURCHASE - v4, 0))
end

function FireworkController.GetPlacedCount()
	return v
end

function FireworkController.PromptPurchase(p, p2: string)
	local countableProductForType = FireworkConstants.GetCountableProductForType(p)

	if countableProductForType == nil then
		return "BACKEND_ERROR"
	end

	return CountableDevProductController.PromptPurchase(countableProductForType, p2)
end

function FireworkController.FrameworkInit() end

function FireworkController.FrameworkStart()
	for k, v3 in FireworkConstants.COUNTABLE_PRODUCT_BY_TYPE do
		local v4 = k
		CountableDevProductController.GetCountChangedSignal(v3):Connect(function()
			fireRemainingUsesUpdated(v4) -- equivalent call inferred; original call site unknown
		end)
	end

	ReplicatedDataController.GetClientReplicaPromise():andThen(function(object)
		for k, v3 in FireworkConstants.CONSUMED_KEY_BY_TYPE do
			local v4 = k
			object:OnSet({ "LiveOpsEventData", FireworkConstants.LIVE_OPS_EVENT_KEY, v3 }, function(value: number)
				v2[v4] = value or 0
				fireRemainingUsesUpdated(v4) -- equivalent call inferred; original call site unknown
			end)
			local liveOpsEventData = object.Data.LiveOpsEventData

			if liveOpsEventData ~= nil and liveOpsEventData[FireworkConstants.LIVE_OPS_EVENT_KEY] ~= nil then
				v2[k] = liveOpsEventData[FireworkConstants.LIVE_OPS_EVENT_KEY][v3] or 0
			end

			fireRemainingUsesUpdated(k) -- equivalent call inferred; original call site unknown
		end
	end)
	ReplicatedDataController.GetSessionReplicaPromise():andThen(function(object)
		object:OnSet({ FireworkConstants.SESSION_DATA_KEY }, function(p)
			if p ~= nil then
				setPlacedCount(p[FireworkConstants.SESSION_PLACED_COUNT_KEY] or 0) -- equivalent call inferred; original call site unknown
			end
		end)
		local v3 = object.Data[FireworkConstants.SESSION_DATA_KEY]

		if v3 ~= nil then
			setPlacedCount(v3[FireworkConstants.SESSION_PLACED_COUNT_KEY] or 0) -- equivalent call inferred; original call site unknown
		end
	end)
end

return FireworkController