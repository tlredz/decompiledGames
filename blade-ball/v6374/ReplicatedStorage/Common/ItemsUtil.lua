local ItemsUtil = {}
local ItemLoader = require(script.ItemLoader)

function shuffleTable(list)
	for i = #list, 2, -1 do
		local v = math.random(1, i)
		local v2 = list[v]
		local v3 = list[i]
		list[i] = v2
		list[v] = v3
	end
end

function ItemsUtil:getSword(p: string)
	if ItemLoader.swords[p] then
		return ItemLoader.swords[p]
	end
end

function ItemsUtil.getSwordsInTier(_, p)
	if ItemLoader.swordNamesByTier[p] then
		return ItemLoader.swordNamesByTier[p]
	end

	return warn((`No sword tier exists for {p}`))
end

function ItemsUtil:getExplosion(p: string)
	if ItemLoader.explosions[p] then
		return ItemLoader.explosions[p]
	end

	return warn((`No explosion exists for {p}`))
end

function ItemsUtil.getExplosionsInTier(_, p)
	if ItemLoader.explosionNamesByTier[p] then
		return ItemLoader.explosionNamesByTier[p]
	end

	return warn((`No explosion tier exists for {p}`))
end

function ItemsUtil:getCoins(amount: number, icon: string)
	return {
		icon = icon,
		amount = amount,
		name = `{amount} Coins`,
		category = "coins"
	}
end

function ItemsUtil:getEmote(p: string)
	if ItemLoader.emotes[p] then
		return ItemLoader.emotes[p]
	end

	return warn((`No emote exists for {p}`))
end

function ItemsUtil:getAbility(p: string)
	if ItemLoader.abilities[p] then
		return ItemLoader.abilities[p]
	end

	return warn((`No ability exists for {p}`))
end

function ItemsUtil:registerSword(p: string, value: number?, value2: number?)
	return {
		info = ItemsUtil:getSword(p),
		chance = value or 0,
		secondaryChance = value2 or 1
	}
end

function ItemsUtil.registerSwordsIn(_, p, p2: number?, flag: boolean?)
	local result = {}

	for _, v in next, ItemLoader.swordNamesByTier[p], nil do
		local sword = ItemsUtil:registerSword(v, p2)

		if flag or not sword.info.isUnobtainable then
			result[#result + 1] = sword
		end
	end

	return result
end

function ItemsUtil:registerExplosion(p: string, value: number?, value2: number?)
	return {
		info = ItemsUtil:getExplosion(p),
		chance = value or 0,
		secondaryChance = value2 or 1
	}
end

function ItemsUtil.registerExplosionsIn(_, p, p2: number?)
	local result = {}

	for _, v in next, ItemLoader.explosionNamesByTier[p], nil do
		result[#result + 1] = ItemsUtil:registerExplosion(v, p2)
	end

	return result
end

function ItemsUtil.registerCoins(_, p: string, value: number?, value2: number?)
	return {
		info = ItemsUtil:getCoins(p),
		chance = value or 1,
		secondaryChance = value2 or 1
	}
end

function ItemsUtil.registerEmote(_, p: string, value: number?, value2: number?)
	return {
		info = ItemsUtil:getEmote(p),
		chance = value or 0,
		secondaryChance = value2 or 1
	}
end

function ItemsUtil.registerAbility(_, p: string, value: number?, value2: number?)
	return {
		info = ItemsUtil:getAbility(p),
		chance = value or 0,
		secondaryChance = value2 or 1
	}
end

function ItemsUtil.registerMass(_, items)
	local result = {}

	for _, item in next, items, nil do
		if typeof(next(item)) == "number" then
			for _, v in next, item, nil do
				result[#result + 1] = v
			end
		else
			result[#result + 1] = item
		end
	end

	return result
end

local random = Random.new()

function ItemsUtil.getRewardForCrate(_, items, flag: boolean, list)
	local total = 0
	local v = {}

	for _, item in next, items, nil do
		if typeof(item) ~= "table" then
			continue
		end

		for _, v2 in next, item, nil do
			if list and table.find(list, v2.info.name) then
				continue
			end

			total += v2[flag and "secondaryChance" or "chance"]
			v[#v + 1] = v2
		end
	end

	local v2 = random:NextNumber() * total

	for _, v3 in next, v, nil do
		v2 -= v3.chance

		if v2 <= 0 then
			return v3.info
		end
	end
end

return ItemsUtil