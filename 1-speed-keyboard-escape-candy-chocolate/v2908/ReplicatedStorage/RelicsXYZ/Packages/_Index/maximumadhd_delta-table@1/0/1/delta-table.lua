local DeltaTable = {}
local Deep

Deep = function(list)
	local result = table.create(#list)
	setmetatable(result, (getmetatable(list)))

	for k, v in pairs(list) do
		if type(v) == "table" then
			result[k] = Deep(v)
		else
			result[k] = v
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetDeltaKey(value)
	if type(value) == "number" then
		return (`_#{value}`)
	end

	return value
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ParseDeltaKey(value)
	if type(value) == "string" and value:sub(1, 2) == "_#" then
		return (tonumber(value:sub(3)))
	end

	return value
end

local Apply

Apply = function(options, p, p2)
	local __deletions = p.__deletions
	local result = options or {}

	for k in p do
		if k == "__deletions" then
			continue
		end

		local parseDeltaKey = ParseDeltaKey(k) -- equivalent call inferred; original call site unknown

		if p2 then
			table.insert(p2.Path, (tostring(parseDeltaKey)))
		end

		if type(p[k]) == "table" then
			result[parseDeltaKey] = Apply(result[parseDeltaKey], p[k], p2)
		else
			result[parseDeltaKey] = p[k]

			if p2 then
				p2.OnApply(p2.Path, p[k])
			end
		end

		if p2 then
			table.remove(p2.Path)
		end
	end

	if not __deletions then
		return result
	end

	for _, __deletion in pairs(__deletions) do
		result[__deletion] = nil

		if not p2 then
			continue
		end

		table.insert(p2.Path, __deletion)
		p2.OnApply(p2.Path, nil)
		table.remove(p2.Path)
	end

	return result
end

DeltaTable.DeepCopy = Deep

function DeltaTable.Create(items, items2, p: number?)
	if items == nil then
		return Deep(items2), 0
	end

	local total = 0
	local result = {}

	for k, item in pairs(items2) do
		local deltaKey = GetDeltaKey(k) -- equivalent call inferred; original call site unknown

		if items[k] == nil then
			total += 1
			result[deltaKey] = item
		elseif type(items2[k]) == "table" then
			local v2, v3 = DeltaTable.Create(items[k], items2[k])

			if v3 > 0 then
				total += v3
				result[deltaKey] = v2
			end
		else
			local item2 = items[k]
			local item3 = items2[k]

			if p then
				if type(item2) == "number" and type(item3) == "number" then
					if math.abs(item2 - item3) < p then
						continue
					end
				elseif type(item2) == "vector" and type(item3) == "vector" and vector.magnitude(item3 - item2) < p then
					continue
				end
			end

			if item2 ~= item3 then
				total += 1
				result[deltaKey] = item3
			end
		end
	end

	local deletions = {}

	for k in pairs(items) do
		if items2[k] ~= nil then
			continue
		end

		table.insert(deletions, k)
		total += 1
	end

	if next(deletions) then
		result.__deletions = deletions
	end

	return result, total
end

function DeltaTable.Apply(p, p2, onApply)
	return (Apply(p, p2, onApply and {
		Path = {},
		OnApply = onApply
	} or nil))
end

return DeltaTable