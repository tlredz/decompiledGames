local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local Mutex = require(shared.Mutex)
local React = require(shared.React)

local function useMutex(p, p2: string?)
	local state, setState = React.useState(function()
		if p and p2 then
			return Mutex.HasLock(p, p2)
		end

		return false
	end)
	React.useEffect(function()
		if not (p and p2) then
			setState(false)
			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			setState((Mutex.HasLock(p, p2)))
		end

		local connection = Mutex.GetLockChangedSignal(p, p2):Connect(update)
		update() -- equivalent call inferred; original call site unknown
		return function()
			connection:Disconnect()
		end
	end, { p, p2 })
	return state
end

return useMutex