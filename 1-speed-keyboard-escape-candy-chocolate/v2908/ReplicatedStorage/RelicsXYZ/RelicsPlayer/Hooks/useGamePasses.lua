local parent = script.Parent
local useSignal = require(parent.useSignal)
local shared = parent.Parent.Parent.Shared
local React = require(shared.React)
local GamePasses = require(shared.GamePasses)

local function useGamePasses(p)
	local state, setState = React.useState(function()
		return GamePasses.GetFilteredGamePasses(p)
	end)
	local ref = React.useRef()
	local ref2 = React.useRef(false)
	local v = React.useCallback(function()
		setState((GamePasses.GetFilteredGamePasses(p)))
	end, { p })
	local v2 = React.useCallback(function()
		ref.current = ref.current or task.defer(function()
			ref.current = nil
			v()
		end)
		return function()
			if ref.current then
				task.cancel(ref.current)
				ref2.current = true
				ref.current = nil
			end
		end
	end, { v })
	React.useEffect(function()
		local now = os.time()
		local v3 = math.max(0, state.NextRefreshTime - now)

		if v3 < 1e999 then
			local thread = task.delay(v3, v)
			return function()
				task.cancel(thread)
			end
		else
			return nil
		end
	end, { state })

	if ref2.current then
		ref2.current = false
		v2()
	end

	useSignal(GamePasses.GamePassAdded, v2, { v2 })
	useSignal(GamePasses.GamePassRemoved, v2, { v2 })
	return state.GamePasses
end

return useGamePasses