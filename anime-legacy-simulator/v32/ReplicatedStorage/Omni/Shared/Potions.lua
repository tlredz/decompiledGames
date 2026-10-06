local Potions = {
	List = {
		["Mythical Potion"] = {
			Index = 1,
			Type = "Multi",
			Effect = "Mythical Chance",
			Rarity = "Item",
			Icon = "rbxassetid://77773427476044",
			Amount = 2,
			Duration = 600,
			Description = "2x Mythical weight when opening stars. Lasts 10 minutes."
		},
		["Secret Potion"] = {
			Index = 2,
			Type = "Multi",
			Effect = "Secret Chance",
			Amount = 2,
			Duration = 600,
			Rarity = "Item",
			Icon = "rbxassetid://117413910431899",
			Description = "2x Secret weight when opening stars. Lasts 10 minutes."
		},
		["Shiny Potion"] = {
			Index = 3,
			Type = "Multi",
			Effect = "Shiny Chance",
			Amount = 1.5,
			Duration = 600,
			Rarity = "Item",
			Icon = "rbxassetid://131408543767360",
			Description = "+50% Shiny chance when opening stars. Lasts 10 minutes."
		},
		["Luck Boost"] = {
			Index = 4,
			Type = "Add",
			Effect = "Luck",
			Amount = 1.25,
			Duration = 600,
			Rarity = "Item",
			Icon = "rbxassetid://103477867366251",
			Description = "+1.25 Luck. Lasts 10 minutes."
		},
		["Super Luck Boost"] = {
			Index = 5,
			Type = "Add",
			Effect = "Luck",
			Amount = 2.5,
			Duration = 600,
			Rarity = "Item",
			Icon = "rbxassetid://132445103103426",
			Description = "+2.5 Luck. Lasts 10 minutes."
		},
		["Speed Boost"] = {
			Index = 6,
			Type = "Multi",
			Effect = "Star Open Speed",
			Amount = 1.25,
			Duration = 600,
			Rarity = "Item",
			Icon = "rbxassetid://140422126728074",
			Description = "+25% Star Open Speed. Lasts 10 minutes."
		},
		["Super Speed Boost"] = {
			Index = 7,
			Type = "Multi",
			Effect = "Star Open Speed",
			Amount = 1.5,
			Duration = 600,
			Rarity = "Item",
			Icon = "rbxassetid://73491772378871",
			Description = "+50% Star Open Speed. Lasts 10 minutes."
		},
		["Yen Boost"] = {
			Index = 8,
			Type = "Multi",
			Effect = "Yen",
			Amount = 1.5,
			Duration = 600,
			Rarity = "Item",
			Icon = "rbxassetid://122764651452269",
			Description = "+50% Yen gained. Lasts 10 minutes."
		},
		["Super Yen Boost"] = {
			Index = 9,
			Type = "Multi",
			Effect = "Yen",
			Amount = 2,
			Duration = 600,
			Rarity = "Item",
			Icon = "rbxassetid://120395214309886",
			Description = "+100% Yen gained. Lasts 10 minutes."
		},
		["Damage Boost"] = {
			Index = 10,
			Type = "Multi",
			Effect = "Damage",
			Amount = 1.5,
			Duration = 600,
			Rarity = "Item",
			Icon = "rbxassetid://102578521313576",
			Description = "+50% global damage. Lasts 10 minutes."
		},
		["Super Damage Boost"] = {
			Index = 11,
			Type = "Multi",
			Effect = "Damage",
			Amount = 2,
			Duration = 600,
			Rarity = "Item",
			Icon = "rbxassetid://118775138102887",
			Description = "+100% global damage. Lasts 10 minutes."
		},
		["Drops Boost"] = {
			Index = 12,
			Type = "Add",
			Effect = "Drops",
			Amount = 0.5,
			Duration = 600,
			Rarity = "Item",
			Icon = "rbxassetid://112726019774410",
			Description = "+0.5 item drop amount. Lasts 10 minutes."
		},
		["Super Drops Boost"] = {
			Index = 13,
			Type = "Add",
			Effect = "Drops",
			Amount = 1,
			Duration = 600,
			Rarity = "Item",
			Icon = "rbxassetid://133039844340164",
			Description = "+1 item drop amount. Lasts 10 minutes."
		}
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function IsDuration(value)
	return typeof(value) == "number" and value > 0 and value < 9007199254740991
end

function Potions.IsPaidRandom(p)
	return typeof(p) == "table" and (p.PaidRandom == true or p.Effect == "Luck" or p.Effect == "Gacha Luck" or p.Effect == "Shiny Chance" or p.Effect == "Mythical Chance" or p.Effect == "Secret Chance")
end

function Potions.IsConfigured(data)
	if typeof(data) ~= "table" or typeof(data.Effect) ~= "string" or data.Type ~= "Add" and data.Type ~= "Multi" then
		return false
	end

	local amount = data.Amount
	local v

	if typeof(amount) == "number" and amount > 0 then
		v = amount < 9007199254740991
	else
		v = false
	end

	if not v then
		return false
	end

	return IsDuration(data.Duration)
end

function Potions.NormalizeData(p)
	local commerce = p.Commerce

	if typeof(commerce) ~= "table" then
		return
	end

	if typeof(commerce.Potions) ~= "table" then
		commerce.Potions = {}
	end

	for k, potion in commerce.Potions do
		if typeof(potion) == "table" then
			local remaining = potion.Remaining
			local v

			if typeof(remaining) == "number" and remaining > 0 then
				v = remaining < 9007199254740991
			else
				v = false
			end

			if v then
				potion.Paused = potion.Paused == true
				potion.Paid = potion.Paid == true
				continue
			end
		end

		commerce.Potions[k] = nil
	end
end

function Potions.GetActive(p)
	local result = {}
	local commerce = p.Commerce

	if not commerce or typeof(commerce.Potions) ~= "table" then
		return result
	end

	for k, potion in commerce.Potions do
		local v = Potions.List[k]

		if not (Potions.IsConfigured(v) and typeof(potion) == "table") then
			continue
		end

		local remaining = potion.Remaining
		local v2

		if typeof(remaining) == "number" and remaining > 0 then
			v2 = remaining < 9007199254740991
		else
			v2 = false
		end

		if not (v2 and potion.Paused ~= true and (not Potions.IsPaidRandom(v) or not potion.Paid or commerce.RandomBenefitsAllowed == true)) then
			continue
		end

		local v3 = result[v.Effect]
		local v4 = v3 and Potions.List[v3]

		if not v4 or v.Amount > v4.Amount or v.Amount == v4.Amount and k < v3 then
			result[v.Effect] = k
		end
	end

	return result
end

function Potions.GetMultiplier(p: string, p2)
	local active = Potions.GetActive(p2)
	local v = active[p] and Potions.List[active[p]]

	if not v then
		return 0, 1
	end

	local selected = v.Type ~= "Add" and 0 or v.Amount

	if v.Type == "Multi" then
		return selected, v.Amount
	end

	return selected, 1
end

function Potions.Advance(p, value: number)
	local v

	if typeof(value) == "number" and value > 0 then
		v = value < 9007199254740991
	else
		v = false
	end

	if not v then
		return false
	end

	local v2 = false

	while value > 0 do
		local active = Potions.GetActive(p)

		if not next(active) then
			break
		end

		local v3 = value

		for _, v4 in active do
			v3 = math.min(v3, p.Commerce.Potions[v4].Remaining)
		end

		for _, v4 in active do
			local potion = p.Commerce.Potions[v4]
			potion.Remaining = math.max(0, potion.Remaining - v3)

			if potion.Remaining <= 0 then
				p.Commerce.Potions[v4] = nil
			end
		end

		value -= v3
		v2 = true
	end

	return v2
end

return Potions