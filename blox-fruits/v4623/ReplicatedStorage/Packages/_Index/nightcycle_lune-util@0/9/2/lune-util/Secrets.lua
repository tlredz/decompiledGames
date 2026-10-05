local option = require(script.Parent.Parent:WaitForChild("option"))
local result = require(script.Parent.Parent:WaitForChild("result"))
local Env = require(script.Parent:WaitForChild("Env"))
local CONFIG = require(script.Parent:WaitForChild("CONFIG"))
local class = {}
class.__index = class

function class.__tostring(_)
	return "CompatSecret<???>"
end

function newCompatSecret(p: string, value)
	if CONFIG.IS_RBX_ENV then
		local v = {
			AddPrefix = function(self, value2: string)
				assert(type(value2) == "string", (`Prefix "{value2}" must be a string`))
				local newCompatSecret2 = newCompatSecret
				local v3

				if typeof(value) == "string" then
					v3 = value2 .. value
				else
					v3 = value:AddPrefix(value2)
				end

				return newCompatSecret2(p, v3)
			end,
			AddSuffix = function(self, value2: string)
				assert(type(value2) == "string", (`Suffix "{value2}" must be a string`))
				local newCompatSecret2 = newCompatSecret
				local v3

				if typeof(value) == "string" then
					v3 = value .. value2
				else
					v3 = value:AddSuffix(value2)
				end

				return newCompatSecret2(p, v3)
			end,
			Build = function(_)
				return value
			end
		}
		setmetatable(v, class)
		table.freeze(v)
		return v
	else
		local v = {
			AddPrefix = function(self, value2: string)
				assert(type(value2) == "string", (`Prefix "{value2}" must be a string`))
				return newCompatSecret(p, value2 .. value)
			end,
			AddSuffix = function(self, value2: string)
				assert(type(value2) == "string", (`Suffix "{value2}" must be a string`))
				return newCompatSecret(p, value .. value2)
			end,
			Build = function(_)
				return value
			end
		}
		setmetatable(v, class)
		table.freeze(v)
		return v
	end
end

return (setmetatable({}, {
	__index = function(_, value)
		assert(type(value) == "string", (`Key "{value}" must be a string`))

		if CONFIG.IS_RBX_ENV then
			local HttpService = game:GetService("HttpService")
			return result.try(function()
				return option.some((HttpService:GetSecret(value)))
			end):match(function(p)
				return p
			end, function()
				return Env[value]
			end):match(function(p)
				return option.some(newCompatSecret(value, p))
			end, function()
				return option.none()
			end)
		end

		local module = require("@lune/process")
		local v = module.env[value]

		if v == nil then
			return option.none()
		end

		assert(typeof(v) == "string", (`Value for "{value}" must be a string, got "{typeof(v)}"`))
		return option.some(newCompatSecret(value, v))
	end
}))