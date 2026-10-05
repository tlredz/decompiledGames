local _ = script.Parent
local DictionaryPathUtil = {
	SEPARATOR = "/"
}

function DictionaryPathUtil.get(p, value: string)
	local parts = value:split(DictionaryPathUtil.SEPARATOR)
	local get

	get = function(p2, p3: number)
		local part = parts[p3]

		if tonumber(part) and p2[tonumber(part)] then
			part = tonumber(part)
		end

		if p3 == #parts then
			return p2[part]
		end

		if p2[part] then
			return get(p2[part], p3 + 1)
		end

		return nil
	end

	return get(p, 1)
end

function DictionaryPathUtil.search(p, flag: boolean, flag2: boolean, p2: string?)
	local result = {}
	local search

	search = function(items, p3: string)
		if p3 ~= "" then
			p3 ..= DictionaryPathUtil.SEPARATOR
		end

		for k, item in pairs(items) do
			if not (type(k) ~= "number" or type(k) == "number" and flag) then
				continue
			end

			local v = p3 .. tostring(k)

			if type(item) == "table" then
				if flag2 then
					result[v] = item
				end

				search(item, v)
			else
				result[v] = item
			end
		end
	end

	if not p2 then
		search(p, "")
		return result
	end

	local v = DictionaryPathUtil.get(p, p2)

	if not v then
		return {}
	end

	assert(type(v) == "table")
	search(v, "")
	return result
end

function DictionaryPathUtil.set(p, value: string, p2)
	local parts = value:split(DictionaryPathUtil.SEPARATOR)
	local set

	set = function(p3, p4: number)
		local part = parts[p4]

		if tonumber(part) then
			part = tonumber(part)
		end

		if p4 == #parts then
			p3[part] = p2
			return
		end

		if not p3[part] then
			p3[part] = {}
		end

		set(p3[part], p4 + 1)
	end

	return set(p, 1)
end

return DictionaryPathUtil