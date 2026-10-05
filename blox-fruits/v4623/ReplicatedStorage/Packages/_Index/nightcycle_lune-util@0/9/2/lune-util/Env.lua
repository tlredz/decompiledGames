local option = require(script.Parent.Parent:WaitForChild("option"))
local error = require(script.Parent.Parent:WaitForChild("error"))
local CONFIG = require(script.Parent:WaitForChild("CONFIG"))
return (setmetatable({}, {
	__index = function(_, value)
		assert(type(value) == "string", (`Key "{value}" must be a string`))

		if CONFIG.IS_RBX_ENV then
			local v = _G[value]
			assert(typeof(v) == "string" or typeof(v) == "nil", (`Value "{v}" must be a string or nil`))
			return option.from(v)
		else
			local module = require("@lune/process")
			local v = module.env[value]
			assert(typeof(v) == "string" or typeof(v) == "nil", (`Value "{v}" must be a string or nil`))
			return option.from(v)
		end
	end,
	__newindex = function(_, value, object)
		assert(type(value) == "string", (`Key "{value}" must be a string`))
		assert(option.isOption(object), (`Value "{object}" must be an Option`))

		if CONFIG.IS_RBX_ENV then
			local nullable = object:asNullable()
			assert(
				typeof(nullable) == "string" or typeof(nullable) == "nil",
				(`Value "{nullable}" must be a string or nil`)
			)
			_G[value] = nullable
		else
			local module = require("@lune/process")
			local nullable = object:asNullable()
			assert(
				typeof(nullable) == "string" or typeof(nullable) == "nil",
				(`Value "{nullable}" must be a string or nil`)
			)
			module.env[value] = nullable
		end
	end,
	__tostring = function()
		if not CONFIG.IS_RBX_ENV then
			local module = require("@lune/process")
			return error.displayAsJson(module.env)
		end

		local v = {}

		for k, v2 in pairs(_G) do
			if typeof(v2) == "string" then
				v[k] = v2
			end
		end

		return error.displayAsJson(v)
	end
}))