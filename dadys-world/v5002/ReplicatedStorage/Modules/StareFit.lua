local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StareFit = {
	LIVE_FOLDER = "StareFitLive",
	FIELDS = {
		lift = {
			default = 0.16,
			step = 0.05,
			min = -1,
			max = 1
		},
		shift = {
			default = 0,
			step = 0.05,
			min = -1,
			max = 1
		},
		zoom = {
			default = 1,
			step = 0.1,
			min = 0.3,
			max = 3
		},
		yaw = {
			default = 0,
			step = 5,
			min = -80,
			max = 80
		},
		edge = {
			default = 0,
			step = 0.1,
			min = -1,
			max = 1
		},
		reach = {
			default = 0,
			step = 0.1,
			min = 0,
			max = 2
		},
		hand = {
			default = 0,
			step = 0.25,
			min = 0,
			max = 1
		}
	},
	FIELD_ORDER = {
		"lift",
		"shift",
		"zoom",
		"yaw",
		"edge",
		"reach",
		"hand"
	},
	describe = function(data)
		return string.format(
			"lift %+.2f  shift %+.2f  zoom %.2f  yaw %+d  edge %+.1f  reach %.1f  hand %d%%",
			data.lift,
			data.shift,
			data.zoom,
			math.round(data.yaw),
			data.edge,
			data.reach,
			(math.round(data.hand * 100))
		)
	end
}

local function authoredRows()
	local sharedData = ReplicatedStorage:FindFirstChild("SharedData")
	local stareFitData = sharedData and sharedData:FindFirstChild("StareFitData")

	if not stareFitData then
		return {}
	end

	local success, result = pcall(require, stareFitData)
	return (not success or type(result) ~= "table" or not result) and {} or result
end

function StareFit.liveFolder()
	return ReplicatedStorage:FindFirstChild(StareFit.LIVE_FOLDER)
end

local function liveRow(childName)
	local liveFolder = StareFit.liveFolder()
	local child = liveFolder and liveFolder:FindFirstChild(childName)

	if not child then
		return nil
	end

	local attributesByAttributeName = {}

	for _, attributeName in ipairs(StareFit.FIELD_ORDER) do
		attributesByAttributeName[attributeName] = tonumber(child:GetAttribute(attributeName))
	end

	local enabled = child:GetAttribute("enabled")

	if type(enabled) == "boolean" then
		attributesByAttributeName.enabled = enabled
	end

	return attributesByAttributeName
end

function StareFit.resolve(childName)
	local result = {
		enabled = true,
		live = false
	}

	for k, v in pairs(StareFit.FIELDS) do
		result[k] = v.default
	end

	local v

	if type(childName) == "string" then
		v = authoredRows()[childName] or nil
	end

	if type(v) == "table" then
		for k, v2 in pairs(StareFit.FIELDS) do
			if type(v[k]) == "number" then
				result[k] = math.clamp(v[k], v2.min, v2.max)
			end
		end

		if v.enabled == false then
			result.enabled = false
		end
	end

	local v2

	if type(childName) == "string" then
		v2 = liveRow(childName) or nil
	end

	if not v2 then
		return result
	end

	for k, v3 in pairs(StareFit.FIELDS) do
		if not v2[k] then
			continue
		end

		result[k] = math.clamp(v2[k], v3.min, v3.max)
		result.live = true
	end

	if v2.enabled ~= nil then
		result.enabled = v2.enabled
		result.live = true
	end

	local liveFolder = StareFit.liveFolder()
	local child = liveFolder and liveFolder:FindFirstChild(childName)
	result.savedAt = child and tonumber(child:GetAttribute("SavedAt")) or nil
	return result
end

function StareFit.isEnabled(p)
	return StareFit.resolve(p).enabled
end

function StareFit.liveToons()
	local names = {}
	local liveFolder = StareFit.liveFolder()

	if liveFolder then
		for _, child in ipairs(liveFolder:GetChildren()) do
			table.insert(names, child.Name)
		end
	end

	table.sort(names)
	return names
end

function StareFit.pasteBlock()
	local liveToons = StareFit.liveToons()

	if #liveToons == 0 then
		return "-- nothing tuned live yet"
	end

	local v = { "-- paste into Shared/ReplicatedStorage/SharedData/StareFitData.lua" }

	for _, liveToon in ipairs(liveToons) do
		local resolved = StareFit.resolve(liveToon)
		local v2 = {}

		for _, v3 in ipairs(StareFit.FIELD_ORDER) do
			if math.abs(resolved[v3] - StareFit.FIELDS[v3].default) > 1e-6 then
				table.insert(v2, string.format("%s = %.2f", v3, resolved[v3]))
			end
		end

		if not resolved.enabled then
			table.insert(v2, "enabled = false")
		end

		if #v2 > 0 then
			table.insert(v, string.format("\t%s = { %s },", liveToon, table.concat(v2, ", ")))
		end
	end

	if #v == 1 then
		return "-- every live row is back on its defaults"
	end

	return table.concat(v, "\n")
end

return StareFit