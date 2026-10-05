local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Assets = require(ReplicatedStorage.Data.Assets)
require(ReplicatedStorage.Shared.Types.AssetItem)
local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
local Audio = require(ReplicatedStorage.Shared.Audio)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local Message = require(ReplicatedStorage.Client.Message)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
require(ReplicatedStorage.Packages.Trove)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local Streamable = require(ReplicatedStorage.Packages.Streamable)
local streamable = Streamable.Streamable
local Log = require(ReplicatedStorage.Packages.Log)
local hex = Color3.fromRGB(0, 255, 8):ToHex()
local hex2 = Color3.fromRGB(255, 170, 0):ToHex()
local hex3 = Color3.fromRGB(207, 58, 255):ToHex()
return {
	Start = function()
		local stands = Workspace.Stands
		assert(stands:IsA("Folder"), "Workspace.Stands must be a Folder")
		local prompts = stands.Prompts
		assert(prompts:IsA("Folder"), "Workspace.Stands.Prompts must be a Folder")
		local localPlayer = Players.LocalPlayer
		local v = Log.new()

		local function getInventoryItemData(UID: string)
			local v2 = Save.Await()
			local inventory = v2 and v2.Inventory

			if not inventory then
				return nil
			end

			local v3 = inventory[UID]

			if not v3 then
				return nil
			end

			local v4, v5 = TryCall(AssetItems.Decode, v3)

			if v4 then
				return v5
			end

			v:AtDebug():Log((`Skipped invalid seller inventory item {UID}`))
			return nil
		end

		local function isEquipped(p: string)
			local v2 = Save.Await()
			return v2 ~= nil and table.find(v2.EquippedAssets, p) ~= nil
		end

		local function computeItemValue(p)
			local salePrice = AssetItems.SalePrice(p)

			if localPlayer:GetAttribute("VIP") then
				salePrice *= 2
			end

			return salePrice
		end

		local function getEggItemData(UID: string)
			local v2 = Save.Await()
			local eggInventory = v2 and v2.EggInventory

			if eggInventory == nil then
				return nil, nil, nil
			end

			local v3 = eggInventory[UID]

			if v3 == nil or v3.Placement ~= nil then
				return nil, nil, nil
			end

			local decoded = EggRecords.Decode(v3)
			return
				EggRecords.ToAssetItemData(decoded),
				EggRecords.SellPrice(decoded),
				EggRecords.DisplayNameWithWeight(decoded)
		end

		local function formatPrice(p: number)
			return string.format("<font color='#%s'>$%s</font>", hex, Simple.FormatCompact(p, "."))
		end

		local function promptSellHeld()
			local character = localPlayer.Character

			if not character then
				Message.Notice("No item equipped.")
				return
			end

			local tool = character:FindFirstChildWhichIsA("Tool")
			local UID

			if tool then
				UID = tool:GetAttribute("UID")
			end

			if tool == nil or type(UID) ~= "string" then
				Message.Notice("No item equipped.")
				return
			end

			local v2 = nil
			local itemType = tool:GetAttribute("ItemType")

			if itemType == "AssetEgg" then
				local eggItemData, price, displayName = getEggItemData(UID)
				v2 = eggItemData ~= nil and price ~= nil and displayName ~= nil and {
					displayName = displayName,
					isFavorite = false,
					itemData = eggItemData,
					kind = "egg",
					price = price,
					uid = UID
				} or v2
			elseif itemType == "Asset" then
				local inventoryItemData = getInventoryItemData(UID)

				if inventoryItemData ~= nil then
					local v3 = Save.Await()
					local v4

					if v3 == nil then
						v4 = false
					else
						v4 = table.find(v3.EquippedAssets, UID) ~= nil
					end

					if not (v4 or inventoryItemData.InFuse) then
						v2 = {
							displayName = Assets.Directory[inventoryItemData.Category].DisplayName or inventoryItemData.Category,
							isFavorite = inventoryItemData.IsFavorite == true,
							itemData = inventoryItemData,
							kind = "pet",
							price = 0,
							uid = 0
						}
						local salePrice = AssetItems.SalePrice(inventoryItemData)

						if localPlayer:GetAttribute("VIP") then
							salePrice *= 2
						end

						v2.price = salePrice
						v2.uid = UID
					end
				end
			end

			if v2 == nil then
				Message.Notice("No item equipped.")
			elseif v2.isFavorite then
				local v3 = string.format("<font color='#%s'>favorited</font>", hex3)
				Message.Notice(string.format("You can't sell %s items.", v3))
			else
				local itemData = v2.itemData
				local hex4 = Assets.Directory[itemData.Category].Rarity.Color:ToHex()
				local v3 = string.format(
					"Would you like to sell %s <font color='#%s'>%s</font> for %s?",
					v2.kind,
					hex4,
					v2.displayName,
					formatPrice(v2.price)
				)

				if Message.Confirm(v3) then
					Remotes.PetSatchel.SellPet:FireServer({ v2.uid })
					Audio.Chime("Prompt")
				end
			end
		end

		local function getSellableInventory()
			local result = {}
			local v2 = Save.Await()
			local inventory = v2 and v2.Inventory

			if not inventory then
				return result
			end

			for k, v3 in pairs(inventory) do
				local v4, itemData = TryCall(AssetItems.Decode, v3)

				if not (v4 and itemData.IsFavorite ~= true) then
					continue
				end

				local v6 = Save.Await()
				local v7

				if v6 == nil then
					v7 = false
				else
					v7 = table.find(v6.EquippedAssets, k) ~= nil
				end

				if not (v7 or itemData.InFuse) then
					table.insert(result, {
						uid = k,
						itemData = itemData
					})
				end
			end

			return result
		end

		local function promptSellAll()
			local sellableInventory = getSellableInventory()

			if #sellableInventory == 0 then
				Message.Notice("You don't have any pets in your inventory.")
				return
			end

			local total = 0
			local uids = {}

			for _, v2 in ipairs(sellableInventory) do
				local itemData = v2.itemData
				local salePrice = AssetItems.SalePrice(itemData)

				if localPlayer:GetAttribute("VIP") then
					salePrice *= 2
				end

				total += salePrice
				table.insert(uids, v2.uid)
			end

			local v2 = string.format(
				"Would you like to sell <font color='#%s'>%d pets</font> for %s?",
				hex2,
				#sellableInventory,
				formatPrice(total)
			)

			if Message.Confirm(v2) then
				Remotes.PetSatchel.SellEveryPet:FireServer(uids)
				Audio.Chime("Prompt")
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindPrompt(p: string, _)
			streamable.new(prompts, p):Observe(function(p2, maid)
				local v2 = streamable.new(p2, "ProximityPrompt")
				maid:Add(function()
					v2:Destroy()
				end)
				maid:Add(v2:Observe(function(p3, _)
					p3.Enabled = false
				end))
			end)
		end

		bindPrompt("SellHeldAsset") -- equivalent call inferred; original call site unknown
		bindPrompt("SellAll") -- equivalent call inferred; original call site unknown
	end
}