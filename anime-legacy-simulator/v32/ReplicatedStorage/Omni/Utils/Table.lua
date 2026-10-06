local class = {}

function class:Reconcile(p, items)
	for k, item in pairs(items) do
		if type(k) ~= "string" then
			continue
		end

		if p[k] == nil then
			if type(item) == "table" then
				p[k] = class:DeepCopy(item)
			else
				p[k] = item
			end
		elseif type(p[k]) == "table" and type(item) == "table" then
			class:Reconcile(p[k], item)
		end
	end
end

function class:Clear(items)
	for k, item in items do
		if typeof(item) == "RBXScriptConnection" then
			item:Disconnect()
		elseif typeof(item) == "Instance" then
			item:Destroy()
		elseif typeof(item) == "table" then
			if item.Disconnect then
				item:Disconnect()
			elseif item.Destroy then
				item:Destroy()
			else
				class:Clear(item)
			end
		end

		items[k] = nil
	end
end

function class:Match(items, p)
	for k, item in items do
		if typeof(item) == "table" then
			if not class:Match(item, p[k]) then
				return false
			end
		elseif item ~= p[k] then
			return false
		end
	end

	return true
end

function class:IsEqual(items, items2, p)
	if items == items2 then
		return true
	end

	if typeof(items) ~= "table" or typeof(items2) ~= "table" then
		return false
	end

	for k, item in items do
		if k ~= p and not class:IsEqual(item, items2[k]) then
			return false
		end
	end

	for k in items2 do
		if k ~= p and items[k] == nil then
			return false
		end
	end

	return true
end

function class:DeepCopy(items, options)
	local v = options or {}

	if v[items] then
		return v[items]
	end

	local result = {}
	v[items] = result

	for k, item in pairs(items) do
		if type(item) == "table" then
			result[k] = class:DeepCopy(item, v)
		else
			result[k] = item
		end
	end

	local metatable = getmetatable(items)

	if metatable then
		setmetatable(result, metatable)
	end

	return result
end

function class.Size(_, items)
	local count = 0

	for _, _ in items do
		count += 1
	end

	return count
end

function class.IndexFromDictionary(_, items, p: number)
	local result = {}

	for k, item in items do
		table.insert(result, {
			Index = k,
			Value = item
		})
	end

	local v = result[p] or {}
	return v.Index, v.Value, result
end

function class.CframeToArray(_, cframe: CFrame)
	return { cframe:GetComponents() }
end

function class.ArrayToCFrame(_, list)
	return CFrame.new(unpack(list))
end

function class.Random(_, items)
	local v = {}

	for k, _ in items do
		table.insert(v, k)
	end

	return v[math.random(1, #v)]
end

function class.RandomWithWeight(_, items)
	local total = 0

	for _, item in items do
		if type(item) == "number" and tonumber(item) then
			total += tonumber(item)
		end
	end

	local v2 = math.random(1, total)

	for k, item in items do
		if not (type(item) == "number" and tonumber(item)) then
			continue
		end

		v2 -= item

		if v2 <= 0 then
			return k
		end
	end

	return nil
end

function class.ChancesFromWeight(_, items)
	local total = 0
	local result = {}

	for _, item in items do
		if type(item) == "number" and tonumber(item) then
			total += tonumber(item)
		end
	end

	for k, item in items do
		if type(item) == "number" and tonumber(item) then
			result[k] = tonumber(item) / total
		end
	end

	return result
end

function class.MergeClasses(_, parents)
	if not parents or typeof(parents) ~= "table" then
		return
	end

	local class2 = {}
	class2.__index = class2
	class2.__parents = parents

	function class2.new()
		local v = {
			__parents = {}
		}

		for k, __parent in class2.__parents do
			local v2 = __parent.new()

			function v2.Get(_, value: string)
				if value and typeof(value) == "string" then
					return v.__parents[value]
				end
			end

			v.__parents[k] = v2
		end

		setmetatable(v, class2)

		if v.Init then
			v:Init()
		end

		return v
	end

	function class2:Get(value: string)
		if value and typeof(value) == "string" then
			return self.__parents[value]
		end
	end

	return class2
end

return table.freeze(class)