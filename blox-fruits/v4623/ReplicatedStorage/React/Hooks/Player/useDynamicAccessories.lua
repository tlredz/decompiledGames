local HttpService = game:GetService("HttpService")
local React = require(game.ReplicatedStorage.Packages.React)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local ItemReplication = require(game.ReplicatedStorage.React.Factories.Hooks.ItemReplication)
local AccessoriesShared = require(game.ReplicatedStorage.AccessoriesShared)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local v = ItemReplication.useAll(ItemReplication.KEYS.IS_EQUIPPED)
local v2 = ItemReplication.useAll(ItemReplication.KEYS.ACCESSORY_GRADE)
local v3 = ItemReplication.useAll(ItemReplication.KEYS.ACCESSORY_TYPE)
local v4 = ItemReplication.useAll(ItemReplication.KEYS.ACCESSORY_MODIFIERS, function(value: string?)
	if value and value ~= "" then
		return (value:split(","))
	end

	return {}
end)
local v5 = {
	[HttpService:GenerateGUID(false)] = {
		Equipped = true,
		Grade = 1,
		Modifiers = { "Punchy", "Brutal" },
		Name = "Ring of Striking",
		Type = "Trinket"
	},
	[HttpService:GenerateGUID(false)] = {
		Equipped = false,
		Grade = 2,
		Modifiers = { "Levitating", "Airborne" },
		Name = "Ring of Carving",
		Type = "Trinket"
	},
	[HttpService:GenerateGUID(false)] = {
		Equipped = false,
		Grade = 3,
		Modifiers = {},
		Name = "Ring of Carving",
		Type = "Trinket"
	},
	[HttpService:GenerateGUID(false)] = {
		Equipped = false,
		Grade = 3,
		Modifiers = {},
		Name = "Ring of Carving",
		Type = "Trinket"
	},
	[HttpService:GenerateGUID(false)] = {
		Equipped = false,
		Grade = 3,
		Modifiers = {},
		Name = "Ring of Carving",
		Type = "Trinket"
	},
	[HttpService:GenerateGUID(false)] = {
		Equipped = false,
		Grade = 0,
		Modifiers = {},
		Name = "Divine Cloak",
		Type = "Super"
	}
}
TableUtil.deepFreeze(v5)
return function()
	local v6 = v3()
	local v7 = {
		v6,
		v2(),
		v4(),
		(v({
			Index = {
				IdType = "Accessory"
			}
		}))
	}
	local v8 = React.useMemo(function()
		local replicatedAccessoryItemsByNetworkedUID = {}

		if not v6 then
			return nil
		end

		for _, v9 in v6 do
			local networkedUID = v9.NetworkedUID
			assert(networkedUID, (`bad UID for {v9.ItemId}`))
			local replicatedAccessoryItem = AccessoriesShared.getReplicatedAccessoryItem(v9.ItemId, networkedUID)

			if replicatedAccessoryItem then
				replicatedAccessoryItemsByNetworkedUID[networkedUID] = replicatedAccessoryItem
			end
		end

		table.freeze(replicatedAccessoryItemsByNetworkedUID)
		return replicatedAccessoryItemsByNetworkedUID
	end, v7)
	local v9 = useMockState("PlayerDynamicAccessories", v5)

	if v9 then
		return (v9:get())
	end

	return v8
end