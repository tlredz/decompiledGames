require(script.Parent.Types)

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function SampleCurve(p: number, p2: number, p3: number, p4: number)
	return ((p * p4 + p2) * p4 + p3) * p4
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function SampleDerivative(p: number, p2: number, p3: number, p4: number)
	return (p * 3 * p4 + p2 * 2) * p4 + p3
end

local function SolveCubicBezier(p: number, p2: number, p3: number, p4: number, p5: number)
	if p5 <= 0 then
		return 0
	end

	if p5 >= 1 then
		return 1
	end

	if p == p2 and p3 == p4 then
		return p5
	end

	local v = p * 3
	local v2 = (p3 - p) * 3 - v
	local v3 = 1 - v - v2
	local v4 = p2 * 3
	local v5 = (p4 - p2) * 3 - v4
	local v6 = 1 - v4 - v5
	local v7 = p5

	for _ = 1, 8 do
		local v8 = SampleCurve(v3, v2, v, v7) - p5

		if math.abs(v8) < 1e-7 then
			return SampleCurve(v6, v5, v4, v7)
		end

		local sampleDerivative = SampleDerivative(v3, v2, v, v7)

		if math.abs(sampleDerivative) < 1e-7 then
			break
		else
			v7 -= v8 / sampleDerivative
		end
	end

	local v8 = p5
	local v9 = 0
	local v10 = 1

	for _ = 1, 16 do
		local v11 = SampleCurve(v3, v2, v, v8) - p5

		if math.abs(v11) < 1e-7 then
			break
		end

		if v11 > 0 then
			v10 = v8
		else
			v9 = v8
		end

		v8 = (v9 + v10) * 0.5
	end

	return SampleCurve(v6, v5, v4, v8)
end

local function NormalizeHandle(value, value2: number?)
	if type(value) == "number" then
		return value
	end

	return value[value2 or 1] or 0
end

