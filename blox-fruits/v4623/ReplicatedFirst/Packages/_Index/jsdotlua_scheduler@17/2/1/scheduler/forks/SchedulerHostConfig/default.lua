local luaupolyfill = require(script.Parent.Parent.Parent:WaitForChild("luau-polyfill"))
local object = luaupolyfill.Object
local shared = require(script.Parent.Parent.Parent:WaitForChild("shared"))
local console = shared.console
local errorToString = shared.errorToString
local describeError = shared.describeError
local setTimeout = luaupolyfill.setTimeout
local clearTimeout = luaupolyfill.clearTimeout
local v = false
local v2 = nil
local none = object.None
local v3 = 15
local v4 = 0

local function shouldYieldToHost()
	local v5 = os.clock() * 1000
	return v4 <= v5
end

local function forceFrameRate(p)
	if p < 0 or p > 125 then
		console.warn("forceFrameRate takes a positive int between 0 and 125, forcing frame rates higher than 125 fps is not supported")
	elseif p > 0 then
		v3 = math.floor(1000 / p)
	else
		v3 = 5
	end
end

local performWorkUntilDeadline

performWorkUntilDeadline = function()
	if v2 == nil then
		v = false
	else
		local v5 = os.clock() * 1000
		v4 = v5 + v3

		local function doWork()
			if v2(true, v5) then
				task.delay(0, performWorkUntilDeadline)
			else
				v = false
				v2 = nil
			end

			return nil
		end

		local v6, v7

		if _G.__YOLO__ then
			if v2(true, v5) then
				task.delay(0, performWorkUntilDeadline)
			else
				v = false
				v2 = nil
			end

			v6 = true
		else
			v6, v7 = xpcall(doWork, describeError)
		end

		if not v6 then
			task.delay(0, performWorkUntilDeadline)
			error(errorToString(v7))
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wrapPerformWorkWithCoroutine(callback)
	local thread = coroutine.create(function()
		while true do
			local thread2 = coroutine.wrap(callback)
			local success, result = pcall(thread2)
			coroutine.yield(success, result)
		end
	end)
	return function()
		local _, v5, v6 = coroutine.resume(thread)

		if not v5 then
			error(v6)
		end
	end
end

performWorkUntilDeadline = wrapPerformWorkWithCoroutine(performWorkUntilDeadline)
local Default = {}

function Default.requestHostCallback(p)
	v2 = p

	if not v then
		v = true
		task.delay(0, performWorkUntilDeadline)
	end
end

function Default.cancelHostCallback()
	v2 = nil
end

function Default.requestHostTimeout(callback, p)
	none = setTimeout(function()
		callback(os.clock() * 1000)
	end, p)
end

function Default.cancelHostTimeout()
	clearTimeout(none)
	none = object.None
end

Default.shouldYieldToHost = shouldYieldToHost

function Default.requestPaint() end

function Default.getCurrentTime()
	return os.clock() * 1000
end

Default.forceFrameRate = forceFrameRate
return Default