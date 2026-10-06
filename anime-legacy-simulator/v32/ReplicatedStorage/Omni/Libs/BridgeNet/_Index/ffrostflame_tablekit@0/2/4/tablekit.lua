local v = {}

function v.DeepCopy(p)
	local clone = table.clone(p)

	for k, v2 in clone do
		if typeof(v2) == "table" then
			clone[k] = v.DeepCopy(v2)
		end
	end

	return clone
end

function v.MergeDictionary(p, items)
	local clone = table.clone(p)

	for k, item in items do
		clone[k] = item
	end

	return clone
end

function v.Keys(items)
	local result = {}

	for k in items do
		table.insert(result, k)
	end

	return result
end

function v.Values(items)
	local result = {}

	for _, item in items do
		table.insert(result, item)
	end

	return result
end

function v.MergeArrays(p, list)
	local clone = table.clone(p)
	table.move(list, 1, #list, #clone + 1, clone)
	return clone
end

function v.Reconcile(p, items)
	local clone = table.clone(p)

	for k, item in items do
		if clone[k] == nil then
			if typeof(item) == "table" then
				clone[k] = v.DeepCopy(item)
			else
				clone[k] = item
			end
		elseif typeof(items[k]) == "table" then
			if typeof(item) == "table" then
				clone[k] = v.Reconcile(item, items[k])
			else
				clone[k] = v.DeepCopy(items[k])
			end
		end
	end

	return clone
end

function v.IsArray(list)
	local count = 0

	for _ in list do
		count += 1
	end

	return count == #list
end

function v.IsDictionary(list)
	local count = 0

	for _ in list do
		count += 1
	end

	return count ~= #list
end

function v.ToString(items)
	local v2 = {}

	for k, item in items do
		local v3

		if typeof(k) == "string" then
			v3 = `"{tostring(k)}"`
		else
			v3 = tostring(k)
		end

		local v4 = tostring(item)

		if typeof(item) == "string" then
			v4 = `"{v4}"`
		end

		table.insert(v2, (`\t[{v3}] = {v4}`))
	end

	return "{\n" .. table.concat(v2, "\n") .. "\n}"
end

function v.ToArrayString(items)
	local v2 = {}

	for _, item in items do
		local v3 = tostring(item)

		if typeof(item) == "string" then
			v3 = `"{v3}"`
		end

		table.insert(v2, v3)
	end

	return "{" .. table.concat(v2, ", ") .. "}"
end

function v.From(sequence)
	local typeName = typeof(sequence)

	if typeName == "string" then
		return string.split(sequence, "")
	elseif typeName == "Color3" then
		return { sequence.R, sequence.G, sequence.B }
	elseif typeName == "Vector2" then
		return { sequence.X, sequence.Y }
	elseif typeName == "Vector3" then
		return { sequence.X, sequence.Y, sequence.Z }
	elseif typeName == "NumberSequence" then
		return sequence.Keypoints
	elseif typeName == "Vector3int16" then
		return { sequence.X, sequence.Y, sequence.Z }
	elseif typeName == "Vector2int16" then
		return { sequence.X, sequence.Y }
	end

	return { sequence }
end

function v.Filter(items, callback)
	local result = {}

	for _, item in items do
		if callback(item) then
			table.insert(result, item)
		end
	end

	return result
end

function v.Some(items, callback)
	for _, item in items do
		if callback(item) == true then
			return true
		end
	end

	return false
end

function v.IsFlat(items)
	for _, item in items do
		if typeof(item) == "table" then
			return false
		end
	end

	return true
end

function v.Every(items, callback)
	for k, item in items do
		if not callback(item) then
			return false, k
		end
	end

	return true
end

function v.HasKey(p, p2)
	return p[p2] ~= nil
end

function v.HasValue(items, p)
	for _, item in items do
		if item == p then
			return true
		end
	end

	return false
end

function v.IsEmpty(items)
	return next(items) == nil
end

return table.freeze(v)