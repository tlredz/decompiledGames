local React = require(game.ReplicatedStorage.Packages.React)
local useShopContext = require(game.ReplicatedStorage.React.Hooks.useShopContext)
return function()
	local v = math.round(useShopContext() == "AdvancedFruitDealer" and 7200 or 14400)
	local v2 = React.useCallback(function(p)
		local v3 = p.UnixTimestamp % v
		return DateTime.fromUnixTimestamp((math.round(p.UnixTimestamp - v3 + v)))
	end, { v })
	local state, setState = React.useState(v2(DateTime.now()))
	React.useEffect(function()
		local now = DateTime.now()
		local v3 = v2(now)

		if v3.UnixTimestamp > now.UnixTimestamp then
			setState(v3)
		end

		local v4 = v3.UnixTimestamp - now.UnixTimestamp
		local thread = task.delay(v4, function()
			setState(v2(DateTime.now()))
		end)
		return function()
			task.cancel(thread)
		end
	end, { v2, state })
	return state
end