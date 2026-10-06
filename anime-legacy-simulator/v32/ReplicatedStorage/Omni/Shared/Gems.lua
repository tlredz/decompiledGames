local v = {}

local function IsBalance(value)
	return typeof(value) == "number" and value >= 0 and value <= 9007199254740991
end

function v.GetName(p)
	if typeof(p) ~= "table" or p.Type ~= "Item" and p.Type ~= "Items" and p.Type ~= "Currency" and p.Type ~= "Currencies" then
		return nil
	end

	if p.Name == "FreeGems" or p.Name == "Free Gems" then
		return "Free Gems"
	end

	if p.Name == "PaidGems" or p.Name == "Paid Gems" then
		return "Paid Gems"
	end

	if p.Name == "Gems" then
		return "Gems"
	end

	return nil
end

function v.Read(data)
	local list = data and data.Items and data.Items.List

	if typeof(list) ~= "table" then
		return nil
	end

	local freeGems = list["Free Gems"] or 0
	local paidGems = list["Paid Gems"] or 0
	local v2

	if typeof(freeGems) == "number" and freeGems >= 0 then
		v2 = freeGems <= 9007199254740991
	else
		v2 = false
	end

	if not v2 then
		return nil
	end

	local v3

	if typeof(paidGems) == "number" and paidGems >= 0 then
		v3 = paidGems <= 9007199254740991
	else
		v3 = false
	end

	if not v3 then
		return nil
	end

	local v4, v5

	if data.Economy and data.Economy.Version == 2 then
		v4 = freeGems + paidGems

		if typeof(v4) == "number" and v4 >= 0 then
			v5 = v4 <= 9007199254740991
		else
			v5 = false
		end

		if v5 then
			return {
				Free = freeGems,
				Paid = paidGems,
				Total = freeGems + paidGems
			}
		end

		return nil
	else
		local freeGems2 = data.FreeGems or 0
		local paidGems2 = data.PaidGems or 0
		local v6

		if typeof(freeGems2) == "number" and freeGems2 >= 0 then
			v6 = freeGems2 <= 9007199254740991
		else
			v6 = false
		end

		if not v6 then
			return nil
		end

		local v7

		if typeof(paidGems2) == "number" and paidGems2 >= 0 then
			v7 = paidGems2 <= 9007199254740991
		else
			v7 = false
		end

		if not v7 then
			return nil
		end

		freeGems += freeGems2
		paidGems += paidGems2
		v4 = freeGems + paidGems

		if typeof(v4) == "number" and v4 >= 0 then
			v5 = v4 <= 9007199254740991
		else
			v5 = false
		end

		if v5 then
			return {
				Free = freeGems,
				Paid = paidGems,
				Total = freeGems + paidGems
			}
		end

		return nil
	end

	return nil
end

function v.Reward(p, p2: string?)
	local name = v.GetName(p)

	if not name then
		return p
	end

	local clone = table.clone(p)
	clone.Type = "Item"

	if name == "Gems" then
		name = p2 == "Free" and "Free Gems" or "Paid Gems"
	end

	clone.Name = name
	return clone
end

return table.freeze(v)