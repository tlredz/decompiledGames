local ComingSoonUtil = require(game.ReplicatedStorage.Util.ComingSoonUtil)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local DEFAULT_FEATURED_FRUITS = require(script.DEFAULT_FEATURED_FRUITS)
local fn

fn = function(DEFAULT_FEATURED_FRUITS2: string, flag: boolean?)
	local v = DEFAULT_FEATURED_FRUITS2 or DEFAULT_FEATURED_FRUITS
	local result = {}

	for k in v:gmatch("[^,]+") do
		local v2 = k:gsub("[^%w%-]", "")

		if v2:gsub("[%p%c%s]", ""):len() == 0 then
			continue
		end

		local nullable = ItemId.getId(`Permanent {v2}-{v2}`, "Redeemable"):asNullable()

		if not nullable or ComingSoonUtil.getIsComingSoon(nullable) then
			continue
		end

		table.insert(result, v2)
	end

	if #result == 0 and not flag then
		return fn(DEFAULT_FEATURED_FRUITS, true)
	end

	if flag then
		warn("FATAL", v, debug.traceback())
	end

	return result
end

return fn