local v = {}
local frozen = table.freeze({ "Divine", "Eternal" })
v.Tiers = frozen
local frozen2 = table.freeze({
	["Light 8"] = "ArchAngel",
	["Dark 8"] = "World Burner",
	["Light 7"] = "Pegasus",
	["Dark 7"] = "Skeleton Horse"
})

local function matchesInput(p: string, p2: string)
	return p == p2 or frozen2[p] == p2
end

function v.Same(items, items2)
	if type(items) ~= "table" or type(items2) ~= "table" then
		return items == items2
	end

	for k, item in items do
		if not v.Same(item, items2[k]) then
			return false
		end
	end

	for k in items2 do
		if items[k] == nil then
			return false
		end
	end

	return true
end

function v.ResolveRecipes(p, p2)
	local result = {}
	local v2 = {}
	local result2 = {}

	for _, v3 in frozen do
		local v4 = p[v3]
		local v5 = type(v4) == "table"
		local v6 = {}

		for _, v7 in { "Light", "Dark", "Fused" } do
			local v8

			if v5 then
				v8 = v4[v7]
			end

			local v9

			if type(v8) == "string" then
				v9 = p2[v8]
			end

			if v9 and v8 ~= "" and not v6[v8] and v9.Rarity._id == v3 then
				v6[v8] = true
			else
				v5 = false
			end
		end

		if v5 then
			result[v3] = table.clone(v4)

			for k in v6 do
				if v2[k] then
					result2[v3] = "Ambiguous recipe"
					result2[v2[k]] = "Ambiguous recipe"
				end

				v2[k] = v3
			end
		else
			result2[v3] = "Configure three distinct, registered animals with the correct rarity"
		end
	end

	for k in result2 do
		result[k] = nil
	end

	return result, result2
end

function v.EggCount(data)
	local count = 0

	for _ in data.EggInventory do
		count += 1
	end

	if type(data.FusionEggReward) == "table" then
		count += 1
	end

	if data.Rift and type(data.Rift.PendingReward) == "table" then
		count += 1
	end

	return count
end

function v.CheckInput(data, p: string?, p2: string, p3, p4)
	if not data or type(data.ShrineFusion) ~= "table" then
		return nil, "DATA_LOADING", "Loading your data. Please wait."
	end

	local v2

	if p then
		v2 = data.Inventory[p]
	end

	if not v2 then
		return nil, "HOLD_PET", (`Hold a {p2} Divine or Eternal pet.`)
	end

	local v3 = nil
	local v4 = nil

	for _, v5 in frozen do
		local v6 = p3[v5]

		if not v6 then
			continue
		end

		local category = v2.Category
		local light = v6.Light

		if category == light or frozen2[category] == light then
			v3 = v5
			v4 = "Light"
		end

		local category2 = v2.Category
		local dark = v6.Dark

		if not (category2 == dark or frozen2[category2] == dark) then
			continue
		end

		v3 = v5
		v4 = "Dark"
	end

	if not v3 then
		return nil, "WRONG_ANIMAL", (`Hold a {p2} Divine or Eternal pet.`)
	end

	if data.ShrineFusion[v3] ~= false then
		return nil, "COMPLETED", (`{v3} Fusion already done. Once per account.`)
	end

	if v4 ~= p2 then
		return nil, "WRONG_PAD", (`Move to the {v4} pad.`)
	end

	if v2.IsFavorite then
		return nil, "FAVORITE", "Unfavorite this pet first. It will be used up."
	end

	if v2.InFuse or table.find(data.FusionSlots or {}, p) or table.find(data.VIPFusionSlots or {}, p) or table.find(
		data.PrivateFusionSlots or {},
		p
	) then
		return nil, "RESERVED", "Take this pet out of the other fuse machine."
	end

	if table.find(data.EquippedAssets or {}, p) then
		return nil, "IN_PEN", "Remove this pet from your pen, then hold it."
	end

	if v2.SpecialLuckyBlockColumn or v2.PendingEggName then
		return nil, "RESERVED", "This pet is busy. Use another pet."
	end

	if v2.IsStolenDNA and not p4.AllowStolenDNA then
		return nil, "STOLEN_DNA", "Use a pet that isn't Stolen DNA."
	end

	if type(v2.Scale) ~= "number" or v2.Scale ~= v2.Scale or v2.Scale <= 0 or v2.Scale == 1e999 then
		return nil, "INVALID_PET", "Pet error. Rejoin and try again."
	end

	if v.EggCount(data) >= p4.EggLimit then
		return nil, "EGG_FULL", "Your egg inventory is full. Make room first."
	end

	local v5 = p2 == "Light" and "Dark" or "Light"
	return v3, "READY", (`Partner needs {p3[v3][v5]} on the {v5} pad. Both pets will be used up.`)
end

function v.BuildPatches(p, list, data)
	if #list ~= 2 or list[1] == list[2] then
		return false, "TWO_PLAYERS", "One player on each pad."
	end

	local v2 = {}

	for k, v3 in list do
		local input = data.Inputs[k]
		local v4 = p[v3]
		local v5 = k == 1 and "Light" or "Dark"
		local v6, v7, v8 = v.CheckInput(v4, input.Uid, v5, data.Recipes, data.Options)

		if not v6 then
			return false, v7, v8
		end

		if v6 ~= data.Tier then
			return false, "MISMATCH", "Both pets must be Divine, or both Eternal."
		end

		if not v.Same(v4.Inventory[input.Uid], input.Snapshot) then
			return false, "PET_CHANGED", "Pet changed. Hold it and try again."
		end

		local grant = data.Grants[k]

		if v4.EggInventory[grant.Uid] or grant.Record.AssetCategory ~= data.Recipes[v6].Fused then
			return false, "INVALID_REWARD", "Reward check failed."
		end

		local v9 = v4.Inventory[input.Uid]
		v2[k] = v9 ~= nil and v9.CreatorTemporary == true
	end

	if v2[1] ~= v2[2] then
		return false, "TEMPORARY_MISMATCH", "Both pets must be temporary creator pets, or neither."
	end

	local result = {}

	for k, v3 in list do
		local input = data.Inputs[k]
		local grant = data.Grants[k]

		if v2[k] then
			grant.Record.CreatorTemporary = true
		end

		local v4 = {
			Remove = {
				[input.Uid] = true
			},
			MutateStore = 0
		}
		local v7 = k

		function v4:MutateStore()
			local clone = table.clone(self.EggInventory)
			clone[grant.Uid] = grant.Record
			self.EggInventory = clone

			if v2[v7] and data.MarkTemporary then
				data.MarkTemporary(self)
			end

			local clone2 = table.clone(self.ShrineFusion)
			clone2[data.Tier] = {
				TransactionId = data.Id,
				EggUid = grant.Uid,
				CompletedAt = data.CompletedAt
			}
			self.ShrineFusion = clone2
		end

		result[v3] = v4
	end

	return result
end

return table.freeze(v)