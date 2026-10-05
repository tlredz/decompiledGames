local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local it = JestGlobals.it

local function expectToBeUnique(ReactSymbols)
	local v = {}

	for k, item in ReactSymbols do
		if v[item] ~= nil then
			error(string.format("%s value %s is the same as %s", k, tostring(item), v[item]))
		end

		v[item] = k
	end
end

it.skip("Symbol values should be unique", function() end)
it("numeric values should be unique", function()
	local ReactSymbols = require(script.Parent.Parent.ReactSymbols)
	expectToBeUnique(ReactSymbols)
end)