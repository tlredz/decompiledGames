local typeof2 = typeof
local instance = Instance
local defaults = require(script.Parent.defaults)
local apply = require(script.Parent.apply)
local flags = require(script.Parent.flags)

local function create_constructor_for_class(p: string)
	local function constructor(p2)
		local success, result = pcall(instance.new, p)

		if not success then
			error(`invalid class name {p}`, 0)
		end

		if not flags.defaults then
			return apply(result, p2)
		end

		local default = defaults[p]

		if default then
			for k, v in default do
				result[k] = v
			end
		end

		return apply(result, p2)
	end

	return constructor
end

local constructors = {}

local function create(p, p2)
	if type(p) ~= "string" and typeof2(p) ~= "Instance" then
		error("bad argument #1, expected string or instance, got " .. typeof2(p), 0)
	end

	local constructor

	if type(p) == "string" then
		constructor = constructors[p]

		if not constructor then
			constructor = function(p3)
				local success, result = pcall(instance.new, p)

				if not success then
					error(`invalid class name {p}`, 0)
				end

				if not flags.defaults then
					return apply(result, p3)
				end

				local default = defaults[p]

				if default then
					for k, v in default do
						result[k] = v
					end
				end

				return apply(result, p3)
			end

			constructors[p] = constructor
		end
	else
		constructor = function(p3)
			return apply(assert(p:Clone(), "attempt to clone a non-archivable instance"), p3)
		end
	end

	if p2 then
		return (constructor(p2))
	end

	return constructor
end

return create