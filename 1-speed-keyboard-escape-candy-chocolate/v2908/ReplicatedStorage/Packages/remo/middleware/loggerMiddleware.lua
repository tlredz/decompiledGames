require(script.Parent.Parent.types)
local constants = require(script.Parent.Parent.constants)
local v = constants.IS_SERVER and "client → server" or "server → client"

local function stringify(...)
	local v2 = {}

	for i = 1, select("#", ...) do
		local v3 = select(i, ...)
		table.insert(v2, (`{i > 1 and "\n" or ""}\t{i}.`))

		if type(v3) == "string" then
			table.insert(v2, string.format("%q", v3))
		elseif type(v3) == "userdata" then
			table.insert(v2, (`{typeof(v3)}({v3})`))
		else
			table.insert(v2, v3)
		end
	end

	if #v2 == 0 then
		return "\t1. (void)\n"
	end

	table.insert(v2, "\n")
	return table.unpack(v2)
end

return function(callback, p)
	return function(...)
		if p.type == "event" then
			print(`\n🟡 ({v}) {p.name}\n\n`, stringify(...))
			return callback(...)
		end

		print((`\n🟣 ({v} async) {p.name}\n`))
		print("Parameters\n", stringify(...))
		local v2 = table.pack(callback(...))
		print("Returns\n", stringify(table.unpack(v2, 1, v2.n)))
		return table.unpack(v2, 1, v2.n)
	end
end