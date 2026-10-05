local shared = script.Parent.Parent.Parent.Shared
local React = require(shared.React)

local function useClock(p: number, callback, list)
	if list then
		table.insert(list, p)
	end

	React.useEffect(function()
		local v = 1 / p
		local v2 = os.clock() - v
		local thread = task.spawn(function()
			while true do
				local now = os.clock()
				callback(now - v2)
				v2 = now
				task.wait(v)
			end
		end)
		return function()
			task.cancel(thread)
		end
	end, list)
end

return useClock