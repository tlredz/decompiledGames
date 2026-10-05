local CmdrUtil = {}

local function transformInstanceSet(list)
	local names = {}

	for i = 1, #list do
		names[i] = list[i].Name
	end

	return names, list
end

function CmdrUtil.createTypeDefinition(p: string, callback, callback2)
	return {
		Transform = function(p2: string, _)
			return CmdrUtil.makeFuzzyFinder(callback())(p2)
		end,
		Validate = function(list)
			return #list > 0, ("No valid %q found"):format(p)
		end,
		Autocomplete = function(p2)
			return p2
		end,
		Parse = function(list)
			return callback2(list[1])
		end,
		Default = function()
			return callback()[1]
		end
	}
end

function CmdrUtil.makeFuzzyFinder(enumItems)
	local names = nil
	local children = {}

	if typeof(enumItems) == "Enum" then
		enumItems = enumItems:GetEnumItems()
	end

	if typeof(enumItems) == "Instance" then
		children = enumItems:GetChildren()
		names = {}

		for i = 1, #children do
			names[i] = children[i].Name
		end
	elseif typeof(enumItems) == "table" then
		if typeof(enumItems[1]) == "Instance" or typeof(enumItems[1]) == "EnumItem" or typeof(enumItems[1]) == "table" and typeof(enumItems[1].Name) == "string" then
			names = {}

			for i = 1, #enumItems do
				names[i] = enumItems[i].Name
			end

			children = enumItems
		elseif type(enumItems[1]) == "string" then
			names = enumItems
		elseif enumItems[1] == nil then
			names = {}
		else
			error("MakeFuzzyFinder only accepts tables of instances or strings.")
		end
	else
		error("MakeFuzzyFinder only accepts a table, Enum, or Instance.")
	end

	return function(value, p)
		local result = {}

		for k, v in pairs(names) do
			local v2

			if children then
				v2 = children[k] or v
			else
				v2 = v
			end

			if v:lower() == value:lower() then
				if p then
					return v2
				else
					table.insert(result, 1, v2)
				end
			elseif v:lower():sub(1, #value) == value:lower() then
				result[#result + 1] = v2
			end
		end

		if p then
			return result[1]
		end

		return result
	end
end

function CmdrUtil.makeListableType(data, items)
	local result = {
		Listable = true,
		Transform = data.Transform,
		Validate = data.Validate,
		ValidateOnce = data.ValidateOnce,
		Autocomplete = data.Autocomplete,
		Default = data.Default,
		Parse = function(...)
			return { data.Parse(...) }
		end
	}

	if items then
		for k, item in pairs(items) do
			result[k] = item
		end
	end

	return result
end

return CmdrUtil