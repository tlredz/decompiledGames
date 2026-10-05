if not game then
	local module = require("test/relative-string")
	script = module
end

local vector3 = game and Vector3

if not vector3 then
	local module = require("test/mock")
	vector3 = module.Vector3
end

local throw = require(script.Parent.throw)
local graph = require(script.Parent.graph)
local create_node = graph.create_node
local create_source_node = graph.create_source_node
local assert_stable_scope = graph.assert_stable_scope
local evaluate_node = graph.evaluate_node
local update_descendants = graph.update_descendants
local push_child_to_scope = graph.push_child_to_scope

-- equivalent calls inferred from this helper; original call sites unknown
local function Vec3(p: number?, p2: number?, p3: number?)
	return vector3.new(p, p2, p3)
end

local vec3 = Vec3(0, 0, 0) -- equivalent call inferred; original call site unknown
local v2 = {
	number = function(p)
		return vector3.new(p, 0, 0), vec3
	end,
	CFrame = function(cframe)
		return cframe.Position, Vec3(cframe:ToEulerAnglesXYZ())
	end,
	Color3 = function(data)
		local R = data.R
		local G = data.G
		local B = data.B
		return vector3.new(R, G, B), vec3
	end,
	UDim = function(p)
		local scale = p.Scale
		local offset = p.Offset
		return vector3.new(scale, offset, 0), vec3
	end,
	UDim2 = function(p)
		local scale = p.X.Scale
		local offset = p.X.Offset
		local scale2 = p.Y.Scale
		return vector3.new(scale, offset, scale2), Vec3(p.Y.Offset, 0, 0)
	end,
	Vector2 = function(p)
		local X = p.X
		local Y = p.Y
		return vector3.new(X, Y, 0), vec3
	end,
	Vector3 = function(p)
		return p, vec3
	end,
	Rect = function(p)
		local X = p.Min.X
		local Y = p.Min.Y
		local X2 = p.Max.X
		return vector3.new(X, Y, X2), Vec3(p.Max.Y, 0, 0)
	end
}
local v3 = {
	number = function(p, _)
		return p.X
	end,
	CFrame = function(position, data)
		return CFrame.new(position) * CFrame.fromEulerAnglesXYZ(data.X, data.Y, data.Z)
	end,
	Color3 = function(data)
		return Color3.new(math.clamp(data.X, 0, 1), math.clamp(data.Y, 0, 1), (math.clamp(data.Z, 0, 1)))
	end,
	UDim = function(p)
		return UDim.new(p.X, (math.round(p.Y)))
	end,
	UDim2 = function(data, p)
		return UDim2.new(data.X, math.round(data.Y), data.Z, (math.round(p.X)))
	end,
	Vector2 = function(p)
		return Vector2.new(p.X, p.Y)
	end,
	Vector3 = function(p)
		return p
	end,
	Rect = function(data, p)
		return Rect.new(data.X, data.Y, data.Z, p.X)
	end
}
local v4 = {
	__index = function(_, p: string)
		throw((`cannot spring type {p}`))
	end
}
setmetatable(v2, v4)
setmetatable(v3, v4)
local v5 = {}
setmetatable(v5, {
	__mode = "v"
})

local function spring(callback, value: number?, value2: number?)
	local v6 = assert_stable_scope()
	local v7 = 6.283185307179586 / (value or 1)
	local v8 = v7 ^ 2
	local v9 = (value2 or 1) * (2 * v7)

	if v9 > 240 then
		throw("spring damping too high, consider reducing damping or increasing period")
	end

	local v10 = {
		k = v8,
		c = v9,
		x0_123 = vec3,
		x1_123 = vec3,
		v_123 = vec3,
		x0_456 = vec3,
		x1_456 = vec3,
		v_456 = vec3,
		source_value = false
	}
	local v11 = create_source_node(false)

	local function updater_effect()
		local source_value = callback()
		local v13 = v10
		local v14 = v10
		local v15, v16 = v2[typeof(source_value)](source_value)
		v13.x1_123 = v15
		v14.x1_456 = v16
		v10.source_value = source_value
		v5[v10] = v11
		return source_value
	end

	evaluate_node((create_node(v6, updater_effect, false)))
	local x1_123 = v10.x1_123
	local x1_456 = v10.x1_456
	v10.x0_123 = x1_123
	v10.x0_456 = x1_456
	v11.cache = v10.source_value
	return function(...)
		if select("#", ...) == 0 then
			push_child_to_scope(v11)
			return v11.cache
		end

		local cache = ...
		local v14 = v10
		local v15 = v10
		local v16, v17 = v2[typeof(cache)](cache)
		v14.x0_123 = v16
		v15.x0_456 = v17
		v10.v_123 = vec3
		v10.v_456 = vec3
		v5[v10] = v11
		v11.cache = cache
		return cache
	end
end

local function step_springs(p: number)
	for k in next, v5, nil do
		local k2 = k.k
		local c = k.c
		local x0_123 = k.x0_123
		local x1_123 = k.x1_123
		local v_123 = k.v_123
		local x0_456 = k.x0_456
		local x1_456 = k.x1_456
		local v_456 = k.v_456
		local v6 = x0_123 - x1_123
		local v7 = x0_456 - x1_456
		local v8 = v6 * -k2
		local v9 = v7 * -k2
		local v10 = v_123 * -c
		local v11 = v_456 * -c
		local v12 = (v8 + v10) * p
		local v13 = (v9 + v11) * p
		local v14 = v_123 + v12
		local v15 = v_456 + v13
		local v16 = x0_123 + v14 * p
		local v17 = x0_456 + v15 * p
		k.x0_123 = v16
		k.x0_456 = v17
		k.v_123 = v14
		k.v_456 = v15
	end
end

local v6 = {}

local function update_spring_sources()
	for k, v7 in next, v5, nil do
		local x0_123 = k.x0_123
		local x1_123 = k.x1_123
		local v_123 = k.v_123
		local x0_456 = k.x0_456
		local x1_456 = k.x1_456
		local v_456 = k.v_456
		local v8 = x0_123 - x1_123
		local v9 = x0_456 - x1_456

		if (v_123 + v_456 + v8 + v9).Magnitude < 0.0001 then
			table.insert(v6, k)
			v7.cache = k.source_value
		else
			v7.cache = v3[typeof(k.source_value)](x0_123, x0_456)
		end

		update_descendants(v7)
	end

	for _, v7 in next, v6, nil do
		v5[v7] = nil
	end

	table.clear(v6)
end

return function()
	local v7 = 0
	return spring, function(p: number)
		v7 += p

		while v7 > 0.008333333333333333 do
			v7 -= 0.008333333333333333
			step_springs(0.008333333333333333)
		end

		update_spring_sources()
	end
end