local v = {
	["John Pork"] = true,
	Meowl = true,
	["Skibidi Toilet"] = true,
	["Strawberry Elephant"] = true
}
local v2 = {
	["John Pork"] = Color3.fromRGB(231, 162, 157),
	Meowl = Color3.fromRGB(179, 146, 57),
	["Skibidi Toilet"] = Color3.fromRGB(247, 227, 227),
	["Strawberry Elephant"] = Color3.fromRGB(219, 80, 81)
}
local v3 = {
	Brainrots = table.freeze({
		"John Pork",
		"Meowl",
		"Skibidi Toilet",
		"Strawberry Elephant"
	}),
	BrainrotsSet = table.freeze(v),
	ImageIds = table.freeze({
		["John Pork"] = 120781357173642,
		Meowl = 80231998122393,
		["Skibidi Toilet"] = 83113056007315,
		["Strawberry Elephant"] = 76972423112991
	}),
	TextColors = table.freeze(v2),
	IsMetadata = function(data)
		if typeof(data) ~= "table" then
			return false
		end

		if typeof(data.Brainrot) == "string" and v[data.Brainrot] == true and typeof(data.InitialStock) == "number" and data.InitialStock >= 1 and data.InitialStock <= 100 and data.InitialStock == math.floor(data.InitialStock) and typeof(data.CreatedAt) == "number" then
			return typeof(data.UseSecondary) == "boolean"
		else
			return false
		end
	end
}

function v3.IsDrop(p)
	if not v3.IsMetadata(p) then
		return false
	end

	return typeof(p.Chance) == "number" and p.Chance == p.Chance and p.Chance > 0 and p.Chance <= 100
end

function v3.ToMetadata(data)
	return {
		Brainrot = data.Brainrot,
		InitialStock = data.InitialStock,
		CreatedAt = data.CreatedAt,
		UseSecondary = data.UseSecondary
	}
end

function v3.CreateDrop(data, chance: number)
	return {
		Brainrot = data.Brainrot,
		InitialStock = data.InitialStock,
		Chance = chance,
		CreatedAt = data.CreatedAt,
		UseSecondary = data.UseSecondary
	}
end

function v3.GetFlagKey(p: string)
	assert(v[p], "brainrot is not available")
	return (`RNGMachine/LimitedStock/{p}`)
end

function v3.GetStockKey(p: string)
	assert(v[p], "brainrot is not available")
	return (`RNGMachineLimited-{p}`)
end

return table.freeze(v3)