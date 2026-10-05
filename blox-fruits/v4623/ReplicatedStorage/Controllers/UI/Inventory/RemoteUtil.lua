local Players = game:GetService("Players")
local Future = require(game.ReplicatedStorage.Packages.Future)
local Result = require(game.ReplicatedStorage.Packages.Result)
local Option = require(game.ReplicatedStorage.Packages.Option)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Types = require(script.Parent.Types)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local Net = require(game.ReplicatedStorage.Modules.Net)
local MaterialActions = require(game.ReplicatedStorage.Modules.Data.MaterialActions)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemReplicationService = require(game.ReplicatedStorage.ItemReplicationService)
local ModificationsMenu = require(game.ReplicatedStorage.Controllers.UI.ModificationsMenu)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Controller"):tag("UI"):tag("Inventory"):display():traceback():build()
local KEYS = require(game.ReplicatedStorage.ItemReplicationService.KEYS)
local commF_ = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local remoteFunction = Net:RemoteFunction("ConsumablesNetworkRF")
local remoteFunction2 = Net:RemoteFunction("UseMaterial")

function getUID(p: number, p2: string?)
	return p2 or `ITEMID_{p}`
end

local RemoteUtil = {
	getUID = getUID,
	getTiles = function()
		return Future.from(function()
			v.info("called getTiles()")

			while ItemReplicationService.IsInitialized ~= true do
				task.wait()
			end

			assert(
				ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT,
				"bad ItemReplicationService"
			)
			local result = {}
			local items = ItemReplicationService:GetItems(KEYS.QUANTITY)

			if items then
				for _, item in items do
					if item.Value <= 0 then
						continue
					end

					local tile = Types.Types.Tile.new(item.ItemId, item.NetworkedUID)

					if tile:isOk() then
						local unwrapped = tile:unwrap()
						result[getUID(unwrapped.ItemId, unwrapped.NetworkedUID)] = unwrapped
					else
						warn("Failed to convert legacy item in ItemChanged event:", tile:unwrapErr())
					end
				end
			end

			local items2 = ItemReplicationService:GetItems(KEYS.EQUIPPED_SKIN)

			if items2 then
				for _, item in items2 do
					if not item.Value then
						continue
					end

					local tile = Types.Types.Tile.new(item.Value)

					if tile:isOk() then
						local unwrapped = tile:unwrap()
						result[getUID(unwrapped.ItemId, unwrapped.NetworkedUID)] = unwrapped
					else
						warn("Failed to convert legacy item in ItemChanged event:", tile:unwrapErr())
					end
				end
			end

			table.freeze(result)
			return result
		end)
	end,
	connectOnTileUpdate = function(callback)
		while ItemReplicationService.IsInitialized ~= true do
			task.wait()
		end

		assert(ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT, "bad ItemRepService")

		local function getIfIncluded(p: number, p2: string?)
			if (ItemReplicationService:ReadItem(KEYS.QUANTITY, p, p2) or 0) > 0 then
				return true
			end

			if p2 ~= nil then
				return false
			end

			for _, v2 in ItemReplicationService:GetItems(KEYS.EQUIPPED_SKIN) do
				if v2.Value == p then
					return true
				end
			end

			return false
		end

		local v2 = ItemReplicationService:ConnectOnKeyChanged(KEYS.QUANTITY, function(p: number, p2: string?, p3, p4)
			local tile = Types.Types.Tile.new(p, p2)

			if tile:isOk() then
				callback(
					tile:unwrap(),
					p3 and p3 > 0 and (not p4 or p4 <= 0) and "Added" or getIfIncluded(p, p2) and "QuantityChanged" or "Removed"
				)
			else
				warn("Failed to convert legacy item in ItemChanged event:", tile:unwrapErr())
			end
		end)
		local v3 = ItemReplicationService:ConnectOnKeyChanged(KEYS.EQUIPPED_SKIN, function(_: number, _: string?, p, p2)
			if p then
				local tile = Types.Types.Tile.new(p)

				if tile:isOk() then
					callback(tile:unwrap(), "Added")
				else
					warn("Failed to convert legacy item in ItemChanged event:", tile:unwrapErr())
					return
				end
			end

			if p2 then
				local v4

				if (ItemReplicationService:ReadItem(KEYS.QUANTITY, p2, nil) or 0) > 0 then
					v4 = true
				else
					local flag = true

					for _, v5 in ItemReplicationService:GetItems(KEYS.EQUIPPED_SKIN) do
						if v5.Value ~= p2 then
							continue
						end

						v4 = true
						flag = false
						break
					end

					if flag then
						v4 = false
					end
				end

				if not v4 then
					local tile = Types.Types.Tile.new(p2)

					if tile:isOk() then
						callback(tile:unwrap(), "Removed")
					else
						warn("Failed to convert legacy item in ItemChanged event:", tile:unwrapErr())
					end
				end
			end
		end)
		return function()
			task.spawn(v2)
			task.spawn(v3)
		end
	end
}

