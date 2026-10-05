local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StickyBombUtil = require(ReplicatedStorage.Modules.Shared.LiveOps.StickyBombUtil)
local Summer2026Util = require(ReplicatedStorage.Modules.Shared.LiveOps.Summer2026Util)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local Signal = require(ReplicatedStorage.Packages.Signal)
local StickyBombController = {
	StickyBombCountUpdated = Signal.new()
}
local v = { "LiveOpsEventData", "SummerCarnival2026", "EarnedTickets" }
local v2 = { "LiveOpsEventData", "SummerCarnival2026", "StickyBombsConsumed" }

-- equivalent calls inferred from this helper; original call sites unknown
local function getState()
	local clientReplica = ReplicatedDataController.clientReplica

	if clientReplica == nil then
		return nil
	end

	local summerCarnival2026 = clientReplica.Data.LiveOpsEventData.SummerCarnival2026
	return {
		earnedTickets = summerCarnival2026.EarnedTickets or 0,
		consumed = summerCarnival2026.StickyBombsConsumed or 0,
		getCountableDevProductCount = CountableDevProductController.GetCount,
		isFeatureUnlocked = UnlockableController.IsFeatureUnlocked
	}
end

function StickyBombController.GetStickyBombCount()
	local state = getState() -- equivalent call inferred; original call site unknown

	if state == nil then
		return 0
	end

	return StickyBombUtil.GetStickyBombCount(state)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refresh()
	StickyBombController.StickyBombCountUpdated:Fire(StickyBombController.GetStickyBombCount())
end

function StickyBombController.FrameworkInit() end

function StickyBombController.FrameworkStart()
	UnlockableController.OnItemUnlocked:Connect(refresh)
	CountableDevProductController.GetCountChangedSignal(CountableDevProducts.STICKY_SITUATION):Connect(refresh)

	for k in Summer2026Util.GetDevProductValues() do
		CountableDevProductController.GetCountChangedSignal(k):Connect(refresh)
	end

	ReplicatedDataController.GetClientReplicaPromise():andThen(function(object)
		object:OnSet(v2, refresh)
		object:OnSet(v, refresh)
		refresh() -- equivalent call inferred; original call site unknown
	end)
end

return StickyBombController