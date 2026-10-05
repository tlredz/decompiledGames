game:GetService("ReplicatedStorage")
local module = require("../playerStats")
local module2 = require("./SharedDataHelper")
local module3 = require("../utils/NumberUtils")
local SharedPlayerStats = {
	GetStat = function(p, p2: string)
		local v = module[p2]

		if not v then
			return nil
		end

		if v.Type == "legacy" then
			return module2.readLegacyPathValue(p, v.Path)
		end

		if v.Type == "newformat" then
			return module2.indexNewFormat(p, v.Path)
		end

		if v.Type == "newstat" then
			return module2.indexNewFormat(p, { "NewStats", v.Path })
		end

		if v.Type == "custom" then
			local both, v2 = module2.fetchBoth(p)
			return v.GetCustomValue(p, v2, both)
		end

		warn((`Unknown stat type "{v.Type}" on stat {p2}`))
		return nil
	end,
	FormatStat = function(p: string, p2: number?, flag: boolean?)
		local v = module[p]

		if not v or p2 == nil then
			return nil
		end

		local comma = module3:Comma(p2)
		local substatValueFormat

		if flag then
			substatValueFormat = v.SubstatValueFormat
		else
			substatValueFormat = v.DisplayFormat
		end

		if not substatValueFormat then
			return comma
		end

		if substatValueFormat ~= "duration" and substatValueFormat ~= "duration_minutes" then
			return substatValueFormat:format(comma)
		end

		local v2 = {}

		if substatValueFormat == "duration_minutes" then
			p2 *= 60
		end

		local v3 = p2 // 86400
		local v4

		if p2 >= 86400 then
			table.insert(v2, (`{v3}d`))
			v4 = p2 % 86400
		else
			v4 = p2
		end

		local v5 = v4 // 3600

		if p2 >= 3600 then
			table.insert(v2, (`{v5}h`))
			v4 %= 3600
		end

		local v6 = v4 // 60

		if p2 >= 60 then
			table.insert(v2, (`{v6}m`))
			v4 %= 60
		end

		if substatValueFormat ~= "duration_minutes" then
			table.insert(v2, (`{math.round(v4)}s`))
		end

		return table.concat(v2, " ")
	end
}

function SharedPlayerStats.GetStatWithDisplay(p, p2: string)
	if not module[p2] then
		return nil, nil
	end

	local stat = SharedPlayerStats.GetStat(p, p2)

	if stat == nil then
		return nil, nil
	end

	return stat, SharedPlayerStats.FormatStat(p2, stat)
end

function SharedPlayerStats.GetSubStat(p, p2: string, p3: string)
	local v = module[p2]

	if v and v.SubstatKey then
		return module2.indexNewFormat(p, { "NewStats", v.SubstatKey, p3 })
	end

	return nil
end

function SharedPlayerStats.GetAllSubStats(p, p2: string)
	local v = module[p2]

	if v and v.SubstatKey then
		return module2.indexNewFormat(p, { "NewStats", v.SubstatKey }) or {}
	end

	return {}
end

return SharedPlayerStats