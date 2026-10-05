local Compiler = require(script:WaitForChild("Compiler"))
local FiOne = require(script:WaitForChild("FiOne"))

local function ValidLuauBytecode(value)
	return string.sub(value, 2, 4) == "Lua"
end

function luau_compile(p, value)
	local success, result = pcall(Compiler, p)
	return success == true and result or error((value or "@") .. result:sub(2), 0)
end

function luau_load(p, p2)
	assert(ValidLuauBytecode(p), "luau_load: Argument #1 got invalid bytecode (lua bytecode expected)")
	assert(type(p2) == "table" or p2 == nil, ("luau_load: Argument #2 got '%s' (table expected)"):format((typeof(p2))))
	return FiOne(p, p2 or getfenv(2))
end

return (setmetatable({
	luau_compile = luau_compile,
	luau_load = luau_load,
	luau_execute = function(p, p2, p3)
		if ValidLuauBytecode(p) then
			return luau_load(p, p2)
		end

		return luau_load(luau_compile(p, p3), p2 or getfenv(2))
	end,
	create_env = function(p)
		local v = getfenv(2)
		return (setmetatable({}, {
			__index = function(_, p2)
				return p[p2] or v[p2]
			end
		}))
	end
}, {
	__call = function(p, p2, p3, p4)
		return p.luau_execute(p2, p3 or getfenv(2), p4)
	end
}))