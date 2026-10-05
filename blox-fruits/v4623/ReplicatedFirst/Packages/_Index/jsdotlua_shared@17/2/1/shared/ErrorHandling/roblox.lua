local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local error = luaupolyfill.Error
local inspect = luaupolyfill.util.inspect
local Roblox = {}

function Roblox.describeError(value)
	if typeof(value) ~= "string" then
		return value
	end

	local _, v = string.find(value, ":[%d]+: ")

	if v then
		value = string.sub(value, v + 1)
	end

	local error2 = luaupolyfill.Error.new(value)
	error2.stack = debug.traceback(nil, 2)
	return error2
end

function Roblox.errorToString(p)
	if typeof(p) ~= "table" then
		return (inspect(p))
	end

	if p.message and p.stack then
		return [[

------ Error caught by React ------
]] .. p.message .. [[

------ Error caught by React ------
]] .. tostring(p.stack)
	end

	return (inspect(p))
end

function Roblox.parseReactError(value: string)
	local v = string.split(value, [[

------ Error caught by React ------
]])

	if #v == 3 then
		local v2, v3, stack = table.unpack(v)
		local v5 = error.new(v3)
		v5.stack = stack
		return v5, v2
	else
		local v2 = error.new(value)
		v2.stack = nil
		return v2, ""
	end
end

Roblox.__ERROR_DIVIDER = [[

------ Error caught by React ------
]]
return Roblox