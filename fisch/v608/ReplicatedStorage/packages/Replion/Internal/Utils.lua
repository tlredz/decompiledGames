local RunService = game:GetService("RunService")
local Freeze = require(script.Parent.Parent.Parent.Freeze)
require(script.Parent.Types)
return table.freeze({
	SerializedNone = "\0",
	ShouldMock = RunService:IsStudio() and not RunService:IsRunning(),
	getValue = function(p)
		if p == Freeze.None or p == "\0" then
			return nil
		end

		return p
	end,
	getPathTable = function(value)
		if type(value) == "table" then
			return value
		end

		if type(value) == "string" then
			return string.split(value, ".")
		end

		return { value }
	end,
	getPathString = function(value)
		if type(value) == "string" then
			return value
		end

		if type(value) == "table" then
			return table.concat(value, ".")
		end

		return (tostring(value))
	end,
	safeCancelThread = function(thread: thread)
		if coroutine.status(thread) ~= "dead" then
			task.cancel(thread)
		end
	end
})