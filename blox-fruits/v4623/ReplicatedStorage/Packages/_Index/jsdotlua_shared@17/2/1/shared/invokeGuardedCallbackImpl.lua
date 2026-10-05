local ErrorHandlingroblox = require(script.Parent:WaitForChild("ErrorHandling.roblox"))
local describeError = ErrorHandlingroblox.describeError

local function invokeGuardedCallbackProd(p, _, callback, p2, ...)
	local v = nil
	local v2

	if _G.__YOLO__ then
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

local _ = _G.__DEV__
return invokeGuardedCallbackProd