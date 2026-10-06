local v = {
	List = {},
	DifficultyOrder = {
		"Easy",
		"Medium",
		"Hard",
		"Insane",
		"Boss",
		"Secret"
	},
	GetPrice = function(p)
		if not p or p.Style ~= "Party" or p.Price == nil then
			return nil, nil
		end

		local price = p.Price

		if typeof(price) ~= "table" or price.Type ~= "Item" and price.Type ~= "Currency" or (typeof(price.Name) ~= "string" or price.Name == "") then
			return nil, "InvalidPrice"
		end

		if typeof(price.Amount) ~= "number" or not (price.Amount > 0 and price.Amount < 1e999) or price.Type == "Item" and price.Amount % 1 ~= 0 then
			return nil, "InvalidPrice"
		end

		return price, nil
	end,
	GetPriceAmount = function(p, p2)
		if not p then
			return 0
		end

		if p2.Type == "Item" then
			local list = p.Items and p.Items.List
			return list and list[p2.Name] or 0
		end

		if p2.Name == "Gems" then
			return (not (p.Items and p.Items.List) and 0 or p.Items.List["Free Gems"] or 0) + (p.Items and p.Items.List and p.Items.List["Paid Gems"] or 0)
		end

		return p[p2.Name] or 0
	end
}

function v.Register(name: string, p)
	if typeof(name) ~= "string" or typeof(p) ~= "table" then
		return
	end

	if v.List[name] then
		warn((`Repeated Gamemode Module: {name}!`))
		return
	end

	p.Name = name
	v.List[name] = p
end

function v.GetDifficultyInfo(p, p2: string?)
	if typeof(p) ~= "table" then
		return nil
	end

	if typeof(p.Difficulty) == "string" then
		if p2 and p2 ~= p.Difficulty then
			return nil
		end

		return p
	elseif p2 and typeof(p.Difficulties) == "table" then
		return p.Difficulties[p2]
	else
		return nil
	end
end

function v.GetOrderedDifficulties(p)
	local result = {}

	if typeof(p) ~= "table" then
		return result
	end

	if typeof(p.Difficulty) == "string" then
		return { p.Difficulty }
	end

	if typeof(p.Difficulties) ~= "table" then
		return result
	end

	for _, v2 in v.DifficultyOrder do
		if p.Difficulties[v2] then
			table.insert(result, v2)
		end
	end

	return result
end

return table.freeze(v)