local spline = {}
local new = Vector3.new
local new2 = CFrame.new

local function solve(list, list2, list3, list4, p)
	local v2 = p * p
	local v3 = v2 * p
	return (new(
		(list[1] + list2[1] * p + list3[1] * v2 + list4[1] * v3) / 2,
		(list[2] + list2[2] * p + list3[2] * v2 + list4[2] * v3) / 2,
		(list[3] + list2[3] * p + list3[3] * v2 + list4[3] * v3) / 2
	))
end

function spline.create(data, data2, data3, data4)
	local cA = { 2 * data2.X, 2 * data2.Y, 2 * data2.Z }
	local cB = { -data.X + data3.X, -data.Y + data3.Y, -data.Z + data3.Z }
	local cC = {
		2 * data.X - 5 * data2.X + 4 * data3.X - data4.X,
		2 * data.Y - 5 * data2.Y + 4 * data3.Y - data4.Y,
		2 * data.Z - 5 * data2.Z + 4 * data3.Z - data4.Z
	}
	local cD = {
		-data.X + 3 * data2.X - 3 * data3.X + data4.X,
		-data.Y + 3 * data2.Y - 3 * data3.Y + data4.Y,
		-data.Z + 3 * data2.Z - 3 * data3.Z + data4.Z
	}
	local v6 = solve(cA, cB, cC, cD, 0)
	local total = 0
	local v7 = {
		cA = cA,
		cB = cB,
		cC = cC,
		cD = cD,
		length = 0
	}

	for i = 0, 0.95, 0.05 do
		local v8 = solve(cA, cB, cC, cD, i + 0.05)
		total += (v8 - v6).magnitude
		v6 = v8
	end

	v7.length = total * 0.05
	return (setmetatable(v7, {
		__index = spline
	}))
end

function spline:Solve(p)
	return (solve(self.cA, self.cB, self.cC, self.cD, p))
end

function spline:SolveNorm(p, value)
	return new2(self:Solve(p), self:Solve(p + (value or 0.01)))
end

local path = {}

function path.create(list)
	assert(#list >= 4, "At least four points are required to construct a spline path")
	local parts = {}
	local v5 = nil
	local v6 = nil
	local count = #list
	local v7 = list[1] == list[count]
	local v8

	if v7 then
		v8 = spline.create(list[2]:Lerp(list[1], 2), list[1], list[2], list[3])
	else
		v8 = spline.create(list[count], list[1], list[2], list[3])
	end

	local v9 = 0 + v8.length
	parts[1] = v8

	for i, v10 in ipairs(list) do
		local v11 = list[i + 1]

		if v5 and v6 and v11 then
			local v12 = spline.create(v5, v6, v10, v11)
			v9 += v12.length
			parts[#parts + 1] = v12
		end

		v5 = v6
		v6 = v10
	end

	local v10

	if v7 then
		v10 = spline.create(list[count - 2], list[count - 1], list[count], list[count - 1]:Lerp(list[count], 2))
	else
		v10 = spline.create(list[count - 2], list[count - 1], list[count], list[1])
	end

	local length = v9 + v10.length
	parts[#parts + 1] = v10
	local total = 0
	local v12 = {}

	for i = 1, #parts do
		total += parts[i].length
		v12[i] = total / length
	end

	local count2 = #v12

	local function GetPointOnPath(p)
		local v13 = nil
		local v14 = nil

		for i = 1, count2 do
			if not (p < v12[i] or i == count2) then
				continue
			end

			v13 = (p - (v12[i - 1] or 0)) / parts[i].length * length
			v14 = parts[i]
			break
		end

		return v14:Solve(v13)
	end

	return (setmetatable({
		parts = parts,
		length = length,
		GetPointOnPath = GetPointOnPath
	}, {
		__index = path
	}))
end

return {
	Spline = spline,
	Path = path
}