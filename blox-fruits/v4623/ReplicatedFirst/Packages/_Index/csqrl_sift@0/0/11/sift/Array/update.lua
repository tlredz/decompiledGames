local parent = script.Parent.Parent
local Util = require(parent.Util)
local copy = require(script.Parent.copy)

-- equivalent calls inferred from this helper; original call sites unknown
local function call(callback, total: number)
	if type(callback) == "function" then
		return callback(total)
	end
end

local function update(list, total: number, returned, callback)
	local v = #list
	local v2 = copy(list)

	if total < 1 then
		total += v
	end

	if type(returned) ~= "function" then
		returned = Util.func.returned
	end

	if v2[total] ~= nil then
		v2[total] = returned(v2[total], total)
		return v2
	end

	local v3 = call(callback, total) -- equivalent call inferred; original call site unknown
	v2[total] = v3
	return v2
end

return update