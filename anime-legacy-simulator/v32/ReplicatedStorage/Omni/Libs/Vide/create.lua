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
local ctors = {}

local function lazy_init(_, p: string)
	local function ctor(p2)
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

	ctors[p] = ctor
	return ctor
end

setmetatable(ctors, {
	__index = lazy_init
})

local function create(p, p2)
	if type(p) ~= "string" and typeof2(p) ~= "Instance" then
		error("bad argument #1, expected string or instance, got " .. typeof2(p), 0)
	end

	local fn

	if type(p) == "string" then
		fn = ctors[p]
	else
		fn = function(p3)
			local clone = p:Clone()

			if not clone then
				error("attempt to clone a non-archivable instance")
			end

			return module2(clone, p3)
		end
	end

	if p2 then
		return (fn(p2))
	end

	return fn
end

return create