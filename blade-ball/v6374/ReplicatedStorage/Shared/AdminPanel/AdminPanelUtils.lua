local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Shared.DeepCopy)
local v3 = require3(ReplicatedStorage2.Packages.Freeze)
local calculateDeltaTables

calculateDeltaTables = function(p, items, p2, flag: boolean?)
	local v4 = flag ~= false
	local v5 = p2 or v3.None

	if p == nil or p == v5 then
		return v5
	end

	local result = v2(p)

	for k, _ in items do
		if result[k] == nil then
			result[k] = v5
		end
	end

	for k, v6 in result do
		if v6 == v5 then
			continue
		end

		if type(v6) == "table" and type(items[k]) == "table" and v4 then
			result[k] = calculateDeltaTables(v6, items[k], v5)
		elseif v3.Dictionary.equals(items[k], v6) then
			result[k] = nil
		end
	end

	if v3.Dictionary.count(result) == 0 then
		return nil
	end

	return result
end

local applyDeltaTables

applyDeltaTables = function(item, p, p2)
	if p == nil then
		return v2(item)
	end

	if item == nil then
		return v2(p)
	end

	local result = v2(p)

	for k, item2 in item do
		if item2 == p2 then
			result[k] = p2
		elseif type(item2) == "table" then
			result[k] = applyDeltaTables(item2, p[k], p2)
		else
			result[k] = item2
		end
	end

	return result
end

local applyDeltaTablesToReplion

applyDeltaTablesToReplion = function(none, object, clone, p)
	if object:Get(clone) == nil then
		object:Set(clone, none)
		return
	end

	local nones = {}
	local flag = false

	for k, none2 in none do
		if type(none2) == "table" then
			local clone2 = table.clone(clone)
			table.insert(clone2, k)
			applyDeltaTablesToReplion(none2, object, clone2, p)
		else
			flag = true

			if none2 == p then
				none2 = v.None
			end

			nones[k] = none2
		end
	end

	if flag then
		object:Update(clone, nones)
	end
end

local replaceNoneKey

replaceNoneKey = function(p, p2, p3)
	if type(p) == "table" then
		local clone = table.clone(p)

		for k, v4 in clone do
			clone[k] = replaceNoneKey(v4, p2, p3)
		end

		return clone
	elseif p == p2 then
		return p3
	else
		return p
	end
end

return {
	calculateDeltaTables = calculateDeltaTables,
	applyDeltaTables = applyDeltaTables,
	applyDeltaTablesToReplion = applyDeltaTablesToReplion,
	replaceNoneKey = replaceNoneKey
}