local v = {
	"nil",
	"string",
	"number",
	"boolean",
	"Vector2",
	"Vector3",
	"Vector2int16",
	"Vector3int16",
	"CFrame",
	"array",
	"dictionary",
	"arrayRemovals",
	"arrayAdditions",
	"arrayChanges",
	"arrayChangesRemovals",
	"arrayChangesAdditions",
	"dictionaryChanges",
	"dictionaryRemovals",
	"dictionaryRemovalsChanges"
}
local v2 = {}

for k, v3 in v do
	v2[v3] = k
end

local TypeId = {}

function TypeId.isArrayDiff(p: number)
	return p == v2.arrayRemovals or p == v2.arrayAdditions or p == v2.arrayChanges or p == v2.arrayChangesRemovals or p == v2.arrayChangesAdditions
end

function TypeId.isDictionaryDiff(p: number)
	return p == v2.dictionaryChanges or p == v2.dictionaryRemovals or p == v2.dictionaryRemovalsChanges
end

function TypeId.toType(p: number)
	return v[p]
end

function TypeId.fromType(p: string)
	return v2[p]
end

return TypeId