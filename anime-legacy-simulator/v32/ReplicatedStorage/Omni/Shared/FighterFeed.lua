local Fighters = require(script.Parent.Fighters)
local Items = require(script.Parent.Items)
local v = {
	IsAmount = function(value)
		return typeof(value) == "number" and value > 0 and value < 1e999 and value % 1 == 0 and value <= 9007199254740991
	end
}

function v.IsFood(p: string)
	local v2 = Items.List[p]
	return v2 ~= nil and v.IsAmount(v2.FeedExp)
end

function v.GetAvailableAmount(p: string, p2)
	local v2 = p2.Items.List[p]

	if typeof(v2) == "number" and v2 == v2 and not (v2 <= 0 or v2 > 9007199254740991) then
		return (math.floor(v2))
	end

	return 0
end

function v.GetFoods()
	local result = {}

	for k in Items.List do
		if v.IsFood(k) then
			table.insert(result, k)
		end
	end

	table.sort(result, function(a, b)
		local feedExp = Items.List[a].FeedExp
		local feedExp2 = Items.List[b].FeedExp

		if feedExp == feedExp2 then
			return a < b
		end

		return feedExp < feedExp2
	end)
	return result
end

function v.GetTotalExp(p, p2)
	local exp = p.Exp or 0

	for i = 2, p.Level or 1 do
		exp += Fighters.GetNeededExpForLevel(i, p, p2) or 0
	end

	return exp
end

function v.GetRemainingExp(p, p2)
	local v2 = -(p.Exp or 0)
	local fighterMaxLevel = Fighters.GetFighterMaxLevel(p, p2)

	if fighterMaxLevel <= (p.Level or 1) then
		return 0
	end

	for i = (p.Level or 1) + 1, fighterMaxLevel do
		v2 += Fighters.GetNeededExpForLevel(i, p, p2) or 0
	end

	return (math.max(0, v2))
end

function v.GetPreview(data, p, items)
	if typeof(items) ~= "table" or not Fighters.List[data.Name] then
		return nil
	end

	for k, item in items do
		if typeof(k) ~= "string" or not (v.IsFood(k) and v.IsAmount(item)) then
			return nil
		end

		if v.GetAvailableAmount(k, p) < item then
			return nil
		end
	end

	local level = data.Level or 1
	local exp = data.Exp or 0
	local fighterMaxLevel = Fighters.GetFighterMaxLevel(data, p)
	local fighterExpGain = Fighters.GetFighterExpGain(data, p)
	local remainingExp = v.GetRemainingExp(data, p)
	local consumed = {}
	local total = 0
	local remainingExp2

	if fighterExpGain > 0 and fighterExpGain < 1e999 then
		remainingExp2 = remainingExp

		for _, v4 in v.GetFoods() do
			local item = items[v4]

			if not item or remainingExp2 <= 0 then
				continue
			end

			local v5 = Items.List[v4].FeedExp * fighterExpGain
			local v6 = math.min(item, (math.ceil(remainingExp2 / v5)))
			consumed[v4] = v6
			total += v6 * v5
			remainingExp2 = math.max(0, remainingExp - total)
		end
	else
		remainingExp2 = remainingExp
	end

	local v4 = exp + total

	while level < fighterMaxLevel do
		local neededExpForLevel = Fighters.GetNeededExpForLevel(level + 1, data, p)

		if not neededExpForLevel or v4 < neededExpForLevel then
			break
		end

		v4 -= neededExpForLevel
		level += 1
	end

	return {
		Level = level,
		Exp = math.floor(fighterMaxLevel <= level and 0 or v4),
		GainedExp = math.floor((math.min(total, remainingExp))),
		Consumed = consumed,
		RemainingExp = remainingExp2,
		MaxLevel = fighterMaxLevel
	}
end

function v.AddAll(p, p2, p3)
	local clone = table.clone(p3)
	local preview = v.GetPreview(p, p2, clone)

	if not preview then
		return clone
	end

	local fighterExpGain = Fighters.GetFighterExpGain(p, p2)

	if fighterExpGain <= 0 or fighterExpGain >= 1e999 then
		return clone
	end

	local remainingExp = preview.RemainingExp

	for _, v2 in v.GetFoods() do
		if remainingExp <= 0 then
			break
		end

		local availableAmount = v.GetAvailableAmount(v2, p2)

		if availableAmount <= 0 then
			continue
		end

		local v3 = clone[v2] or 0
		local v4 = Items.List[v2].FeedExp * fighterExpGain
		local v5 = math.min(math.max(0, availableAmount - v3), (math.ceil(remainingExp / v4)))

		if v5 <= 0 then
			continue
		end

		clone[v2] = v3 + v5
		remainingExp = math.max(0, remainingExp - v5 * v4)
	end

	return clone
end

function v.GetDeconstructReward(data)
	local v2 = Fighters.List[data.Name]

	if v2 and v2.Deconstructable == false or not (v2 and v.IsAmount(data.Level or 1) and v.IsAmount(v2.DeconstructAmount)) then
		return nil
	end

	for _, name in v.GetFoods() do
		if Items.List[name].DeconstructMap ~= v2.MapName then
			continue
		end

		local amount = math.round(v2.DeconstructAmount * (data.Shiny and 1.5 or 1))

		if v.IsAmount(amount) then
			return {
				Name = name,
				Amount = amount
			}
		end

		return nil
	end

	return nil
end

return table.freeze(v)