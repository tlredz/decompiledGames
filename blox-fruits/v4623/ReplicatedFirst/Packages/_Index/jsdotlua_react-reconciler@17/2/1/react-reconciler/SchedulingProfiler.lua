local SchedulingProfiler = {}
local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local weakMap = luaupolyfill.WeakMap
require(script.Parent:WaitForChild("ReactFiberLane"))
require(script.Parent:WaitForChild("ReactInternalTypes"))
require(script.Parent.Parent:WaitForChild("shared"))
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local enableSchedulingProfiler = shared.ReactFeatureFlags.enableSchedulingProfiler
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local reactVersion = shared2.ReactVersion
local shared3 = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared3.getComponentName
local v = _G.performance ~= nil
local performance = _G.performance or {
	mark = function(p)
		debug.profilebegin(p)
		debug.profileend()
	end
}

function formatLanes(p)
	return (tostring(p))
end

if enableSchedulingProfiler and v then
	performance.mark("--react-init-" .. tostring(reactVersion))
end

function SchedulingProfiler.markCommitStarted(p)
	if enableSchedulingProfiler and v then
		performance.mark("--commit-start-" .. formatLanes(p))
	end
end

function SchedulingProfiler.markCommitStopped()
	if enableSchedulingProfiler and v then
		performance.mark("--commit-stop")
	end
end

local v2 = weakMap.new()
local count = 0

function getWakeableID(p)
	if not v2:has(p) then
		v2:set(p, count)
		count += 1
	end

	return v2:get(p)
end

function SchedulingProfiler.markComponentSuspended(p, object)
	if enableSchedulingProfiler and v then
		local wakeableID = getWakeableID(object)
		local v3 = getComponentName(p.type) or "Unknown"
		performance.mark("--suspense-suspend-" .. tostring(wakeableID) .. "-" .. v3)
		object:andThen(function()
			performance.mark("--suspense-resolved-" .. tostring(wakeableID) .. "-" .. v3)
		end, function()
			performance.mark("--suspense-rejected-" .. tostring(wakeableID) .. "-" .. v3)
		end)
	end
end

function SchedulingProfiler.markLayoutEffectsStarted(p)
	if enableSchedulingProfiler and v then
		performance.mark("--layout-effects-start-" .. formatLanes(p))
	end
end

function SchedulingProfiler.markLayoutEffectsStopped()
	if enableSchedulingProfiler and v then
		performance.mark("--layout-effects-stop")
	end
end

function SchedulingProfiler.markPassiveEffectsStarted(p)
	if enableSchedulingProfiler and v then
		performance.mark("--passive-effects-start-" .. formatLanes(p))
	end
end

function SchedulingProfiler.markPassiveEffectsStopped()
	if enableSchedulingProfiler and v then
		performance.mark("--passive-effects-stop")
	end
end

function SchedulingProfiler.markRenderStarted(p)
	if enableSchedulingProfiler and v then
		performance.mark("--render-start-" .. formatLanes(p))
	end
end

function SchedulingProfiler.markRenderYielded()
	if enableSchedulingProfiler and v then
		performance.mark("--render-yield")
	end
end

function SchedulingProfiler.markRenderStopped()
	if enableSchedulingProfiler and v then
		performance.mark("--render-stop")
	end
end

function SchedulingProfiler.markRenderScheduled(p)
	if enableSchedulingProfiler and v then
		performance.mark("--schedule-render-" .. formatLanes(p))
	end
end

function SchedulingProfiler.markForceUpdateScheduled(p, p2)
	if enableSchedulingProfiler and v then
		local v3 = getComponentName(p.type) or "Unknown"
		performance.mark("--schedule-forced-update-" .. formatLanes(p2) .. "-" .. v3)
	end
end

function SchedulingProfiler.markStateUpdateScheduled(p, p2)
	if enableSchedulingProfiler and v then
		local v3 = getComponentName(p.type) or "Unknown"
		performance.mark("--schedule-state-update-" .. formatLanes(p2) .. "-" .. v3)
	end
end

return SchedulingProfiler