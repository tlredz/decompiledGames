local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local ErrorHandlingroblox = require(script.Parent["ErrorHandling.roblox"])
local describeError = ErrorHandlingroblox.describeError

local function invokeGuardedCallbackProd(p, _, callback, p2, ...)
	local v = nil
	local v2

	if ReactGlobals.__YOLO__ then
		v2 = true

		if p2 == nil then
			callback(...)
		else
			callback(p2, ...)
		end
	elseif p2 == nil then
		v2, v = xpcall(callback, describeError, ...)
	else
		v2, v = xpcall(callback, describeError, p2, ...)
	end

	if not v2 then
		p.onError(v)
	end
end

local _ = ReactGlobals.__DEV__
return invokeGuardedCallbackProd