local Items = require(script.Parent.Items)
local gameSettings = require(script.Parent.Parent.gameSettings)
local Utility = require(script.Parent.Parent.Utility)
local ItemRequirements = {
	Resolve = function(valueBase, value: string)
		if valueBase == nil or value == nil then
			return nil
		end

		for childName in string.gmatch(value, "[^%.]+") do
			if valueBase == nil then
				return nil
			else
				valueBase = valueBase:FindFirstChild(childName)
			end
		end

		if valueBase == nil or not valueBase:IsA("ValueBase") then
			return nil
		end

		return valueBase
	end
}

function ItemRequirements.Passes(instance, items)
	if items == nil then
		return true
	end

	if instance == nil then
		return false
	end

	for k, item in pairs(items) do
		if k == "Level" and typeof(item) == "number" then
			local resolved = ItemRequirements.Resolve(instance, "Exp.Goal")

			if resolved == nil or resolved.Value / gameSettings.expPerLevel < item then
				return false
			end
		elseif k == "MaxLevel" and typeof(item) == "number" then
			local resolved = ItemRequirements.Resolve(instance, "Exp.Goal")

			if resolved == nil or item < resolved.Value / gameSettings.expPerLevel then
				return false
			end
		elseif k == "Items" then
			local inventory = instance:FindFirstChild("Inventory")
			local v

			if inventory ~= nil then
				v = inventory:FindFirstChild("Inventory") or nil
			end

			if v == nil then
				return false
			end

			local v2 = typeof(item) ~= "table" and { item } or item
			local v3 = false

			for _, v5 in ipairs(v2) do
				if not (type(v5) == "string" and Utility.HeldItem(instance, v5) ~= nil) then
					continue
				end

				v3 = true
				break
			end

			if not v3 then
				return false
			end
		else
			local resolved = ItemRequirements.Resolve(instance, k)
			local value

			if resolved ~= nil then
				value = resolved.Value
			end

			if typeof(item) == "table" then
				if table.find(item, value) == nil then
					return false
				end
			elseif value ~= item then
				return false
			end
		end
	end

	return true
end

function ItemRequirements.Satisfies(p, p2: string, flag: boolean?)
	local item = Items[p2]
	local requirements

	if item ~= nil then
		requirements = item.Requirements or nil
	end

	if flag == true and item ~= nil and item.NoSaveRequirements ~= nil then
		requirements = item.NoSaveRequirements
	end

	return ItemRequirements.Passes(p, requirements)
end

function ItemRequirements.SatisfiesEquip(p, p2: string)
	local item = Items[p2]
	local passes = ItemRequirements.Passes
	local v

	if item ~= nil then
		v = item.EquipRequirements or nil
	end

	return passes(p, v)
end

function ItemRequirements.Describe(p)
	if p == nil then
		return ""
	end

	local v = {}

	for k, v2 in p do
		if not (k ~= "Level" and k ~= "MaxLevel") then
			continue
		end

		if k == "Items" then
			if typeof(v2) == "table" then
				v2 = v2[1]
			end

			if v2 ~= nil then
				table.insert(v, (`holding an {v2}`))
			end
		elseif typeof(v2) == "table" then
			if v2[1] ~= nil then
				table.insert(v, (tostring(v2[1])))
			end
		else
			table.insert(v, (tostring(v2)))
		end
	end

	if p.Level == nil or p.MaxLevel == nil then
		if p.Level == nil then
			if p.MaxLevel ~= nil then
				table.insert(v, (`Lvl. {p.MaxLevel} max`))
			end
		else
			table.insert(v, (`Lvl. {p.Level}+`))
		end
	else
		table.insert(v, (`Lvl. {p.Level}-{p.MaxLevel}`))
	end

	return table.concat(v, ", ")
end

local result = nil

function ItemRequirements.Keys()
	if result ~= nil then
		return result
	end

	local v = {}

	for _, item in pairs(Items) do
		if typeof(item) ~= "table" then
			continue
		end

		for _, v2 in { item.Requirements, item.NoSaveRequirements, item.EquipRequirements } do
			if typeof(v2) ~= "table" then
				continue
			end

			for k in pairs(v2) do
				v[k] = true
			end
		end
	end

	result = {}

	for k in pairs(v) do
		table.insert(result, k)
	end

	return result
end

return ItemRequirements