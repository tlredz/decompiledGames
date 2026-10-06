local Gamepasses = require(script.Parent.Gamepasses)
local Potions = require(script.Parent.Potions)
local CommerceEffects = {
	Owns = function(p, p2: string)
		return p.Gamepasses and p.Gamepasses[p2] == true
	end
}

function CommerceEffects.GetPerks(p: string, p2)
	local perks = {}

	for k, gamepass in Gamepasses do
		if not CommerceEffects.Owns(p2, k) then
			continue
		end

		local v = p2.Commerce and p2.Commerce.PassOrigins and p2.Commerce.PassOrigins[k] == "Free"

		if not (not gamepass.PaidRandom or v or p2.Commerce and p2.Commerce.RandomBenefitsAllowed == true) then
			continue
		end

		local perk = gamepass.Perks[p]

		if perk then
			table.insert(perks, perk)
		end
	end

	return perks
end

function CommerceEffects.GetMultiplier(p: string, p2)
	local multiplier, v = Potions.GetMultiplier(p, p2)

	for _, v2 in CommerceEffects.GetPerks(p, p2) do
		if v2.Type == "Add" then
			multiplier += v2.Amount
		else
			v *= v2.Amount
		end
	end

	return multiplier, v
end

function CommerceEffects.WithoutPaidRandomModifiers(p)
	local commerce = p.Commerce or {}
	local clone = table.clone(p.Gamepasses or {})
	local clone2 = table.clone(commerce.Potions or {})
	local v = false

	for k, gamepass in Gamepasses do
		local v2 = commerce.PassOrigins and commerce.PassOrigins[k] == "Free"

		if not gamepass.PaidRandom or clone[k] ~= true or v2 or commerce.RandomBenefitsAllowed ~= true then
			continue
		end

		clone[k] = nil
		v = true
	end

	for _, v2 in Potions.GetActive(p) do
		local v3 = v2 and clone2[v2]
		local v4 = v2 and Potions.List[v2]

		if not (v3 and v3.Paid == true and Potions.IsPaidRandom(v4)) then
			continue
		end

		clone2[v2] = nil
		v = true
	end

	if not v then
		return p
	end

	for k, v2 in clone2 do
		if v2.Paid == true and Potions.IsPaidRandom(Potions.List[k]) then
			clone2[k] = nil
		end
	end

	local clone3 = table.clone(p)
	clone3.Gamepasses = clone
	clone3.Commerce = table.clone(commerce)
	clone3.Commerce.Potions = clone2
	return clone3
end

function CommerceEffects.HaveDifferentChances(items, items2)
	if typeof(items) ~= "table" or typeof(items2) ~= "table" then
		return true
	end

	for k, item in items do
		local item2 = items2[k]

		if not item2 then
			return true
		end

		if math.max(math.abs(item.Chance), (math.abs(item2.Chance))) * 1e-10 < math.abs(item.Chance - item2.Chance) then
			return true
		end
	end

	for k in items2 do
		if not items[k] then
			return true
		end
	end

	return false
end

return CommerceEffects