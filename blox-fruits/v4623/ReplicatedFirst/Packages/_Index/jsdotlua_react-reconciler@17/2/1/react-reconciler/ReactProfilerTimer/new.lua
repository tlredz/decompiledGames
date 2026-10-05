require(script.Parent:WaitForChild("ReactInternalTypes"))
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local reactFeatureFlags = shared.ReactFeatureFlags
local enableProfilerTimer = reactFeatureFlags.enableProfilerTimer
local enableProfilerCommitHooks = reactFeatureFlags.enableProfilerCommitHooks
local ReactWorkTags = require(script.Parent:WaitForChild("ReactWorkTags"))
local profiler = ReactWorkTags.Profiler
local scheduler = require(script.Parent.Parent:WaitForChild("scheduler"))
local unstable_now = scheduler.unstable_now
local v = 0
local v2 = -1
local v3 = -1
local v4 = -1

function getCommitTime()
	return v
end

function recordCommitTime()
	if not enableProfilerTimer then
		return
	end

	v = unstable_now()
end

function startProfilerTimer(p)
	if not enableProfilerTimer then
		return
	end

	v3 = unstable_now()

	if p.actualStartTime ~= nil and p.actualStartTime < 0 then
		p.actualStartTime = unstable_now()
	end
end

function stopProfilerTimerIfRunning(_)
	if not enableProfilerTimer then
		return
	end

	v3 = -1
end

function stopProfilerTimerIfRunningAndRecordDelta(p, flag: boolean)
	if not enableProfilerTimer then
		return
	end

	if v3 >= 0 then
		local selfBaseDuration = unstable_now() - v3
		p.actualDuration += selfBaseDuration

		if flag then
			p.selfBaseDuration = selfBaseDuration
		end

		v3 = -1
	end
end

function recordLayoutEffectDuration(p)
	if not (enableProfilerTimer and enableProfilerCommitHooks) then
		return
	end

	if v2 >= 0 then
		local v5 = unstable_now() - v2
		v2 = -1
		local return_ = p.return_

		while return_ ~= nil do
			if return_.tag == profiler then
				return_.stateNode.effectDuration += v5
				return
			else
				return_ = return_.return_
			end
		end
	end
end

function recordPassiveEffectDuration(p)
	if not (enableProfilerTimer and enableProfilerCommitHooks) then
		return
	end

	if v4 >= 0 then
		local v5 = unstable_now() - v4
		v4 = -1
		local return_ = p.return_

		while return_ ~= nil do
			if return_.tag == profiler then
				local stateNode = return_.stateNode

				if stateNode == nil then
					break
				end

				stateNode.passiveEffectDuration += v5
				return
			else
				return_ = return_.return_
			end
		end
	end
end

function startLayoutEffectTimer()
	if enableProfilerTimer and enableProfilerCommitHooks then
		v2 = unstable_now()
	end
end

function startPassiveEffectTimer()
	if enableProfilerTimer and enableProfilerCommitHooks then
		v4 = unstable_now()
	end
end

function transferActualDuration(state)
	local child = state.child

	while child do
		state.actualDuration += child.actualDuration
		child = child.sibling
	end
end

return {
	getCommitTime = getCommitTime,
	recordCommitTime = recordCommitTime,
	recordLayoutEffectDuration = recordLayoutEffectDuration,
	recordPassiveEffectDuration = recordPassiveEffectDuration,
	startLayoutEffectTimer = startLayoutEffectTimer,
	startPassiveEffectTimer = startPassiveEffectTimer,
	startProfilerTimer = startProfilerTimer,
	stopProfilerTimerIfRunning = stopProfilerTimerIfRunning,
	stopProfilerTimerIfRunningAndRecordDelta = stopProfilerTimerIfRunningAndRecordDelta,
	transferActualDuration = transferActualDuration
}