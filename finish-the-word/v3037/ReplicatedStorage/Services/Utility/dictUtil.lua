local removeFunctions

removeFunctions = function(item)
	for k, item2 in pairs(item) do
		if type(item2) == "function" then
			item[k] = nil
		elseif type(item2) == "table" then
			removeFunctions(item2)
		end
	end
end

local DictUtil = {
	count = function(p)
		local count = 0

		for k, _ in pairs(p._State or p) do
			if not (type(k) ~= "string" or k:sub(1, 1) ~= "_") then
				continue
			end

			count += 1
		end

		return count
	end,
	index = function(p, items)
		for _, item in pairs(items) do
			p = p[item]
		end

		return p
	end
}

function DictUtil.keychainSet(p, list, p2)
	local v = table.remove(list, #list)
	local index = DictUtil.index(p, list)
	index[v] = p2
end

function DictUtil.firstKey(items)
	for k in pairs(items) do
		return k
	end

	return nil
end

function DictUtil.reduce(items, p, callback)
	for k, item in pairs(items) do
		p = callback(k, item, p)
	end

	return p
end

function DictUtil.sum(p)
	return DictUtil.reduce(p, 0, function(_, p2, p3)
		return p3 + p2
	end)
end

function DictUtil.deserializeKeychain(value)
	return value:split(".")
end

function DictUtil.getValueFromKeyChain(p, p2)
	local deserializeKeychain = DictUtil.deserializeKeychain(p2)

	for _, v in pairs(deserializeKeychain) do
		if type(p) ~= "table" then
			return nil, false
		end

		p = rawget(p, tonumber(v) or v)

		if p == nil then
			return nil, false
		end
	end

	return p, true
end

function DictUtil.deepCopy(items)
	local copies = {}

	for k, copy in pairs(items) do
		if type(copy) == "table" then
			copy = DictUtil.deepCopy(copy)
		end

		copies[k] = copy
	end

	return copies
end

function DictUtil.shallowCopy(items)
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

function DictUtil.has(items, callback)
	for _, item in pairs(items) do
		if callback(item) then
			return true, item
		end
	end
end

function DictUtil.find(items, p)
	for k, item in pairs(items) do
		if p == item then
			return k, item
		end
	end
end

function DictUtil.findIndex(list, callback)
	for i, v in ipairs(list) do
		if callback(v) then
			return i
		end
	end
end

function DictUtil.findKey(items, callback)
	for k, item in pairs(items) do
		if callback(item) then
			return k
		end
	end
end

function DictUtil.all(items, callback)
	for _, item in pairs(items) do
		if not callback(item) then
			return false, item
		end
	end

	return true
end

function DictUtil.subMatch(p, items)
	for k, item in pairs(items) do
		if type(item) == "table" and type(p[k]) == "table" then
			if not DictUtil.match(p[k], item) then
				return
			end
		elseif item ~= p[k] then
			return false
		end
	end

	return true
end

function DictUtil.match(p, p2)
	return DictUtil.subMatch(p, p2) and DictUtil.subMatch(p2, p)
end

function DictUtil:remove(p2)
	local v = self[p2]
	self[p2] = nil
	return v
end

function DictUtil:clear()
	for k, _ in pairs(self) do
		self[k] = nil
	end
end

function DictUtil.appendArray(list, items)
	for _, item in pairs(items) do
		table.insert(list, item)
	end
end

function DictUtil.invertArray(list)
	local result = {}

	for i, v in ipairs(list) do
		result[v] = i
	end

	return result
end

function DictUtil:shiftArray()
	local v = 1

	for i = 1, #self do
		if self[i] == nil then
			continue
		end

		if i ~= v then
			self[v] = self[i]
			self[i] = nil
		end

		v += 1
	end

	return self
end

function DictUtil:fillDict(p)
	for k, item in pairs(self) do
		local v = p[k]
		local typeName = type(item)
		local typeName2 = type(v)

		if typeName == "table" then
			local _Insertable = item._Insertable
			item._Insertable = nil

			if v then
				if typeName2 == "table" then
					if _Insertable then
						self[k] = DictUtil.merge(item, v)
					else
						DictUtil.fillDict(item, v)
					end
				end
			else
				DictUtil.fillDict(item, {})
			end
		elseif typeName2 == typeName then
			self[k] = v
		end
	end

	return self
end

function DictUtil:fill(items)
	for k, item in pairs(items) do
		self[k] = item
	end
end

function DictUtil.set(...)
	local result = {}

	for _, v in pairs({ ... }) do
		result[v] = true
	end

	return result
end

function DictUtil.deepSet(...)
	local merged = {}

	for _, v in pairs({ ... }) do
		if type(v) == "table" then
			merged = DictUtil.merge(merged, DictUtil.deepSet(unpack(v)))
		else
			merged[v] = true
		end
	end

	return merged
end

function DictUtil.map(items, callback)
	local result = {}

	for k, item in pairs(items) do
		local v, v2 = callback(k, item)
		result[v] = v2
	end

	return result
end

function DictUtil.merge(...)
	local result = {}

	for _, v in pairs({ ... }) do
		for k, v2 in pairs(v) do
			result[k] = v2
		end
	end

	return result
end

function DictUtil.arrayMerge(p, items)
	local clone = table.clone(p)

	for _, item in pairs(items) do
		table.insert(clone, item)
	end

	return clone
end

function DictUtil.runDescendantsOfType(instance, p, callback, callback2, p2)
	if callback2 and callback2(instance) then
		return
	end

	local children = instance:GetChildren()

	for _, v in pairs(children) do
		local v2

		if v.ClassName == p then
			v2 = v
		else
			v2 = false
		end

		if v2 then
			callback(v2)
		end

		DictUtil.runDescendantsOfType(v, p, callback, callback2, p2)
	end
end

function DictUtil.getDescendantsOfType(folder, className)
	local descendants = folder:GetDescendants()
	local descendants2 = {}

	for _, descendant in pairs(descendants) do
		if descendant:IsA(className) then
			descendants2[#descendants2 + 1] = descendant
		end
	end

	return descendants2
end

function DictUtil.normalizeKeys(items)
	if type(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in pairs(items) do
		local v

		if type(k) == "string" then
			v = tonumber(k)

			if v then
				if tostring(v) ~= k then
					v = k
				end
			else
				v = k
			end
		else
			v = k
		end

		result[v] = DictUtil.normalizeKeys(item)
	end

	return result
end

local v = {
	userdata = true,
	["function"] = true
}

function DictUtil.tableToFolder(items, name)
	local folder = Instance.new("Folder")
	folder.Name = name

	for k, item in pairs(items) do
		if type(item) == "table" then
			local tableToFolder = DictUtil.tableToFolder(item, k)
			tableToFolder.Parent = folder
		elseif not v[type(item)] then
			folder:SetAttribute(k, item)
		end
	end

	return folder
end

function DictUtil.folderToTable(instance)
	local result = {}

	for k, v2 in pairs(instance:GetAttributes()) do
		result[k] = v2
	end

	for i, child in pairs(instance:GetChildren()) do
		result[i] = DictUtil.folderToTable(child)
	end

	return result
end

function DictUtil.isArray(items)
	local count = 0

	for k, _ in pairs(items) do
		count += 1

		if k ~= count then
			return false
		end
	end

	return true
end

return DictUtil