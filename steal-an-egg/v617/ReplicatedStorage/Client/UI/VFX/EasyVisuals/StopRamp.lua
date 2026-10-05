local v = {}

local function mixColour(color: Color3, color2: Color3, p: number)
	return Color3.new(
		color.R + (color2.R - color.R) * p,
		color.G + (color2.G - color.G) * p,
		color.B + (color2.B - color.B) * p
	)
end

local function mixAlpha(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function earlierStop(p, p2)
	return p.Time < p2.Time
end

v.Colour = {
	Blend = mixColour,
	Stop = function(p: number, p2)
		return ColorSequenceKeypoint.new(p, p2)
	end,
	Wrap = function(p: number, p2: number)
		return (p + p2) % 1
	end
}
v.Alpha = {
	Blend = mixAlpha,
	Stop = function(p: number, p2)
		return NumberSequenceKeypoint.new(p, p2)
	end,
	Wrap = function(p: number, p2: number)
		local v3 = p + p2

		if v3 < 0 or v3 > 1 then
			return v3 % 1
		end

		return v3
	end
}

function v.Sample(items, p: number, p2)
	local v3 = p + 1
	local v4 = {}

	for i = 0, 2 do
		for _, item in items do
			v4[#v4 + 1] = {
				Time = item.Time + i,
				Value = item.Value
			}
		end
	end

	for k, v5 in v4 do
		local v6 = v4[k + 1]

		if not v6 then
			break
		end

		if not (v5.Time <= v3 and v3 < v6.Time) then
			continue
		end

		local v7 = (v3 - v5.Time) / (v6.Time - v5.Time)
		return p2.Blend(v5.Value, v6.Value, v7)
	end

	return nil
end

function v.Drift(items, p, p2: number, p3: number, time: number)
	local v3 = {}

	for _, item in items do
		local v4 = p.Stop(p.Wrap(item.Time, p2), item.Value)

		if v4.Time <= time then
			p3 -= 1
			v3[p3] = v4
			time = v4.Time
		else
			v3[#v3 + 1] = v4
		end
	end

	local result = {}

	for _, v4 in v3 do
		result[#result + 1] = v4
	end

	table.sort(result, earlierStop)

	if result[1].Time ~= 0 then
		table.insert(result, 1, p.Stop(0, v.Sample(result, 0, p)))
	end

	if result[#result].Time ~= 1 then
		result[#result + 1] = p.Stop(1, v.Sample(result, 1, p))
	end

	return result
end

function v.Restripe(list, list2, p: number, p2)
	local v3 = #list == #list2
	local result = {}

	for _, v4 in list do
		local sample = v.Sample(list2, v4.Time, p2)

		if v3 then
			sample = sample:Lerp(v4.Value, p)
		end

		result[#result + 1] = p2.Stop(v4.Time, sample)
	end

	return result
end

return table.freeze(v)