local typeof2 = game and typeof

if not typeof2 then
	local module = require("../test/mock")
	typeof2 = module.typeof
end

local instance = game and Instance

if not instance then
	local module = require("../test/mock")
	instance = module.Instance
end

local module = require("./defaults")
local module2 = require("./apply")
local module3 = require("./flags")

local function create_constructor_for_class(p: string)
	local function constructor(p2)
		local success, result = pcall(instance.new, p)

		if not success then
			error(`invalid class name {p}`, 0)
		end

		if not module3.defaults then
			return module2(result, p2)
		end

		local v = module[p]

		if v then
			for k, v2 in v do
				result[k] = v2
			end
		end

		return module2(result, p2)
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

				if not module3.defaults then
					return module2(result, p3)
				end

				local v = module[p]

				if v then
					for k, v2 in v do
						result[k] = v2
					end
				end

				return module2(result, p3)
			end

			constructors[p] = constructor
		end
	else
		constructor = function(p3)
			return module2(assert(p:Clone(), "attempt to clone a non-archivable instance"), p3)
		end
	end

	if p2 then
		return (constructor(p2))
	end

	return constructor
end

return create