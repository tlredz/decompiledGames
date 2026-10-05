local RunService = game:GetService("RunService")
local ItemReplicationService = require(game.ReplicatedStorage.ItemReplicationService)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
require(game.ReplicatedStorage.Modules.FruitSkillUtil)
local KEYS = require(game.ReplicatedStorage.ItemReplicationService.KEYS)

function newInterface(p)
	return {
		onUpdateLoop = function(callback)
			if not RunService:IsRunning() then
				return function() end
			end

			while not ItemReplicationService.IsInitialized do
				task.wait()
			end

			assert(
				ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT,
				"ItemReplicationService not initialized"
			)
			local v = ItemReplicationService:ConnectOnKeyChanged(p, callback)
			local thread = task.spawn(function()
				local items = ItemReplicationService:GetItems(p)

				if not items then
					return
				end

				for _, item in items do
					local v2 = item
					local success, result = pcall(function()
						callback(v2.ItemId, v2.NetworkedUID, v2.Value)
					end)

					if not success then
						warn((`[ItemReplication] Error in onUpdateLoop callback for key {p}, itemId {item.ItemId}, networkedUID {item.NetworkedUID}: {result}`))
					end
				end
			end)
			return function()
				v()
				task.cancel(thread)
			end
		end,
		readClient = function(p2: number, p3: string?)
			if not RunService:IsRunning() then
				return nil
			end

			while not ItemReplicationService.IsInitialized do
				task.wait()
			end

			assert(
				ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT,
				"ItemReplicationService not initialized"
			)
			return (ItemReplicationService:ReadItem(p, p2, p3))
		end,
		writeClient = function(p2: number, p3: string?, p4)
			if not RunService:IsRunning() then
				return
			end

			while not ItemReplicationService.IsInitialized do
				task.wait()
			end

			assert(
				ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT,
				"ItemReplicationService not initialized"
			)
			ItemReplicationService:WriteTempItem(p, p2, p3, p4)
		end,
		replicate = function(p2, p3: number, p4: string?, p5)
			if not RunService:IsRunning() then
				return
			end

			while not ItemReplicationService.IsInitialized do
				task.wait()
			end

			assert(
				ItemReplicationService.IsInitialized and ItemReplicationService.IS_SERVER,
				"ItemReplicationService not initialized"
			)
			ItemReplicationService:ReplicateItem(p2, p, p3, p4, p5)
		end,
		onItemChanged = function(p2: number, p3: string?, callback)
			if not RunService:IsRunning() then
				return function() end
			end

			while not ItemReplicationService.IsInitialized do
				task.wait()
			end

			assert(
				ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT,
				"ItemReplicationService not initialized"
			)
			return ItemReplicationService:ConnectOnItemKeyChanged(p, p2, p3, callback)
		end,
		onChanged = function(callback, p2)
			if not RunService:IsRunning() then
				return function() end
			end

			while not ItemReplicationService.IsInitialized do
				task.wait()
			end

			local function fn(p3: number, p4: string?, p5)
				if p2 and not ItemConfig.Query.check(p3, p2) then
					return
				end

				callback(p3, p4, p5)
			end

			assert(
				ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT,
				"ItemReplicationService not initialized"
			)
			return ItemReplicationService:ConnectOnKeyChanged(p, fn)
		end
	}
end

return {
	CombatData = newInterface(KEYS.COMBAT_DATA),
	FishModifiers = newInterface(KEYS.FISH_MODIFIERS),
	FishWeight = newInterface(KEYS.FISH_WEIGHT),
	HasClicked = newInterface(KEYS.HAS_CLICKED),
	IsPreferred = newInterface(KEYS.IS_PREFERRED),
	IsEquipped = newInterface(KEYS.IS_EQUIPPED),
	IsStackLeader = newInterface(KEYS.IS_STACK_LEADER),
	IsNew = newInterface(KEYS.IS_NEW),
	Mastery = newInterface(KEYS.MASTERY),
	NewCount = newInterface(KEYS.NEW_COUNT),
	Quantity = newInterface(KEYS.QUANTITY),
	UpgradeCount = newInterface(KEYS.UPGRADE_COUNT),
	IsOwned = newInterface(KEYS.IS_OWNED)
}