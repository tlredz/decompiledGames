local __DEV__ = _G.__DEV__
local flat = require(script.Parent:WaitForChild("flat"))
local map = require(script.Parent:WaitForChild("map"))
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))

local function flatMap(p, callback, p2)
	if not __DEV__ then
		return flat(map(p, callback, p2))
	end

	if typeof(p) ~= "table" then
		error(string.format("Array.flatMap called on %s", (typeof(p))))
	end

	if typeof(callback) ~= "function" then
		error("callback is not a function")
	end

	return flat(map(p, callback, p2))
end

return flatMap