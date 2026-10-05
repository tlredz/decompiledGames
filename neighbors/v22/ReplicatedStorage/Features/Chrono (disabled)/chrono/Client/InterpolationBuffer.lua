local Warn = require(script.Parent.Parent.Shared.Warn)
local Config = require(script.Parent.Parent.Shared.Config)
require(script.Parent.Parent.Shared.Types)
local v = nil
local v2 = nil
Config._WaitForLock(function()
	v = Config._GetConfig("MIN_BUFFER")
	v2 = Config._GetConfig("MAX_BUFFER")
end)
local InterpolationBuffer = {}

function InterpolationBuffer.new(clientClock)
	return {
		init = false,
		averageLatency = 0,
		deviation = 0,
		lastLatency = 0,
		clientClock = clientClock
	}
end

function InterpolationBuffer.Register(state, p: number)
	local clientClock = state.clientClock
	local v3 = clientClock:GetEstimatedServerTime() - p

	if math.abs(v3) > 1 then
		clientClock:Clear()
		Warn.low(state.clientClock.name, (` latency too high, cleared cache to repredict in case of error:! {v3}`))
	end

	if state.init then
		if state.lastLatency then
			local v4 = math.abs(v3 - state.lastLatency)
			state.deviation += (v4 - state.deviation) * 0.1
		end

		state.averageLatency += (v3 - state.averageLatency) * 0.1
		state.lastLatency = v3
	else
		state.averageLatency = v3
		state.deviation = 0
		state.lastLatency = v3
		state.init = true
	end
end

function InterpolationBuffer.GetBuffer(p, p2: number)
	if not p then
		return v
	end

	local v3 = p2 + p.deviation * 2

	if v3 < v then
		v3 = v + (v - v3) * 0.2
	end

	if v2 < v3 then
		Warn.low(`Interpolation buffer exceeded max! Was {v3}, clamped to {v2} for`, p.clientClock.name)
		return v2
	end

	return v3
end

return InterpolationBuffer