local MaskFitCore = {
	SIZE_TOLERANCE = 0.15,
	OFFSET_TOLERANCE = 0.35
}
local v = {
	"centreOffset",
	"lateralOffset",
	"coverage",
	"standoffBias"
}

function MaskFitCore.skinKey(value)
	if type(value) == "string" and value ~= "" and value ~= "Default" then
		return value
	end

	return nil
end

function MaskFitCore.resolveRow(p, p2, p3)
	local v2

	if type(p) == "table" and p2 then
		v2 = p[p2] or nil
	end

	if type(v2) ~= "table" then
		return nil, false
	end

	local result = {}

	for _, v3 in ipairs(v) do
		result[v3] = v2[v3]
	end

	local skinKey = MaskFitCore.skinKey(p3)
	local v3

	if skinKey and type(v2.skins) == "table" then
		v3 = v2.skins[skinKey] or nil
	end

	if type(v3) ~= "table" then
		return result, false
	end

	for _, v4 in ipairs(v) do
		if v3[v4] ~= nil then
			result[v4] = v3[v4]
		end
	end

	return result, true
end

local function narrow(p)
	return (math.min(p.x, p.y))
end

function MaskFitCore.anchorOf(data, p)
	return {
		x = data.lateralOffset,
		y = data.centreOffset,
		z = -(p.z / 2 + data.standoffBias)
	}
end

function MaskFitCore.maskWidth(p, p2)
	return math.min(p2.x, p2.y) * p.coverage
end

function MaskFitCore.transferRow(data, data2, p)
	return {
		lateralOffset = data.x,
		centreOffset = data.y,
		standoffBias = -data.z - data2.z / 2,
		coverage = p / math.max(math.min(data2.x, data2.y), 0.01)
	}
end

function MaskFitCore.isHeadBoneName(value)
	for k in value:lower():gmatch("%a+") do
		if k == "head" or k == "headbone" then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hangsOffHead(p)
	for _, ancestor in ipairs(p.ancestors) do
		if MaskFitCore.isHeadBoneName(ancestor) then
			return true
		end
	end

	return false
end

function MaskFitCore.pickHeadBone(list)
	local v2 = nil
	local v3 = nil
	local v4 = nil

	for _, v5 in ipairs(list) do
		if not v2 and v5.name:lower() == "head" then
			v2 = v5
		end

		if MaskFitCore.isHeadBoneName(v5.name) then
			local v6 = hangsOffHead(v5) -- equivalent call inferred; original call site unknown

			if not v6 and (not v4 or v5.dist < v4.dist) then
				v4 = v5
			end
		end

		if v5.chainRoot and (not v3 or v5.dist < v3.dist) then
			v3 = v5
		end
	end

	return v2 or v4 or v3
end

function MaskFitCore.compare(p, p2, p3)
	local size = p.size
	local v2 = math.max(math.min(size.x, size.y), 0.01)
	local size2 = p2.size
	local sizeDelta = (math.min(size2.x, size2.y) - v2) / v2
	local up = p2.offset.y - p.offset.y
	local lateral = p2.offset.x - p.offset.x
	local forward = p.offset.z - p.size.z / 2 - (p2.offset.z - p2.size.z / 2)
	return {
		verdict = (math.abs(sizeDelta) > MaskFitCore.SIZE_TOLERANCE or math.abs(up) > MaskFitCore.OFFSET_TOLERANCE or math.abs(lateral) > MaskFitCore.OFFSET_TOLERANCE or math.abs(forward) > MaskFitCore.OFFSET_TOLERANCE) and (p3 and "tuned" or "flag") or "ok",
		sizeDelta = sizeDelta,
		up = up,
		lateral = lateral,
		forward = forward
	}
end

function MaskFitCore.describe(data)
	if data.verdict == "ok" then
		return "ok"
	end

	local v2 = {}

	if math.abs(data.sizeDelta) > MaskFitCore.SIZE_TOLERANCE then
		table.insert(v2, string.format("%+d%% size", (math.floor(data.sizeDelta * 100 + 0.5))))
	end

	if math.abs(data.up) > MaskFitCore.OFFSET_TOLERANCE then
		table.insert(v2, string.format("%.2f %s", math.abs(data.up), data.up > 0 and "high" or "low"))
	end

	if math.abs(data.lateral) > MaskFitCore.OFFSET_TOLERANCE then
		table.insert(v2, string.format("%.2f %s", math.abs(data.lateral), data.lateral > 0 and "right" or "left"))
	end

	if math.abs(data.forward) > MaskFitCore.OFFSET_TOLERANCE then
		table.insert(v2, string.format("%.2f %s", math.abs(data.forward), data.forward > 0 and "off face" or "sunk"))
	end

	return data.verdict .. " " .. table.concat(v2, ", ")
end

return MaskFitCore