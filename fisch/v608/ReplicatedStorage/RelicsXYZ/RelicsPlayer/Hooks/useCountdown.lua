local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
require(shared.GamePasses)
local hooks = parent.Hooks
local useClock = require(hooks.useClock)

local function getTimeRemaining(p)
	if not p.EndDate then
		return nil
	end

	local v = math.max(0, (p.EndDate.UnixTimestamp or 0) - os.time())
	local v2 = v // 86400
	local v3 = v % 86400
	local v4 = v3 // 3600
	local v5 = v3 % 3600
	local v6 = v5 // 60
	local v7 = v5 % 60

	if v2 > 0 then
		return string.format("%d:%02d:%02d:%02d", v2, v4, v6, v7)
	end

	return string.format("%02d:%02d:%02d", v4, v6, v7)
end

local function useCountdown(p, flag: boolean)
	local state, setState = React.useState(flag)
	local v, v2 = React.useBinding(getTimeRemaining(p))
	useClock(1, function()
		v2((getTimeRemaining(p)))
		local endDate = p.EndDate
		local unixTimestamp = endDate and endDate.UnixTimestamp

		if unixTimestamp and unixTimestamp < os.time() then
			setState(false)
		end
	end, {})
	return v, state
end

return useCountdown