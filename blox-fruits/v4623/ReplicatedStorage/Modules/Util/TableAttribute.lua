local HttpService = game:GetService("HttpService")

-- equivalent calls inferred from this helper; original call sites unknown
local function set(instance, p: string, items)
	if next(items) then
		instance:SetAttribute(p, HttpService:JSONEncode(items))
	else
		instance:SetAttribute(p, nil)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function get(instance, attributeName: string)
	return HttpService:JSONDecode(instance:GetAttribute(attributeName) or "[]")
end

local TableAttribute = {}

function TableAttribute.SetKey(_, instance, attributeName: string, value, p)
	if typeof(value) ~= "string" then
		return
	end

	local v = get(instance, attributeName) -- equivalent call inferred; original call site unknown
	v[value] = p
	set(instance, attributeName, v) -- equivalent call inferred; original call site unknown
end

function TableAttribute.ArrayInsert(_, instance, attributeName: string, p)
	local v = get(instance, attributeName) -- equivalent call inferred; original call site unknown
	table.insert(v, p)
	set(instance, attributeName, v) -- equivalent call inferred; original call site unknown
end

function TableAttribute.ArrayFindAndRemove(_, instance, attributeName: string, p)
	local v = get(instance, attributeName) -- equivalent call inferred; original call site unknown
	local index = table.find(v, p)

	if index then
		table.remove(v, index)
	end

	set(instance, attributeName, v) -- equivalent call inferred; original call site unknown
end

function TableAttribute.Get(_, p, p2)
	return get(p, p2)
end

function TableAttribute.Set(_, p, p2, p3)
	return set(p, p2, p3)
end

return TableAttribute