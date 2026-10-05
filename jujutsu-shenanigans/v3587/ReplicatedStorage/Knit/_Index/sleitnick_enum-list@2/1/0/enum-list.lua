local v = newproxy()
local v2 = newproxy()

-- equivalent calls inferred from this helper; original call sites unknown
local function CreateEnumItem(name: string, i: number, enumType)
	local v3 = {
		Name = name,
		Value = i,
		EnumType = enumType
	}
	table.freeze(v3)
	return v3
end

local EnumList = {}
EnumList.__index = EnumList

function EnumList.new(value: string, list)
	assert(type(value) == "string", "Name string required")
	assert(type(list) == "table", "Enums table required")
	local enumType = {
		[v] = {},
		[v2] = value
	}

	for i, v4 in ipairs(list) do
		assert(type(v4) == "string", "Enum name must be a string")
		local enumItem = CreateEnumItem(v4, i, enumType) -- equivalent call inferred; original call site unknown
		enumType[v4] = enumItem
		table.insert(enumType[v], enumItem)
	end

	return table.freeze((setmetatable(enumType, EnumList)))
end

function EnumList.BelongsTo(p, p2)
	return type(p2) == "table" and p2.EnumType == p
end

function EnumList.GetEnumItems(p)
	return p[v]
end

function EnumList.GetName(p)
	return p[v2]
end

return EnumList