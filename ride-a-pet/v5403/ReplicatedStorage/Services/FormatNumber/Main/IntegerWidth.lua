local _internal = require(script.Parent.Parent._internal)
local v = {}
local v2 = {}
local create_init_function = _internal.class.create_init_function(
	"IntegerWidth",
	nil,
	v2,
	nil,
	_internal.class.ImmutabilityType.DEFAULT
)

function v2.TruncateAt(p, p2: number)
	local try_coerce = _internal.class.try_coerce(1, p, "IntegerWidth")
	local max = tonumber(p2) and math.ceil(p2) == -1 and -1 or _internal.class.try_coerce_range(
		1,
		p2,
		try_coerce.min,
		999
	)
	return create_init_function({
		min = try_coerce.min,
		max = max
	})
end

function v.zeroFillTo(p: number)
	return create_init_function({
		min = _internal.class.try_coerce_range(1, p, 0, 999),
		max = -1
	})
end

return table.freeze(v)