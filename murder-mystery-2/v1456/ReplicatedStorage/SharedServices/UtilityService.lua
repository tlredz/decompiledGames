local UtilityService = {}

function UtilityService.DeepCopy(items)
	local result = {}

	for k, item in items do
		if typeof(item) == "table" then
			result[k] = UtilityService.DeepCopy(item)
		else
			result[k] = item
		end
	end

	return result
end

function UtilityService.CommaNumber(_, _: number)
	local v = nil

	repeat
		local v2
		v, v2 = string.gsub(v, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return v
end

function UtilityService.IsTestingServer(_)
	return game.GameId == 119460199
end

return UtilityService