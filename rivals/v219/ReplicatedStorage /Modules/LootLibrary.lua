local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self:_Init()
	return self
end

function class.GetCareerLevelsRewardMilestone(_)
	return 10
end

function class.GetCareerLevelsRewardData(_)
	return {
		Name = "Experience",
		Weapon = "IsRandom",
		Quantity = 1
	}
end

function class:GetCostToLevelUp(p, p2)
	return (math.clamp(math.floor(10 * (1 - (not p2 and 0 or p2 / self:GetXPRequiredToLevelUp(p)))), 1, 10))
end

function class.GetCostToRefreshDailyShop(_, p)
	return (math.min(24, 3 * 2 ^ p))
end

function class:GetNextWeaponLevelReward(p, p2)
	for i = p + 1, 99 do
		local weaponLevelReward = self:GetWeaponLevelReward(i, p2)

		if weaponLevelReward then
			return weaponLevelReward, i
		end
	end
end

function class:GetWeaponLevelReward(p, weapon)
	if p == 5 then
		return {
			Name = "Key",
			Quantity = 1
		}
	elseif p == 50 then
		return {
			Name = "White",
			Weapon = weapon
		}
	elseif p == 99 then
		return {
			Name = "Black",
			Weapon = weapon
		}
	end

	if p % 10 == 0 then
		return
	end

	local _ = p % 5 == 0
end

function class:GetXPRequiredToLevelUp(p)
	return (math.max(50, (math.floor(5 + 4 * (p - 1) + (math.min(p, 99) / 40) ^ 2 * 100))))
end

function class.GetRecoverStreakCost(_, p)
	return (math.clamp(5 * 2 ^ p, 1, 100))
end

function class:CanCosmeticBeEarnedRandomly(p, p2, p3)
	local cosmetic = CosmeticLibrary.Cosmetics[p]
	local v = cosmetic.Type == "Skin" and { cosmetic.ItemName } or ShopLibrary.OwnableWeapons

	for _, v2 in pairs(v) do
		if (cosmetic.Type ~= "Finisher" or ItemLibrary.Items[v2].CanEliminate) and (p3[v2] or ShopLibrary:IsWeaponReleased(
			v2,
			CONSTANTS.WEAPON_EARLY_ACCESS_TIME_OFFSET
		)) and not CosmeticLibrary:OwnsCosmetic(p2, p, v2) then
			return true
		end
	end
end

function class.GetWeightedLootboxOutcome(_, items)
	local total = 0
	local v = {}

	for _, item in pairs(items) do
		total += item.Weight
		table.insert(v, { item.Weight, item.Reward })
	end

	table.sort(v, function(a, b)
		return a[1] < b[1]
	end)
	local v2 = math.random() * total
	local total2 = 0

	for k, v3 in pairs(v) do
		total2 += v3[1]

		if v2 < total2 or k == #v then
			return v3[2]
		end
	end

	return v[#v] or nil
end

function class:GetLootboxPossibilities(p, items, p2, p3, value)
	if not p then
		return items, {}, {}
	end

	local v = value or "IsRandom"
	local v2 = {}
	local v3 = {}
	local v4 = {}

	local function attempt_cosmetic(item, p4)
		local name = item.Reward.Name
		local cosmetic = CosmeticLibrary.Cosmetics[name]

		if cosmetic.Type == "Skin" and not (p3[cosmetic.ItemName] or ShopLibrary:IsWeaponReleased(
			cosmetic.ItemName,
			CONSTANTS.WEAPON_EARLY_ACCESS_TIME_OFFSET
		)) then
			return
		end

		if cosmetic.ItemName and not (p4 or p3[cosmetic.ItemName]) then
			table.insert(v3, item)
			return
		end

		local v5

		if v == "IsRandom" then
			v5 = not self:CanCosmeticBeEarnedRandomly(name, p2, p3)
		elseif v == "IsUniversal" then
			v5 = CosmeticLibrary:OwnsCosmeticUniversally(p2, name)
		else
			v5 = CosmeticLibrary:OwnsCosmetic(p2, name, v)
		end

		if v5 then
			table.insert(v4, item)
		else
			table.insert(v2, item)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function attempt_reward(item)
		local name = item.Reward.Name

		if CosmeticLibrary.Rewards[name].Type ~= "Weapon" then
			table.insert(v2, item)
		elseif p3[name] then
			table.insert(v4, item)
		else
			table.insert(v2, item)
		end
	end

	local function populate(p4)
		for _, item in pairs(items) do
			if CosmeticLibrary.Cosmetics[item.Reward.Name] then
				attempt_cosmetic(item, p4)
			elseif CosmeticLibrary.Rewards[item.Reward.Name] then
				attempt_reward(item) -- equivalent call inferred; original call site unknown
			else
				assert(false, item.Reward.Name)
			end
		end
	end

	populate()

	if #v2 == 0 then
		v3 = {}
		v4 = {}
		populate(true)
	end

	return v2, v3, v4
end

function class:GetUnlockedWeaponsForSelection(items, p, p2, p3)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function is_valid_option(p4)
		if not p2 then
			return true
		end

		local cosmetic = CosmeticLibrary.Cosmetics[p2]
		local v = not CosmeticLibrary:OwnsCosmetic(p3, p2, p4)
		local v2

		if cosmetic.Type == "Skin" and p4 ~= cosmetic.ItemName then
			v2 = true
		elseif cosmetic.Type == "Finisher" then
			v2 = not ItemLibrary.Items[p4].CanEliminate
		else
			v2 = false
		end

		return v and not v2
	end

	local names = {}

	for _, item in pairs(items) do
		-- equivalent call inferred; original call site unknown
		if is_valid_option(item.Name) then
			table.insert(names, item.Name)
		end
	end

	if #names > 0 then
		return names
	end

	if not p then
		return {}
	end

	local result = {}

	for _, v in pairs(ShopLibrary:GetReleasedOwnableWeapons(CONSTANTS.WEAPON_EARLY_ACCESS_TIME_OFFSET)) do
		-- equivalent call inferred; original call site unknown
		if is_valid_option(v) then
			table.insert(result, v)
		end
	end

	return result
end

function class:GetRandomUnlockedWeapon(...)
	local unlockedWeaponsForSelection = self:GetUnlockedWeaponsForSelection(...)

	if unlockedWeaponsForSelection and #unlockedWeaponsForSelection ~= 0 then
		return unlockedWeaponsForSelection[math.random(#unlockedWeaponsForSelection)]
	end

	return nil
end

function class:_Init() end

return class._new()