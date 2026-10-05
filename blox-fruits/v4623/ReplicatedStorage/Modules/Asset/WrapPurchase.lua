local Controller = require(game.ReplicatedStorage.React.Components.ConfirmationDialog.Controller)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local GetRobuxShopItem = require(game.ReplicatedStorage.Modules.Asset.GetRobuxShopItem)
local Net = require(game.ReplicatedStorage.Modules.Net)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local confirmPurchase = nil
return function(data, callback)
	local success, result = pcall(function()
		assert(callback)
		local storageName = assert(data.StorageName)
		local v2 = assert(data.PurchaseAction, "Purchase action not supplied")
		local purchaseLocation = data.PurchaseLocation

		if purchaseLocation then
			assert(typeof(purchaseLocation) == "string")
		else
			task.spawn(error, (`You should be applying a purchase location {storageName}`))
		end

		assert(typeof(storageName) == "string")
		assert(typeof(v2) == "string")
		local funnelId = data.FunnelId

		if funnelId then
			assert(typeof(funnelId) == "string")
		end

		local v3 = assert(GetRobuxShopItem(storageName))
		local subtype = v3.subtype

		if v3.bundletype == "FruitSkin" then
			subtype = v3.bundletype
		end

		if confirmPurchase and confirmPurchase.Destroy then
			confirmPurchase:Destroy()
			confirmPurchase = nil
		end

		if v2 == "Store" then
			local function confirmPurchase2(p: string, callback2)
				return (Controller.new("Confirm Purchase", p, function(flag: boolean)
					callback2(flag)
				end, "Continue", "Cancel"))
			end

			local v4

			if "Store" == "Store" then
				v4 = Net:RemoteFunction("ShopNetworkRequest"):InvokeServer({
					Context = "CheckPurchase",
					Purchase = {
						StorageName = storageName,
						PurchaseLocation = purchaseLocation,
						ReceiverUserId = data.ReceiverUserId,
						FunnelId = funnelId
					}
				})
			else
				v4 = false
			end

			if subtype == "FruitSkin" then
				local v5 = assert(v3.subitem, (`No sub item for skin {v3.StorageName}`))
				local unwrapped = ItemConfig.match(v5, "Skin"):unwrap()
				local unwrapped2 = Modification.matchAdornee(unwrapped.Index.ItemId):unwrap()
				local unwrapped3 = ItemConfig.match(unwrapped2):unwrap()
				local arrowBracket = FormatUtil.arrowBracket(
					unwrapped3.Display.Name or unwrapped3.Index.StorageKey,
					"Green"
				)
				local arrowBracket2 = FormatUtil.arrowBracket(
					unwrapped.Display.Name or unwrapped.Index.StorageKey,
					"Green"
				)

				if v4 and "Store" == "Store" and v4.Redeem == false then
					local v6 = `You won't be able to redeem this as you do not own {arrowBracket} Fruit, or have already redeemed {arrowBracket2}.` .. [[


Are you sure you want to store it?]]

					local function fn(flag: boolean)
						callback(flag)
					end

					confirmPurchase = Controller.new("Confirm Purchase", v6, function(flag: boolean)
						fn(flag)
					end, "Continue", "Cancel")
				else
					if "Store" == "Gift" then
						local _ = data.ReceiverName
					end

					task.defer(callback, true)
				end
			else
				if subtype ~= "AuraSkin" then
					task.defer(callback, true)
					return
				end

				local v5 = assert(v3.subitem, (`No sub item for skin {v3.StorageName}`))
				local unwrapped = ItemConfig.match(v5, "Skin"):unwrap()
				local arrowBracket = FormatUtil.arrowBracket("Aura", "Green")
				local arrowBracket2 = FormatUtil.arrowBracket(
					unwrapped.Display.Name or unwrapped.Index.StorageKey,
					"Green"
				)

				if v4 and v2 == "Store" and v4.Redeem == false then
					local v6 = `You can't redeem {arrowBracket2}. Either you haven't learned the {arrowBracket} skill, or you have already redeemed it.` .. [[


Are you sure you want to continue?]]

					local function fn(flag: boolean)
						callback(flag)
					end

					confirmPurchase = Controller.new("Confirm Purchase", v6, function(flag: boolean)
						fn(flag)
					end, "Continue", "Cancel")
				else
					if v2 == "Gift" then
						local _ = data.ReceiverName
					end

					task.defer(callback, true)
				end
			end
		else
			task.defer(callback, true)
		end
	end)

	if not success then
		task.defer(callback, true)
		warn(result)
	end

	return function()
		if confirmPurchase and confirmPurchase.Destroy then
			confirmPurchase:Destroy()
			confirmPurchase = nil
		end
	end
end