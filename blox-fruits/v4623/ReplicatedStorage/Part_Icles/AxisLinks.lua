local v = {
	{ "SizeX", "SizeY", "SizeZ" },
	{ "RotSpeedX", "RotSpeedY", "RotSpeedZ" },
	{ "PosOffsetX", "PosOffsetY", "PosOffsetZ" },
	{ "RotX", "RotY", "RotZ" },
	{ "PosX", "PosY", "PosZ" }
}
local v2 = {}
local AxisLinks = {}
local v3 = {
	"SizeX",
	"SizeY",
	"SizeZ",
	"RotSpeedX",
	"RotSpeedY",
	"RotSpeedZ",
	"PosOffsetX",
	"PosOffsetY",
	"PosOffsetZ"
}

for _, list in ipairs(v) do
	local v4 = {}

	for _, v5 in ipairs(list) do
		v4[v5] = true
	end

	for _, v5 in ipairs(list) do
		v2[v5] = v4
	end
end

local function resolveAxisLink(p, p2)
	local v4

	if p then
		v4 = p[p2] or nil
	end

	if not v4 or v4 == "" or v4 == p2 then
		return nil
	end

	local v5 = v2[p2]

	if not (v5 and v5[v4]) then
		return nil
	end

	local v6 = p[v4]

	if v6 and v6 ~= "" and v6 ~= v4 and v5[v6] then
		return nil
	end

	return v4
end

function AxisLinks.sanitize(p)
	local result = {}

	for _, list in ipairs(v) do
		for _, v4 in ipairs(list) do
			local v5

			if p then
				v5 = p[v4] or nil
			end

			if v5 and v5 ~= "" and v5 ~= v4 then
				local v6 = v2[v4]

				if v6 and v6[v5] then
					local v7 = p[v5]

					if v7 and v7 ~= "" and v7 ~= v5 and v6[v7] then
						v5 = nil
					end
				else
					v5 = nil
				end
			else
				v5 = nil
			end

			result[v4] = v5
		end
	end

	return result
end

function AxisLinks:applyGraphAxisAliases(p2, p3)
	if not (p3 and self and p2) then
		return
	end

	for _, v4 in ipairs(v3) do
		local v5 = p3[v4]

		if not (v5 and v5 ~= v4 and self[v5] and p2[v5]) then
			continue
		end

		self[v4] = self[v5]
		p2[v4] = p2[v5]
	end
end

function AxisLinks.sampleRangeAxes(p, p2, list, p3, data)
	local emitIndex = data and data.EmitIndex
	local emitCount = data and data.EmitCount
	local v4 = (list[1] or ""):sub(1, 3)
	local evenOffsetIdx_Pos = nil
	local evenOffsetN_Pos = nil

	if v4 == "Pos" then
		evenOffsetIdx_Pos = data and data.EvenOffsetIdx_Pos
		evenOffsetN_Pos = data and data.EvenOffsetN_Pos
	elseif v4 == "Rot" then
		evenOffsetIdx_Pos = data and data.EvenOffsetIdx_Rot
		evenOffsetN_Pos = data and data.EvenOffsetN_Rot
	end

	local v5 = emitIndex and emitCount and emitCount > 0
	local result = {}

	for _, v6 in ipairs(list) do
		if p2 and p2[v6] then
			continue
		end

		if p[v6 .. "Even"] == true and v5 then
			local v7 = p[v6]
			local v8 = not (evenOffsetN_Pos and evenOffsetN_Pos > 0) and 0 or (evenOffsetIdx_Pos - 1) / (evenOffsetN_Pos * emitCount) or 0
			local v9

			if evenOffsetN_Pos == nil then
				v9 = false
			else
				v9 = evenOffsetN_Pos > 0
			end

			local v10

			if emitCount == 1 and v8 == 0 and not v9 then
				v10 = 0.5
			else
				v10 = emitIndex / emitCount + v8

				if v10 > 1 then
					v10 -= 1
				end
			end

			result[v6] = v7.Min + (v7.Max - v7.Min) * v10
		else
			result[v6] = p3.RandomValueFromRange(p[v6])
		end
	end

	for _, v6 in ipairs(list) do
		if result[v6] ~= nil then
			continue
		end

		local v7 = p2 and p2[v6]
		result[v6] = v7 and result[v7] or p3.RandomValueFromRange(p[v6])
	end

	return result
end

function AxisLinks.refreshLoopGraphsAndSeeds(p, p2, p3)
	if not p.Graphs then
		return
	end

	for k, _ in pairs(p.Graphs) do
		if p2[k] ~= nil then
			p.Graphs[k] = p2[k]
		end
	end

	if p.Seeds then
		for k, _ in pairs(p.Seeds) do
			if p.Graphs[k] then
				p.Seeds[k] = p3.GenerateSeed(p.Graphs[k])
			end
		end
	end

	AxisLinks.applyGraphAxisAliases(p.Graphs, p.Seeds, p2.AxisLinks)
end

return AxisLinks