local createVector = vector.create
local module = require("./merge")
local module2 = require("./oklab")
local v = {
	number = function(list, p: number)
		list[1] = p
	end,
	vector = function(list, vector2: Vector3)
		list[1] = vector2
	end,
	Vector3 = function(list, vector2: Vector3)
		list[1] = vector2
	end,
	table = function(p, items)
		for k, item in items do
			p[k] = item
		end
	end,
	Vector2 = function(vectors, point: Vector2)
		vectors[1] = vector.create(point.X, point.Y, 0)
	end,
	CFrame = function(list, cframe: CFrame)
		list[1] = cframe.Position
		list[2] = cframe.XVector
		list[3] = cframe.YVector
		list[4] = cframe.ZVector
	end,
	Color3 = function(list, color: Color3)
		list[1] = module2.fromSRGB((vector.create(color.R, color.G, color.B)))
	end,
	UDim = function(vectors, udim: UDim)
		vectors[1] = vector.create(udim.Scale, udim.Offset, 0)
	end,
	UDim2 = function(list, udim: UDim2)
		list[1] = vector.create(udim.X.Scale, udim.X.Offset, udim.Y.Scale)
		list[2] = udim.Y.Offset
	end,
	Rect = function(list, rect: Rect)
		list[1] = vector.create(rect.Min.X, rect.Min.Y, rect.Max.X)
		list[2] = rect.Max.Y
	end
}
local v2 = {
	number = function(list)
		return list[1]
	end,
	vector = function(list)
		return list[1]
	end,
	Vector3 = function(list)
		return list[1]
	end,
	table = function(p)
		return table.clone(p)
	end,
	Vector2 = function(list)
		local v3 = list[1]
		return Vector2.new(v3.x, v3.y)
	end,
	CFrame = function(list)
		return CFrame.fromMatrix(list[1], list[2], list[3], list[4]):Orthonormalize()
	end,
	Color3 = function(list)
		local v3 = vector.max(module2.toSRGB(list[1]), createVector(0, 0, 0))
		return Color3.new(v3.x, v3.y, v3.z)
	end,
	UDim = function(list)
		local v3 = list[1]
		return UDim.new(v3.x, (math.round(v3.y)))
	end,
	UDim2 = function(list)
		local v3 = list[1]
		local v4 = list[2]
		return UDim2.new(v3.x, math.round(v3.y), v3.z, (math.round(v4)))
	end,
	Rect = function(list)
		local v3 = list[1]
		local v4 = list[2]
		return Rect.new(v3.x, v3.y, v3.z, v4)
	end
}
local Intermediate = {}

function Intermediate.create(p)
	local typeName = typeof(p)
	local components = {}
	local encode = v[typeName]
	local decode = v2[typeName]

	if not (encode and decode) then
		error((`Unsupported type {typeName} for Ripple animation value`))
	end

	encode(components, p)
	return {
		components = components,
		value = p,
		encode = encode,
		decode = decode
	}
end

function Intermediate.copy(data)
	return {
		components = table.clone(data.components),
		value = data.value,
		encode = data.encode,
		decode = data.decode
	}
end

function Intermediate.zero(p)
	local components = p.components

	for k in components do
		components[k] *= 0
	end

	p.dirty = true
	return p
end

function Intermediate.setValue(state, p)
	local decoded

	if state.dirty then
		decoded = state.decode(state.components)
		state.value = decoded
		state.dirty = nil
	else
		decoded = state.value
	end

	if type(p) == "table" then
		p = module(decoded, p)
	end

	if p == decoded then
		return false
	end

	state.encode(state.components, p)
	state.value = p
	state.dirty = nil
	return true
end

function Intermediate.addValue(state, p)
	local v3 = {}
	state.encode(v3, p)

	for k, v4 in v3 do
		state.components[k] += v4
	end

	state.dirty = true
end

function Intermediate.getValue(state)
	if not state.dirty then
		return state.value
	end

	local decoded = state.decode(state.components)
	state.value = decoded
	state.dirty = nil
	return decoded
end

function Intermediate.recomputeValue(state)
	local decoded = state.decode(state.components)
	state.value = decoded
	state.dirty = nil
	return decoded
end

function Intermediate.assign(p, state)
	for k, component in state.components do
		p.components[k] = component
	end

	local decoded

	if state.dirty then
		decoded = state.decode(state.components)
		state.value = decoded
		state.dirty = nil
	else
		decoded = state.value
	end

	p.value = decoded
	p.dirty = nil
end

function Intermediate.lerp(p, p2, p3, p4: number)
	for k, component in p3.components do
		local component2 = p2.components[k]
		p.components[k] = component2 + (component - component2) * p4
	end

	p.dirty = true
end

return Intermediate