local function LerpScalar(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function LerpArray(s, s2, p: number)
	local result = table.create(#s)

	for i = 1, #s do
		result[i] = s[i] + ((s2[i] or s[i]) - s[i]) * p
	end

	return result
end

local function LerpBezierShape(s, s2, p: number)
	local v = table.create(#s.v)
	local v2 = table.create(#s.i)
	local v3 = table.create(#s.o)

	for i = 1, #s.v do
		local v4 = s.v[i]
		local v5 = s2.v[i]
		local v6 = s.i[i]
		local v7 = s2.i[i]
		local v8 = s.o[i]
		local v9 = s2.o[i]
		v[i] = { v4[1] + (v5[1] - v4[1]) * p, v4[2] + (v5[2] - v4[2]) * p }
		v2[i] = { v6[1] + (v7[1] - v6[1]) * p, v6[2] + (v7[2] - v6[2]) * p }
		v3[i] = { v8[1] + (v9[1] - v8[1]) * p, v8[2] + (v9[2] - v8[2]) * p }
	end

	return {
		v = v,
		i = v2,
		o = v3,
		c = s.c
	}
end

local function FindKeyframes(k, p: number)
	local count = #k

	if count == 0 then
		return nil, nil, 0
	elseif count == 1 then
		return k[1], nil, 0
	end

	local v = k[1]

	if p <= v.t then
		return v, nil, 0
	end

	for i = 2, count do
		local v2 = k[i]

		if p < v2.t then
			return k[i - 1], v2, i - 1
		end
	end

	return k[count], nil, count
end

local function ExtractValue(list)
	if not (list ~= nil and #list ~= 0) then
		return nil
	end

	if type(list[1]) == "table" then
		return list[1]
	end

	return list
end

local function Evaluate(p, p2: number)
	local a = p.a
	local k = p.k

	if a == nil or a == 0 then
		if type(k) == "number" then
			return k
		end

		if type(k) ~= "table" then
			return nil
		end

		if #k > 0 and type(k[1]) == "table" then
			return k[1]
		end

		return k
	else
		local v, v2, _ = FindKeyframes(k, p2)

		if v == nil then
			return nil
		end

		if v2 == nil then
			local s = v.s

			if s == nil or #s == 0 then
				s = nil
			elseif type(s[1]) == "table" then
				s = s[1]
			end

			if s ~= nil then
				return s
			end

			local e = v.e

			if not (e ~= nil and #e ~= 0) then
				return nil
			end

			if type(e[1]) == "table" then
				return e[1]
			end

			return e
		elseif v.h == 1 then
			local s = v.s

			if not (s ~= nil and #s ~= 0) then
				return nil
			end

			if type(s[1]) == "table" then
				return s[1]
			end

			return s
		else
			local t = v.t
			local v3 = v2.t - t

			if v3 <= 0 then
				local s = v.s

				if not (s ~= nil and #s ~= 0) then
					return nil
				end

				if type(s[1]) == "table" then
					return s[1]
				end

				return s
			else
				local v4 = math.clamp((p2 - t) / v3, 0, 1)
				local s = v.s

				if s == nil or #s == 0 then
					s = nil
				elseif type(s[1]) == "table" then
					s = s[1]
				end

				local s2 = v2.s

				if s2 == nil or #s2 == 0 then
					s2 = nil
				elseif type(s2[1]) == "table" then
					s2 = s2[1]
				end

				if not s2 then
					s2 = v.e

					if s2 == nil or #s2 == 0 then
						s2 = nil
					elseif type(s2[1]) == "table" then
						s2 = s2[1]
					end
				end

				if s == nil or s2 == nil then
					return s or s2
				end

				local o = v.o
				local i = v.i

				if o and i then
					local x = o.x

					if type(x) ~= "number" then
						x = x[1] or 0
					end

					local y = o.y

					if type(y) ~= "number" then
						y = y[1] or 0
					end

					local x2 = i.x

					if type(x2) ~= "number" then
						x2 = x2[1] or 0
					end

					local y2 = i.y

					if type(y2) ~= "number" then
						y2 = y2[1] or 0
					end

					v4 = SolveCubicBezier(x, y, x2, y2, v4)
				end

				if type(s) == "number" then
					return s + (s2 - s) * v4
				end

				if type(s) ~= "table" then
					return s
				end

				if #s > 0 and type(s[1]) == "number" then
					return (LerpArray(s, s2, v4))
				end

				return (LerpBezierShape(s, s2, v4))
			end
		end
	end
end

return (table.freeze({
	SolveCubicBezier = SolveCubicBezier,
	Evaluate = Evaluate,
	EvaluateScalar = function(p, p2: number)
		if p == nil then
			return p2
		end

		local evaluate = Evaluate(p, 0)

		if evaluate == nil then
			return p2
		end

		if type(evaluate) == "number" then
			return evaluate
		end

		if type(evaluate) == "table" then
			return evaluate[1] or p2
		end

		return p2
	end,
	EvaluateScalarAtFrame = function(p, p2: number, p3: number)
		if p == nil then
			return p3
		end

		local evaluate = Evaluate(p, p2)

		if evaluate == nil then
			return p3
		end

		if type(evaluate) == "number" then
			return evaluate
		end

		if type(evaluate) == "table" then
			return evaluate[1] or p3
		end

		return p3
	end,
	EvaluateVector = function(p, p2: number, p3)
		if p == nil then
			return p3
		end

		local evaluate = Evaluate(p, p2)

		if evaluate == nil then
			return p3
		end

		if type(evaluate) == "table" then
			return evaluate
		end

		if type(evaluate) == "number" then
			return { evaluate }
		end

		return p3
	end,
	EvaluateColor = function(p, p2: number)
		if p == nil then
			return Color3.new(1, 1, 1)
		end

		local evaluate = Evaluate(p, p2)

		if evaluate == nil then
			return Color3.new(1, 1, 1)
		end

		if type(evaluate) == "table" then
			return Color3.new(evaluate[1] or 1, evaluate[2] or 1, evaluate[3] or 1)
		end

		return Color3.new(1, 1, 1)
	end,
	EvaluateBezierShape = function(p, p2: number)
		if p == nil then
			return nil
		end

		local evaluate = Evaluate(p, p2)

		if evaluate == nil then
			return nil
		end

		if type(evaluate) == "table" and #evaluate > 0 and type(evaluate[1]) ~= "number" then
			return evaluate
		end

		return nil
	end,
	LerpArray = LerpArray
}))