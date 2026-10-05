local option = require(script.Parent:WaitForChild("option"))
local result = require(script.Parent:WaitForChild("result"))
require(script.Parent:WaitForChild("error"))
local luneutil = require(script.Parent:WaitForChild("lune-util"))
local v = {
	timeout = function(self, p: number)
		luneutil.Task.delay(p, function()
			self._interrupt("Timeout")
		end)
		return self:awaitResult()
	end,
	await = function(self)
		return self:awaitResult():match(function(p)
			return p
		end, function(p)
			error("Future did not complete because: " .. tostring(p))
		end)
	end,
	awaitResult = function(self)
		self._start()
		return self._yieldUntil()
	end,
	cancel = function(p)
		p._interrupt("Cancelled")
	end,
	poll = function(p)
		return p._get():match(function(value)
			return value:match(function(p2)
				return option.some(p2)
			end, function(_)
				return option.none()
			end)
		end, function()
			return option.none()
		end)
	end
}
v.__index = v

function v:__eq(p2)
	return self._get() == p2._get()
end

function v:__tostring()
	return (`Future<{self._get()}>`)
end

function v:pollResult()
	return self._get()
end

function new(callback)
	local none = option.none()
	local none2 = option.none()
	local none3 = option.none()

	local function interrupt(p: string)
		if none2:isSome() or none:isSome() then
			return
		end

		none2 = option.some(p)
		none3:inspect(luneutil.Task.cancel)
	end

	local function yieldUntil()
		while none:isNone() and none2:isNone() do
			luneutil.Task.wait()
		end

		return (none2:match(function(p)
			return result.err(p)
		end, function()
			return result.ok(none:expect("Future should have output by now"))
		end))
	end

	local flag = false

	local function start()
		if flag then
			return
		end

		flag = true

		if none2:isSome() or none:isSome() then
			return
		end

		none3 = option.some(luneutil.Task.spawn(function()
			none = option.some(callback())
		end))
	end

	local self = setmetatable({
		_interrupt = interrupt,
		_start = start,
		_yieldUntil = yieldUntil,
		_get = function()
			return none2:match(function(p)
				return option.some(result.err(p))
			end, function()
				return none:match(function(p)
					return option.some(result.ok(p))
				end, function()
					return option.none()
				end)
			end)
		end
	}, v)
	table.freeze(self)
	return self
end

return {
	from = function(callback)
		return new(callback)
	end
}