function RemoteUtil.connectOnTileRemoved(callback)
	return RemoteUtil.connectOnTileUpdate(function(p, p2)
		if p2 == "Removed" then
			callback(p)
		end
	end)
end

function RemoteUtil.invokeFruitSwitch(value: string)
	return Future.from(function()
		v.info((`CommF-1: {value}`))
		local v2 = value:gsub("Permanent ", "")
		local Global = require(game.ReplicatedStorage.Global)
		Global.fruitSwapTimeLockout = tick() + 5
		commF_:InvokeServer("SwitchFruit", v2)
		local Global2 = require(game.ReplicatedStorage.Global)
		Global2.fruitSwapTimeLockout = tick() + 1
		return v2
	end)
end

function RemoteUtil.clearNewCountAsync(p, p2: string?)
	commF_:InvokeServer("ClearNewItem", p, p2)
end

function RemoteUtil.invokeAction(p, p2: number, p3: string?, flag: boolean?)
	local extended = v.extend(".invokeAction")
	extended.info((`call fn: (action: {p}, itemId: {p2}, networkedUID: {p3}, isEquipped: {flag})`))
	return Future.from(function()
		return Result.try(function()
			local storageKey = ItemId.getDataFromId(p2):unwrap().StorageKey
			local unwrapped = ItemConfig.match(p2):unwrap()

			if p == PseudoEnum.InventoryAction.EquipConsumable then
				extended.trace((`Unstoring consumable: {storageKey}`))
				return remoteFunction:InvokeServer({
					Context = "UnstoreConsumable",
					StorageName = storageKey
				})
			end

			if p == PseudoEnum.InventoryAction.EquipItem then
				if flag then
					GlobalUtil.tryGetCurrentlyStoringItem()

					if Option.map(Option.from(Players.LocalPlayer.Character), function(instance)
						return Option.map(Option.from(instance:FindFirstChild(storageKey)), function(instance2)
							local holding = instance2:FindFirstChild("Holding")

							if holding and holding:IsA("BoolValue") then
								return holding.Value
							end

							return false
						end):unwrapOr(false)
					end):unwrapOr(false) then
						GlobalUtil.testWarnAsync("Trying to store item while holding an ability")
					end

					GlobalUtil.setCurrentlyStoringItem(storageKey)
					local v4

					if p3 then
						v4 = p3
					else
						v4 = storageKey
					end

					local v5 = commF_:InvokeServer("StoreItem", v4)
					extended.trace((`Stored item: {storageKey}`))
					GlobalUtil.setCurrentlyStoringItem(nil)
					return v5
				else
					extended.trace((`Loading item: {storageKey}`))
					local v2 = {}

					if unwrapped.Index.IdType == "Fish" then
						table.insert(v2, "Fish")
					elseif unwrapped.Index.IdType == "Bait" then
						table.insert(v2, "Usables")
					end

					if p3 then
						storageKey = p3
					end

					if not (#v2 > 0) then
						v2 = nil
					end

					return commF_:InvokeServer("LoadItem", storageKey, v2)
				end
			else
				if p == PseudoEnum.InventoryAction.EquipFruit then
					extended.trace("Loading fruit")
					return commF_:InvokeServer("LoadFruit", storageKey)
				end

				if p == PseudoEnum.InventoryAction.ViewMoreFruitAccessories then
					local availableModifications = {}
					local modification = Modification.Data.Modification.fromItemReplication(Players.LocalPlayer)
					local adornee = Modification.Data.Adornee.fromItemReplication(Players.LocalPlayer)
					TableUtil.append(availableModifications, Modification.getUnlocked(modification, adornee))

					if unwrapped.Index.IdType == "Skin" and unwrapped.Skin then
						TableUtil.append(availableModifications, Modification.getEquippable(modification, adornee))
						TableUtil.append(availableModifications, Modification.getEquipped(modification, adornee))
						TableUtil.append(availableModifications, Modification.getUsable(modification, adornee))
						TableUtil.deduplicate(availableModifications)
						table.sort(availableModifications)
						assert(ModificationsMenu.IsInitialized, "bad ModificationsMenu")
						local v4

						if unwrapped.Skin.Type == "Fruit" or unwrapped.Skin.Type == "Sword" then
							v4 = {
								Type = "MovesetSkin",
								MovesetType = unwrapped.Skin.Type,
								SelectedModificationId = unwrapped.Index.ItemId,
								AvailableModifications = availableModifications
							}
						else
							v4 = {
								Type = "AuraSkin",
								SelectedModificationId = unwrapped.Index.ItemId,
								AvailableModifications = availableModifications
							}
						end

						ModificationsMenu:Open(v4)

						if ModificationsMenu:IsOpen() then
							ModificationsMenu.OnClosed:Wait()
						end
					else
						local unwrapped2 = Modification.matchAdornee(unwrapped.Index.ItemId):unwrap()
						TableUtil.append(availableModifications, Modification.getAllModifications(unwrapped2))
						TableUtil.deduplicate(availableModifications)
						table.sort(availableModifications)
						assert(ModificationsMenu.IsInitialized, "bad ModificationsMenu")
						ModificationsMenu:Open({
							Type = "MovesetSkin",
							MovesetType = "Fruit",
							SelectedModificationId = unwrapped.Index.ItemId,
							AvailableModifications = availableModifications
						})
					end
				else
					if p == PseudoEnum.InventoryAction.RedeemStoredGamepass then
						extended.trace("Redeeming stored gamepass")
						return commF_:InvokeServer("RedeemStoredGamepass", storageKey, "Gift")
					end

					if p == PseudoEnum.InventoryAction.OpenBox then
						extended.trace("Redeeming stored gamepass")
						return commF_:InvokeServer("RedeemStoredGamepass", storageKey, "Gift")
					end

					if p == PseudoEnum.InventoryAction.EquipHolidayGift then
						extended.trace("Unstoring holiday gift")
						return commF_:InvokeServer("UnstoreHolidayGift", storageKey)
					end

					if p == PseudoEnum.InventoryAction.EquipDragonToken then
						extended.trace("Equipping dragon token")
						return commF_:InvokeServer("ClassicDragonConvert", "Activate")
					end

					if p == PseudoEnum.InventoryAction.RedeemPhysicalDragonToken then
						extended.trace("Redeeming physical dragon token")
						return commF_:InvokeServer("ClassicDragonConvert", "Physical")
					end

					if p == PseudoEnum.InventoryAction.BuildCampfire then
						extended.trace("Building campfire")
						return remoteFunction2:InvokeServer(
							storageKey,
							assert(MaterialActions[storageKey], (`no action for {storageKey}`))
						)
					end

					if p ~= PseudoEnum.InventoryAction.Favorite then
						error((`TODO: Handle action type '{p}'`))
						return
					end

					assert(ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT, "bad item rep")
					local v2 = ItemReplicationService:ReadItem(ItemReplicationService.KEYS.IS_FAVORITED, p2, p3) == true
					print((`favoriting -> {not v2}`))
					commF_:InvokeServer("SetFavoriteItem", p2, p3, not v2)
				end
			end
		end)
	end)
end

return RemoteUtil