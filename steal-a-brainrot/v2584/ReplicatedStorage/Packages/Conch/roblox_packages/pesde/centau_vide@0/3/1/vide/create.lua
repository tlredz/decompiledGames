if not game then
	local module = require("test/relative-string")
	script = module
end

local typeof2 = game and typeof

if not typeof2 then
	local module = require("test/mock")
	typeof2 = module.typeof
end

local instance = game and Instance

if not instance then
	local module = require("test/mock")
	instance = module.Instance
end

local throw = require(script.Parent.throw)
local defaults = require(script.Parent.defaults)
local apply = require(script.Parent.apply)
local v = {}
setmetatable(v, {
	__index = function(ctors, p)
		local success, result = pcall(instance.new, p)

		if not success then
			throw((`invalid class name, could not create instance of class {p}`))
		end

		local default = defaults[p]

		if default then
			for k, v2 in next, default, nil do
				result[k] = v2
			end
		end

		local function ctor(p2)
			return apply(result:Clone(), p2)
		end

		ctors[p] = ctor
		return ctor
	end
})

local function create_instance(p: string)
	return v[p]
end

local function clone_instance(instance2)
	return function(p)
		local clone = instance2:Clone()

		if not clone then
			throw("attempt to clone a non-archivable instance")
		end

		return apply(clone, p)
	end
end

local function create(p)
	if type(p) == "string" then
		return v[p]
	end

	if typeof2(p) == "Instance" then
		return function(p2)
			local clone = p:Clone()

			if not clone then
				throw("attempt to clone a non-archivable instance")
			end

			return apply(clone, p2)
		end
	end

	throw("bad argument #1, expected string or instance, got " .. typeof2(p))
	return nil
end

return create