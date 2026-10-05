local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DataController = require(legacyControllers.DataController)
local modules = ReplicatedStorage.shared.modules
local totemcrafting = require(modules.library.totemcrafting)
local packages = ReplicatedStorage.packages
local Signal = require(packages.Signal)
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("TotemCrafting/Open", -1)
local remoteEvent2 = Net:RemoteEvent("TotemCrafting/StartCraft")
local remoteEvent3 = Net:RemoteEvent("TotemCrafting/ClaimCraft")
local remoteEvent4 = Net:RemoteEvent("TotemCrafting/Cut")
local TotemCraftingController = {
	Signals = {
		Inbound = {
			Open = Signal.new(),
			DataCacheUpdated = Signal.new()
		},
		Outbound = {
			Craft = Signal.new(),
			Claim = Signal.new(),
			Cut = Signal.new()
		}
	},
	DataCache = {}
}

function TotemCraftingController.Start(_)
	task.spawn(TotemCraftingController._bootDataObserver)
	task.defer(TotemCraftingController._bootSignals)
end

function TotemCraftingController.IsCraftingTotem(_: string)
	if TotemCraftingController.DataCache.TotemName then
		return true
	end

	return false
end

function TotemCraftingController.GetRemainingTime()
	if not (TotemCraftingController.DataCache.TotemName and TotemCraftingController.DataCache.StartedAt) then
		return nil
	end

	local startedAt = TotemCraftingController.DataCache.StartedAt
	local v = Workspace:GetServerTimeNow() - startedAt
	local v2 = totemcrafting[TotemCraftingController.DataCache.TotemName]

	if v2 then
		return v2.TimeToCraft - v
	end
end

function TotemCraftingController._bootSignals()
	remoteEvent.OnClientEvent:Connect(function()
		TotemCraftingController.Signals.Inbound.Open:Fire()
	end)
	TotemCraftingController.Signals.Outbound.Craft:Connect(function(p: string)
		remoteEvent2:FireServer(p)
	end)
	TotemCraftingController.Signals.Outbound.Claim:Connect(function()
		remoteEvent3:FireServer()
	end)
	TotemCraftingController.Signals.Outbound.Cut:Connect(function()
		remoteEvent4:FireServer()
	end)
end

function TotemCraftingController._bootDataObserver()
	DataController.PlayerDataReplicator:Observe({ "TotemCrafting" }, function(dataCache)
		if not dataCache then
			return
		end

		TotemCraftingController.DataCache = dataCache
		TotemCraftingController.Signals.Inbound.DataCacheUpdated:Fire()
	end)
end

return TotemCraftingController