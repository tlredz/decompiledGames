local HatchLuck = {}
local General = require(script.Parent:WaitForChild("General"))
local hatchUpgrade = General.HatchUpgrade or {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StringService = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("StringService"))
HatchLuck.BasePrice = hatchUpgrade.InitialCost or 5
HatchLuck.PricePerUpgrade = hatchUpgrade.IncrementCost or 5
HatchLuck.PriceStepPerBonus = hatchUpgrade.CostIncrementPerFive or 25
HatchLuck.LuckPerUpgrade = 1
HatchLuck.BonusEvery = 5
HatchLuck.BonusLuck = 5

function HatchLuck.GetMultiplier(p)
	local v = math.max(0, (math.floor(tonumber(p) or 0)))
	local v2 = HatchLuck.BonusLuck - HatchLuck.LuckPerUpgrade
	return 1 + v * HatchLuck.LuckPerUpgrade + math.floor(v / HatchLuck.BonusEvery) * v2
end

function HatchLuck.GetPrice(p)
	local v = math.max(0, (math.floor(tonumber(p) or 0)))
	local bonusEvery = HatchLuck.BonusEvery
	local v2 = math.floor(v / bonusEvery)
	local v3 = v - v2 * bonusEvery
	local v4 = bonusEvery * (v2 * (v2 - 1) / 2) + v2 * (v3 + 1)
	return HatchLuck.BasePrice + v * HatchLuck.PricePerUpgrade + v4 * HatchLuck.PriceStepPerBonus
end

HatchLuck.MaxBuyLimit = 1000

function HatchLuck.GetMaxAffordable(p, p2)
	local v = math.max(0, (math.floor(tonumber(p) or 0)))
	local v2 = math.max(0, tonumber(p2) or 0)
	local price = HatchLuck.GetPrice(v)
	local count = 0
	local total = 0

	while count < HatchLuck.MaxBuyLimit and not (v2 < total + price) do
		total += price
		count += 1
		price += HatchLuck.PricePerUpgrade + math.floor((v + count) / HatchLuck.BonusEvery) * HatchLuck.PriceStepPerBonus
	end

	return count, total
end

function HatchLuck.PlainMultiplier(p)
	local multiplier = HatchLuck.GetMultiplier(p)

	if multiplier % 1 == 0 then
		return StringService.AddComma(multiplier)
	end

	local v = math.floor(multiplier)
	return StringService.AddComma(v) .. string.format("%.1f", multiplier - v):sub(2)
end

HatchLuck.FreeUpgradesPerTier = { 100, 300, 500 }
HatchLuck.FreeUpgradesPerPack = HatchLuck.FreeUpgradesPerTier[1]
HatchLuck.BuysPerTier = 3
HatchLuck.MaxTier = 3

function HatchLuck.GetFreeUpgrades(p)
	local v = math.clamp(math.floor(tonumber(p) or 1), 1, HatchLuck.MaxTier)
	return HatchLuck.FreeUpgradesPerTier[v] or HatchLuck.FreeUpgradesPerPack
end

function HatchLuck.GetFreeUpgradesForBuys(p)
	return HatchLuck.GetFreeUpgrades(HatchLuck.GetPackTier(p))
end

HatchLuck.PackProductKeys = { "x10LuckUpgrade", "x10LuckUpgrade2", "x10LuckUpgrade3" }

function HatchLuck.GetPackTier(p)
	return (math.clamp(
		math.floor(math.max(0, (math.floor(tonumber(p) or 0))) / HatchLuck.BuysPerTier) + 1,
		1,
		HatchLuck.MaxTier
	))
end

function HatchLuck.GetPaidUpgrades(p, p2)
	return (math.max(math.max(0, (math.floor(tonumber(p) or 0))) - math.max(0, (math.floor(tonumber(p2) or 0))), 0))
end

function HatchLuck.GetPackProductKey(p)
	return HatchLuck.PackProductKeys[HatchLuck.GetPackTier(p)]
end

function HatchLuck.FormatMultiplier(p)
	return string.format("%.1fx", HatchLuck.GetMultiplier(p))
end

HatchLuck.SettingAttribute = "Setting_LuckMultiplier"

