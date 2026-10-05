local import = _G.import("eggCollection")
local import2 = _G.import("itemModules")
local Egg = {}

function Egg.purchaseEgg(p, p2, state, p3, p4)
	if not p2.Eggs[p3] then
		return "Egg not owned"
	end

	if state.Policies.ArePaidRandomItemsRestricted then
		return "Paid random items are restricted for this account"
	end

	if state.OpeningEgg then
		return "Already opening an egg"
	end

	local v = import:get(p3)

	if not v then
		return "Egg not found"
	end

	local currency = v.Currency

	if p2.Statistics[currency] < v.Cost * p4 then
		return "Not enough " .. currency
	end

	state.OpeningEgg = true
	p2.Statistics[currency] = p2.Statistics[currency] - v.Cost * p4
	return true, p, p2, state, p3, p4
end

function Egg.buyRestrictedPet(p, object, p2, p3, p4)
	if not object.Eggs[p3] then
		return "Egg not owned"
	end

	local v = import:get(p3)

	if not v then
		return "Egg not found"
	end

	if not v.Pets[p4] then
		return "Pet not in this egg"
	end

	local item = import2:getItem("Pet", p4)

	if not item then
		return "Pet not found"
	end

	local directPrice = item.DirectPrice

	if not directPrice then
		return "Pet cannot be purchased directly"
	end

	local currency = v.Currency

	if object.Statistics[currency] < directPrice then
		return "Not enough " .. currency
	end

	object.Statistics[currency] -= directPrice
	object:add("Inventory", "Pet", p4)
	return true, p, object, p2, p3, p4
end

function Egg.unlockEgg(_, p, _, p2)
	local v = import:get(p2)

	if not v then
		return "Egg not found"
	end

	if not v.UnlockCost then
		return "Egg cannot be unlocked this way"
	end

	if v.DefaultUnlocked or p.Eggs[p2] then
		return "Already unlocked"
	end

	if p.Statistics.Cash < v.UnlockCost then
		return "Not enough cash"
	end

	p.Statistics.Cash -= v.UnlockCost
	p.Eggs[p2] = true
	return true
end

return Egg