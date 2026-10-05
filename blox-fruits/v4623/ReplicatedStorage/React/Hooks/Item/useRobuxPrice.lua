local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.ItemConfig)
local PriceService = require(game.ReplicatedStorage.PriceService)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
return function(p, p2)
	local v = useMatch(p, p2)
	local state, setState = React.useState(nil)
	local ref = React.useRef(false)

	if not ref.current then
		if v then
			state = PriceService.getPrice(v.Index.ItemId)

			if state then
				setState(state)
			end
		end

		ref.current = true
	end

	React.useEffect(function()
		if not (PriceService:GetIfInitialized() and v) then
			return function() end
		end

		local v2 = PriceService:ScheduleCallback(v.Index.ItemId, function(p3: number?)
			setState(p3)
		end)
		setState((PriceService.getPrice(v.Index.ItemId)))
		return function()
			v2()
		end
	end, { v and v.Index.ItemId or nil, PriceService:GetIfInitialized() })
	return state
end