function HatchLuck.MultiplierEnabled(instance)
	return not instance or instance:GetAttribute(HatchLuck.SettingAttribute) ~= false
end

function HatchLuck.EffectiveUpgrades(p, p2)
	if HatchLuck.MultiplierEnabled(p) then
		return p2
	end

	return 0
end

function HatchLuck.GetMultiplierFor(p, p2)
	return HatchLuck.GetMultiplier(HatchLuck.EffectiveUpgrades(p, p2))
end

HatchLuck.EventAttribute = "HatchLuckEventMultiplier"
HatchLuck.EventUntilAttribute = "HatchLuckEventUntil"
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

function HatchLuck.EventMultiplier()
	local attribute = tonumber(ReplicatedStorage2:GetAttribute(HatchLuck.EventAttribute))

	if attribute and not (attribute <= 1) then
		return attribute
	end

	return 1
end

local Pets = require(script.Parent:WaitForChild("Pets"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local pets = ReplicatedStorage3:WaitForChild("Assets"):WaitForChild("Pets")
HatchLuck.JackpotPower = 1.5
HatchLuck.FadePower = 3
HatchLuck.MinWeight = 0
HatchLuck.RequireAsset = true

function HatchLuck.GetTotalLuck(p, p2)
	return (math.max((tonumber(p) or 1) * HatchLuck.GetMultiplier(p2), 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetPoolLuck(p)
	if p and typeof(p.PoolLuck) == "table" then
		return p.PoolLuck
	end

	return nil
end

local function GetPoolPetConfig(p, p2)
	local poolLuck = GetPoolLuck(p) -- equivalent call inferred; original call site unknown
	local pets2 = poolLuck and poolLuck.Pets
	local selected = pets2 and pets2[p2]

	if typeof(selected) == "table" then
		return selected
	end

	return nil
end

function HatchLuck.GetSampleSize(p, p2)
	local pet = Pets[p]

	if not pet then
		return 0
	end

	local poolLuck = GetPoolLuck(p2) -- equivalent call inferred; original call site unknown
	local pets2 = poolLuck and poolLuck.Pets
	local v2 = pets2 and pets2[p]

	if typeof(v2) ~= "table" then
		v2 = nil
	end

	local sampleSize = v2 and tonumber(v2.SampleSize)

	if sampleSize and sampleSize > 0 then
		return sampleSize
	end

	return tonumber(pet.SampleSize) or 0
end

function HatchLuck.GetWeight(p, p2, p3, p4, p5)
	local v = tonumber(p) or 0
	local v2 = tonumber(p2) or 0

	if v <= 0 or v2 <= 0 then
		return 0
	end

	local v3 = tonumber(p3) or HatchLuck.JackpotPower
	local v4 = tonumber(p4) or HatchLuck.FadePower
	local minWeight = tonumber(p5)

	if minWeight == nil then
		minWeight = HatchLuck.MinWeight
	end

	local v5

	if v2 <= v then
		v5 = (v2 / v) ^ v3
	else
		v5 = (v / v2) ^ v4
	end

	return (math.max(v5, minWeight))
end

function HatchLuck.GetPool(p)
	local pets2

	if p and typeof(p.Pets) == "table" then
		pets2 = p.Pets or nil
	end

	local childNames = {}

	for childName, pet in pairs(Pets) do
		local v = HatchLuck.GetSampleSize(childName, p) > 0

		if v and pets2 then
			v = table.find(pets2, childName) ~= nil
		elseif v and pet.GlobalHatch == false then
			v = false
		end

		if v and HatchLuck.RequireAsset then
			v = pets:FindFirstChild(childName) ~= nil
		end

		if v then
			table.insert(childNames, childName)
		end
	end

	table.sort(childNames, function(a, b)
		local sampleSize = HatchLuck.GetSampleSize(a, p)
		local sampleSize2 = HatchLuck.GetSampleSize(b, p)

		if sampleSize == sampleSize2 then
			return a < b
		end

		return sampleSize < sampleSize2
	end)
	return childNames
end

function HatchLuck.GetOdds(p, p2, p3)
	local v = math.max(tonumber(p3) or 1, 1)
	local poolLuck = GetPoolLuck(p2) -- equivalent call inferred; original call site unknown
	local jackpotPower = poolLuck and poolLuck.JackpotPower or HatchLuck.JackpotPower
	local fadePower = poolLuck and poolLuck.FadePower or HatchLuck.FadePower
	local minWeight = poolLuck and poolLuck.MinWeight

	if minWeight == nil then
		minWeight = HatchLuck.MinWeight
	end

	local total = 0
	local result = {}

	for _, petName in HatchLuck.GetPool(p2) do
		local sampleSize = HatchLuck.GetSampleSize(petName, p2)
		local weight = HatchLuck.GetWeight(sampleSize, p, jackpotPower, fadePower, minWeight)

		if not (weight > 0) then
			continue
		end

		total += weight
		local poolLuck2 = GetPoolLuck(p2) -- equivalent call inferred; original call site unknown
		local pets2 = poolLuck2 and poolLuck2.Pets
		local poolConfig = pets2 and pets2[petName]

		if typeof(poolConfig) ~= "table" then
			poolConfig = nil
		end

		table.insert(result, {
			PetName = petName,
			SampleSize = sampleSize,
			PoolConfig = poolConfig,
			Weight = weight,
			Cumulative = total
		})
	end

	if total <= 0 then
		return {}, 0
	end

	local v3 = total
	local v4 = {}
	local v5 = 1
	local flag = false

	for _ = 1, #result do
		local v6 = false

		for _, v7 in result do
			if v4[v7] then
				continue
			end

			local pet = Pets[v7.PetName]
			local poolConfig = v7.PoolConfig
			local maxChance = tonumber(poolConfig and poolConfig.MaxChance) or tonumber(pet and pet.MaxChance)

			if not maxChance or maxChance ~= maxChance or v3 <= 0 then
				continue
			end

			local v8 = poolConfig and poolConfig.HardCap == true
			local v9 = p < v7.SampleSize * 0.1

			if not (v8 or v9) then
				continue
			end

			local v10 = math.clamp(maxChance * (v8 and 1 or v) / 100, 0, 1)

			if not (v10 < v7.Weight / v3 * v5) then
				continue
			end

			v4[v7] = v10
			v5 = math.max(0, v5 - v10)
			v3 = math.max(0, v3 - v7.Weight)
			v6 = true
			flag = true
		end

		if not v6 then
			break
		end
	end

	if flag and v3 <= 0 and v5 > 1e-10 then
		return {}, 0
	end

	local total2 = 0

	for _, v6 in result do
		if flag then
			v6.Chance = v4[v6] or not (v3 > 0) and 0 or v6.Weight / v3 * v5 or 0
			v6.Weight = v6.Chance
			total2 += v6.Weight
			v6.Cumulative = total2
		else
			v6.Chance = v6.Weight / total
		end
	end

	if flag then
		return result, total2
	end

	return result, total
end

function HatchLuck.GetBoostedOdds(p, p2, p3)
	local v = tonumber(p2) or 1

	if v <= 1 then
		return HatchLuck.GetOdds(p, p3)
	end

	local odds, v2 = HatchLuck.GetOdds(p, p3)
	local odds2, v3 = HatchLuck.GetOdds((tonumber(p) or 1) * v, p3, v)

	if v2 <= 0 or v3 <= 0 or #odds2 == 0 then
		return odds2, v3
	end

	local v4 = {}

	for _, odd in odds do
		v4[odd.PetName] = math.min(1, odd.Chance * v)
		local petName = odd.PetName
		local poolLuck = GetPoolLuck(p3) -- equivalent call inferred; original call site unknown
		local pets2 = poolLuck and poolLuck.Pets
		local v6 = pets2 and pets2[petName]

		if typeof(v6) ~= "table" then
			v6 = nil
		end

		if not (v6 and v6.HardCap == true) then
			continue
		end

		local pet = Pets[odd.PetName]
		local maxChance = tonumber(v6.MaxChance) or tonumber(pet and pet.MaxChance)

		if maxChance and maxChance == maxChance then
			v4[odd.PetName] = math.min(v4[odd.PetName], (math.clamp(maxChance / 100, 0, 1)))
		end
	end

	for _, odd in odds2 do
		if v4[odd.PetName] == nil then
			v4[odd.PetName] = 0
		end
	end

	local v5 = {}
	local v6 = {}

	for _ = 1, #odds2 do
		local total = 0
		local total2 = 0

		for _, odd in odds2 do
			if v5[odd.PetName] then
				total += v4[odd.PetName]
			else
				total2 += odd.Chance
			end
		end

		local v7 = math.max(0, 1 - total)
		local v8 = false

		for _, odd in odds2 do
			local petName = odd.PetName

			if v5[petName] then
				v6[petName] = v4[petName]
			else
				local v9 = not (total2 > 0) and 0 or odd.Chance / total2 * v7

				if v4[petName] * 1.000000001 < v9 then
					v5[petName] = true
					v6[petName] = v4[petName]
					v8 = true
				else
					v6[petName] = v9
				end
			end
		end

		if not v8 then
			break
		end
	end

	local total = 0
	local result = {}

	for _, odd in odds2 do
		local v7 = v6[odd.PetName] or 0

		if not (v7 > 0) then
			continue
		end

		total += v7
		table.insert(result, {
			PetName = odd.PetName,
			Weight = v7,
			Chance = v7,
			Cumulative = total
		})
	end

	return result, total
end

function HatchLuck.RollPet(p, p2, p3, value)
	local boostedOdds, v = HatchLuck.GetBoostedOdds(p, value or 1, p2)

	if v <= 0 then
		return nil, nil
	end

	local v2 = (p3 or Random.new()):NextNumber() * v

	for _, boostedOdd in boostedOdds do
		if v2 <= boostedOdd.Cumulative then
			return boostedOdd.PetName, boostedOdd.Chance
		end
	end

	local boostedOdd = boostedOdds[#boostedOdds]
	return boostedOdd.PetName, boostedOdd.Chance
end

function HatchLuck.FormatChance(p)
	if p and not (p <= 0) then
		return string.format("1 in %d", (math.max(1, (math.floor(1 / p + 0.5)))))
	end

	return "1 in ?"
end

local General2 = require(script.Parent:WaitForChild("General"))

local function PickWeighted(items, p)
	local total = 0

	for _, item in pairs(items) do
		total += math.max(tonumber(item) or 0, 0)
	end

	if total <= 0 then
		return nil, 0
	end

	local v = (p or Random.new()):NextNumber() * total
	local total2 = 0

	for k, item in pairs(items) do
		total2 += math.max(tonumber(item) or 0, 0)

		if v <= total2 then
			return k, math.max(tonumber(item) or 0, 0) / total
		end
	end

	return nil, 0
end

function HatchLuck.IsPremiumEgg(p)
	return General2.PremiumEggs ~= nil and General2.PremiumEggs[p] ~= nil
end

function HatchLuck.RollPremiumPet(p, p2)
	local v = General2.PremiumEggs and General2.PremiumEggs[p]

	if not v then
		return nil, nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Eligible(childName)
		return not not Pets[childName] and not (HatchLuck.RequireAsset and not pets:FindFirstChild(childName))
	end

	if typeof(v.Pets) == "table" then
		local pets2 = {}

		for k, pet in pairs(v.Pets) do
			-- equivalent call inferred; original call site unknown
			if Eligible(k) then
				pets2[k] = pet
			end
		end

		return PickWeighted(pets2, p2)
	else
		if typeof(v.Rarities) ~= "table" then
			return nil, nil
		end

		local v2 = {}
		local rarities = {}

		for k, pet in pairs(Pets) do
			if not (pet.Rarity and v.Rarities[pet.Rarity]) then
				continue
			end

			-- equivalent call inferred; original call site unknown
			if not Eligible(k) then
				continue
			end

			v2[pet.Rarity] = v2[pet.Rarity] or {}
			table.insert(v2[pet.Rarity], k)
		end

		for k, rarity in pairs(v.Rarities) do
			if v2[k] then
				rarities[k] = rarity
			end
		end

		local v3, v4 = PickWeighted(rarities, p2)

		if not v3 then
			return nil, nil
		end

		local v5 = v2[v3]
		table.sort(v5)
		return v5[(p2 or Random.new()):NextInteger(1, #v5)], v4 / #v5
	end
end

return HatchLuck