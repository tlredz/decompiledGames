local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local typeof2 = game and typeof or require3("../test/mock").typeof
local instance = game and Instance or require3("../test/mock").Instance
local v = require3("./defaults")
local v2 = require3("./apply")
local v3 = require3("./flags")
local ctors = {}

local function lazy_init(_, p: string)
	local function ctor(p2)
		local success, result = pcall(instance.new, p)

		if not success then
			error(`invalid class name {p}`, 0)
		end

		if not v3.defaults then
			return v2(result, p2)
		end

		local v4 = v[p]

		if v4 then
			for k, v5 in v4 do
				result[k] = v5
			end
		end

		return v2(result, p2)
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

			return v2(clone, p3)
		end
	end

	if p2 then
		return (fn(p2))
	end

	return fn
end

return create