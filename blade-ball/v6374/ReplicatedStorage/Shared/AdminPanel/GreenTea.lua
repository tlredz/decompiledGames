local GreenTea = require(script.GreenTea)
local InstanceClasses = require(script.InstanceClasses)
local GreenTea2 = {
	t = require(script.tCompat),
	isGreenTeaType = GreenTea.isGreenTeaType,
	isGtType = GreenTea.isGtType,
	any = GreenTea.any,
	unknown = GreenTea.unknown,
	never = GreenTea.never,
	boolean = GreenTea.boolean,
	bool = GreenTea.bool,
	Instance = GreenTea.Instance,
	isA = InstanceClasses,
	IsA = InstanceClasses,
	coroutine = GreenTea.coroutine,
	thread = GreenTea.thread,
	buffer = GreenTea.buffer,
	userdata = GreenTea.userdata,
	Vector2 = GreenTea.Vector2,
	vector = GreenTea.vector,
	Vector3 = GreenTea.Vector3,
	CFrame = GreenTea.CFrame,
	Color3 = GreenTea.Color3,
	UDim = GreenTea.UDim,
	UDim2 = GreenTea.UDim2,
	Ray = GreenTea.Ray,
	Rect = GreenTea.Rect,
	Region3 = GreenTea.Region3,
	BrickColor = GreenTea.BrickColor,
	Font = GreenTea.Font,
	Enum = GreenTea.Enum,
	EnumItem = GreenTea.EnumItem,
	none = GreenTea.none,
	literal = GreenTea.literal,
	withCustom = GreenTea.withCustom,
	custom = GreenTea.custom,
	number = GreenTea.number,
	string = GreenTea.string,
	isTypeof = GreenTea.isTypeof,
	isType = GreenTea.isType,
	vararg = GreenTea.vararg,
	tuple = GreenTea.tuple,
	args = GreenTea.args,
	returns = GreenTea.returns,
	fn = GreenTea.fn,
	anyfn = GreenTea.anyfn,
	tuplePacked = GreenTea.tuplePacked,
	table = GreenTea.table,
	struct = GreenTea.struct,
	anyTable = GreenTea.anyTable,
	array = GreenTea.array,
	dictionary = GreenTea.dictionary,
	union = GreenTea.union,
	oneOf = GreenTea.oneOf,
	intersection = GreenTea.intersection,
	allOf = GreenTea.allOf,
	optional = GreenTea.optional,
	opt = GreenTea.opt,
	typeof = GreenTea.typeof,
	typecast = GreenTea.typecast,
	asGreenTeaType = GreenTea.asGreenTeaType,
	asGtType = GreenTea.asGtType,
	build = GreenTea.build,
	meta = GreenTea.meta
}
table.freeze(GreenTea2)
table.freeze(GreenTea2.isA)
table.freeze(GreenTea2.t)
table.freeze(GreenTea.__Cause)
table.freeze(GreenTea.__Type)

for k, v in GreenTea2 do
	GreenTea.__greenteaConstructorsSet[v] = `GreenTea.{k}`
end

for k, v in pairs(GreenTea2.isA) do
	GreenTea.__greenteaConstructorsSet[v] = `GreenTea.isA.{k}`
end

for k, v in pairs(GreenTea2.t) do
	GreenTea.__greenteaConstructorsSet[v] = `GreenTea.t.{k}`
end

return GreenTea2