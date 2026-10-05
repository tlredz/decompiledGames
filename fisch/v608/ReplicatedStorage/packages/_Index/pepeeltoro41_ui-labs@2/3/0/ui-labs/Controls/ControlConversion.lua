local PrimitiveControls = require(script.Parent.PrimitiveControls)
local primitive = PrimitiveControls.Primitive
local DatatypeControls = require(script.Parent.DatatypeControls)

local function ConvertPrimitive(p, typeName: string)
	local v = primitive[typeName]
	assert(v, (`UI-Labs: Primitive ({typeName}) can't be converted to a control`))
	return v(p)
end

local function ConvertDatatype(p, typeName: string)
	local datatypeControl = DatatypeControls[typeName]
	assert(datatypeControl, (`UI-Labs: Datatype ({typeName}) can't be converted to a control`))
	return datatypeControl(p)
end

return {
	ConvertControl = function(p)
		local typeName = typeof(p)

		if typeName == "table" then
			return p
		end

		if primitive[typeName] then
			return ConvertPrimitive(p, typeName)
		end

		if DatatypeControls[typeName] then
			return ConvertDatatype(p, typeName)
		end

		error((`UI-Labs: Control ({p}) is not a valid control`))
	end
}