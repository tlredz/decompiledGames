local SettingsLive = {}
local cloneTable

cloneTable = function(items)
	if typeof(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in items do
		result[k] = cloneTable(item)
	end

	return result
end

local sanitize

sanitize = function(list, defaults)
	if defaults[1] == nil then
		local result = {}

		for k, v in defaults do
			local v2 = list[k]

			if typeof(v) == "table" then
				if typeof(v2) ~= "table" then
					v2 = v
				end

				result[k] = sanitize(v2, v)
			elseif typeof(v2) == typeof(v) then
				result[k] = v2
			else
				result[k] = v
			end
		end

		return result
	else
		if list[1] == nil then
			return (cloneTable(defaults))
		end

		local typeName = typeof(defaults[1])
		local result = {}

		for _, v in list do
			if typeof(v) == typeName then
				result[#result + 1] = v
			end
		end

		if #result == 0 then
			return (cloneTable(defaults))
		end

		return result
	end
end

local reconcile

reconcile = function(p, list)
	for k, v in list do
		if typeof(v) == "table" then
			local v2 = p[k]

			if typeof(v2) ~= "table" then
				v2 = {}
				p[k] = v2
			end

			reconcile(v2, v)
		else
			p[k] = v
		end
	end

	if list[1] ~= nil then
		local v = #list + 1

		while p[v] ~= nil do
			p[v] = nil
			v += 1
		end
	end
end

function SettingsLive.new(KEY: string, p2, p3)
	local v = {
		KEY = KEY,
		Defaults = cloneTable(p3)
	}

	function v.normalize(p4)
		if typeof(p4) == "table" then
			return (sanitize(p4, v.Defaults))
		end

		return (cloneTable(v.Defaults))
	end

	function v.apply(p4)
		if typeof(p4) ~= "table" then
			return
		end

		reconcile(p2, (sanitize(p4, v.Defaults)))
	end

	return v
end

function SettingsLive.surface(items)
	local result = {}

	for k, item in items do
		local typeName = typeof(item)

		if typeName == "number" or typeName == "string" or typeName == "boolean" then
			result[k] = item
		elseif typeName == "table" then
			local surface = SettingsLive.surface(item)

			if next(surface) ~= nil then
				result[k] = surface
			end
		end
	end

	return result
end

return SettingsLive