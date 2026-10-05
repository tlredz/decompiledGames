local Bezier = {}
Bezier.__index = Bezier

function Bezier.new(...)
	local v = { ... }
	assert(#v >= 3, "Must have at least 3 points")
	local v2 = #v == 3
	local v3 = #v == 4
	local v4 = {}
	local new = Vector3.new
	local lerp = new().lerp
	local v5 = nil
	local v6 = {}

	local function CreatePoint(data)
		return {
			data.X,
			data.Y,
			data.Z,
			ToVector3 = function(self)
				return (new(self[1], self[2], self[3]))
			end,
			lerp = function(self, object2, p)
				return lerp(self:ToVector3(), object2:ToVector3(), p)
			end
		}
	end

	local v7, v8

	if v2 or v3 then
		v7 = 0
		v8 = nil
	else
		for i = 1, #v - 1 do
			local point = CreatePoint(v[i])
			local v10 = { point, CreatePoint(v[i + 1]), (CreatePoint(point)) }
			v6[#v6 + 1] = v10
		end

		local v9 = v6

		for i = #v6, 2, -1 do
			local v10 = {}

			for i2 = 1, i - 1 do
				local v11 = v9[i2]
				local v12 = v9[i2 + 1]
				local v13 = { v11[3], v12[3], (CreatePoint(v11[3])) }
				v10[i2] = v13
				v6[#v6 + 1] = v13
			end

			v9 = v10
		end

		v8 = v9[1]
		v7 = #v6
	end

	if v2 then
		local v9 = v[1]
		local v10 = v[2]
		local v11 = v[3]

		function v4:Get(p, p2)
			if p2 then
				p = p < 0 and 0 or p > 1 and 1 or p
			end

			return (1 - p) * (1 - p) * v9 + 2 * (1 - p) * p * v10 + p * p * v11
		end
	elseif v3 then
		local v9 = v[1]
		local v10 = v[2]
		local v11 = v[3]
		local v12 = v[4]

		function v4:Get(p, p2)
			if p2 then
				p = p < 0 and 0 or p > 1 and 1 or p
			end

			return (1 - p) * (1 - p) * (1 - p) * v9 + 3 * (1 - p) * (1 - p) * p * v10 + 3 * (1 - p) * p * p * v11 + p * p * p * v12
		end
	else
		function v4:Get(p, p2)
			if p2 then
				p = p < 0 and 0 or p > 1 and 1 or p
			end

			for i = 1, v7 do
				local v9 = v6[i]
				local lerped = v9[1]:lerp(v9[2], p)
				local v10 = v9[3]
				local X = lerped.X
				local Y = lerped.Y
				local Z = lerped.Z
				v10[1] = X
				v10[2] = Y
				v10[3] = Z
			end

			return v8[3]:ToVector3()
		end
	end

	function v4:GetLength(value)
		if v5 then
			return v5
		end

		local path = self:GetPath(value or 0.1)
		local total = 0

		for i = 2, #path do
			total += (path[i - 1] - path[i]).Magnitude
		end

		v5 = total
		return v5
	end

	function v4:GetPath(value)
		assert(type(value) == "number", "Must provide a step increment")
		local v9

		if value > 0 then
			v9 = value < 1
		else
			v9 = false
		end

		assert(v9, "Step out of domain; should be between 0 and 1")
		local result = {}
		local v10 = 0

		for i = 0, 1, value do
			result[#result + 1] = self:Get(i)
			v10 = i
		end

		if v10 < 1 then
			local v11 = 1 - v10 < value * 0.5
			result[#result + (v11 and 0 or 1)] = self:Get(1)
		end

		return result
	end

	function v4.GetPoints(_)
		return v
	end

	return (setmetatable(v4, Bezier))
end

return Bezier