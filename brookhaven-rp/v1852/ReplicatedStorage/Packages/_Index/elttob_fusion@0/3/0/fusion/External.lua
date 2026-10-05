local parent = script.Parent
local formatError = require(parent.Logging.formatError)
require(parent.Types)
local External = {
	safetyTimerMultiplier = 1
}
local v = {}
local v2 = nil
local v3 = 0

function External.setExternalProvider(p)
	local v4 = v2

	if v4 ~= nil then
		v4.stopScheduler()
	end

	v2 = p

	if p ~= nil then
		p.startScheduler()
	end

	return v4
end

function External.isTimeCritical()
	return false
end

function External.doTaskImmediate(callback)
	if v2 == nil then
		External.logError("noTaskScheduler")
	else
		v2.doTaskImmediate(callback)
	end
end

function External.doTaskDeferred(callback)
	if v2 == nil then
		External.logError("noTaskScheduler")
	else
		v2.doTaskDeferred(callback)
	end
end

function External.logError(p: string, p2, ...)
	error(formatError(v2, p, p2, ...), 0)
end

function External.logErrorNonFatal(p: string, p2, ...)
	local v4 = formatError(v2, p, p2, ...)

	if v2 == nil then
		print(v4)
	else
		v2.logErrorNonFatal(v4)
	end
end

function External.logWarn(p: string, ...)
	local v4 = formatError(v2, p, debug.traceback(nil, 2), ...)

	if v2 == nil then
		print(v4)
	else
		v2.logWarn(v4)
	end
end

function External.bindToUpdateStep(callback)
	local v4 = {}
	v[v4] = callback
	return function()
		v[v4] = nil
	end
end

function External.performUpdateStep(p: number)
	v3 = p

	for _, v4 in v do
		v4(p)
	end
end

function External.lastUpdateStep()
	return v3
end

return External