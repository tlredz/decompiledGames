local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = ReplicatedStorage.shared.utils
local FpUtils = require(utils.FpUtils)
local deepAccumulate

deepAccumulate = function(p, list)
	local function helper(instance)
		local children = instance:GetChildren()

		if instance.ClassName == "ModuleScript" then
			table.insert(list, instance)
		end

		if #children == 0 then
			return list
		end

		for _, v in children do
			deepAccumulate(v, list)
		end

		return list
	end

	return (helper(p))
end

local function validatorMapFn(moduleScript)
	return require(moduleScript)
end

return function(items, p)
	local instances = {}

	for _, item in items do
		local function helper(item2)
			local children = item2:GetChildren()

			if item2.ClassName == "ModuleScript" then
				table.insert(instances, item2)
			end

			if #children == 0 then
				return instances
			end

			for _, v in children do
				deepAccumulate(v, instances)
			end

			return instances
		end

		helper(item)
	end

	local function transformerMapFn(p2)
		return string.lower(p2[p])
	end

	local function validatorPredicateFn(moduleScript)
		if moduleScript.ClassName ~= "ModuleScript" then
			return false
		end

		local success, result = pcall(function()
			return require(moduleScript)
		end)

		if not success then
			return false
		end

		if result[p] then
			return true
		end

		return false
	end

	return FpUtils.keyBy(FpUtils.filterMap(instances, validatorPredicateFn, validatorMapFn), transformerMapFn)
end