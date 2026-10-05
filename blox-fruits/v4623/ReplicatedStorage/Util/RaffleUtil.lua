local Display = require(game.ReplicatedStorage.Packages.Display)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local info = LoggerBuilder.new():tag(script.Name):tag("Util"):traceback():build().info
local RaffleUtil = {
	simulate = function(size: number, callback, value: number?)
		local pulls = {}

		for _ = 1, size do
			local v2 = callback()

			if typeof(v2) == "table" then
				for _, item in pairs(v2) do
					pulls[item] = pulls[item] or 0
					pulls[item] += 1
				end
			elseif typeof(v2) == "string" then
				pulls[v2] = pulls[v2] or 0
				pulls[v2] += 1
			else
				warn((`unknown={v2} typeof({typeof(v2)})`))
			end
		end

		local v2 = 10 ^ (value or 3)
		local percentage = {}

		for k, v4 in pairs(pulls) do
			percentage[k] = `{math.round(v2 * 100 * v4 / size) / v2}%`
		end

		return {
			Size = size,
			Percentage = percentage,
			Pulls = pulls
		}
	end,
	renormalize = function(items, p, items2)
		local clones = {}
		local total = 0

		for k, item in items do
			clones[k] = table.clone(item)
		end

		for k, item in items2 do
			local v = clones[k]

			if v then
				if type(v[p]) == "number" then
					if item then
						v[p] = item
					end
				else
					warn((`no number value at key "{p}"`))
				end
			else
				warn((`no existing entry for "{k}"`))
			end
		end

		for _, v in clones do
			if type(v[p]) == "number" then
				total += v[p]
			else
				warn((`no number value at key "{p}"`))
			end
		end

		for _, v in clones do
			if type(v[p]) == "number" then
				v[p] /= total
			else
				warn((`no number value at key "{p}"`))
			end
		end

		return clones
	end,
	getRandom = function(clone, object, flag: boolean?)
		local v = true

		for _, item in pairs(clone) do
			if not (item > 0) then
				continue
			end

			v = false
			break
		end

		assert(
			not v,
			(`table has no weights / no weight is above 0: {Display.JSON.new():setIndentWith(" "):display(clone)}`)
		)

		for k, item in pairs(clone) do
			if not (item < 0) then
				continue
			end

			warn((`negative weights not supported: {k}, removing`))
			clone = table.clone(clone)
			clone[k] = nil
		end

		local total = 0
		local v3 = 0
		local v4 = nil

		for _, v5 in pairs(clone) do
			total += v5
		end

		local v5

		if object then
			v5 = object:NextNumber(0, total)
		else
			v5 = math.random() * total
		end

		local total2 = 0
		local v6 = nil

		for k, v8 in pairs(clone) do
			if v8 <= 0 then
				continue
			end

			if v3 < v8 then
				v4 = k
				v3 = v8
			end

			total2 += v8

			if not (v5 <= total2) then
				continue
			end

			v6 = k
			break
		end

		assert(v4 ~= nil, "chance table was empty")

		if flag then
			info((`getRandom() -> {v6}, rng={v5}, prob={math.round(1000 * clone[v6]) / 10}%`))
		end

		return v6 or v4
	end
}

function RaffleUtil.getRandomFromGroup(p, p2, object, flag: boolean)
	assert(p2)
	local random = RaffleUtil.getRandom(p, object, flag)
	local v = p2[random]

	if #v == 0 then
		error((`group "{random}" has a population of 0`))
	end

	local v2

	if object then
		v2 = object:NextInteger(1, #v)
	else
		v2 = math.random(1, #v)
	end

	if flag then
		info((`getRandomFromGroup() -> group={random}, n={v2}/{#v}`))
	end

	return v[v2]
end

return RaffleUtil