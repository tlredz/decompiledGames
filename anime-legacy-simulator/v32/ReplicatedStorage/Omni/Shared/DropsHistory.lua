local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maps = require(ReplicatedStorage.Omni.Shared.Maps)
local Gamemodes = require(ReplicatedStorage.Omni.Shared.Gamemodes)
local v = {
	AllCategory = "All",
	UnknownSource = "Unknown",
	KeySeparator = "|"
}

function v.GetSource(value: string?, value2: string?, value3: string?)
	if typeof(value) == "string" then
		local v2 = Gamemodes.List[value]

		if v2 and typeof(v2.Difficulty) ~= "string" and typeof(value2) == "string" then
			return (`{value} ({value2})`)
		end

		return value
	elseif typeof(value3) == "string" then
		return value3
	else
		return v.UnknownSource
	end
end

function v.GetKey(p: string, p2: string, flag: boolean?)
	if flag == true then
		return (`{p}{v.KeySeparator}{p2}{v.KeySeparator}Shiny`)
	end

	return (`{p}{v.KeySeparator}{p2}`)
end

function v.ParseKey(value: string)
	local v2 = string.split(value, v.KeySeparator)
	return v2[1], v2[2], v2[3] == "Shiny"
end

function v.GetSourceOrder(value: string)
	if value == v.AllCategory then
		return -1
	end

	local v2 = Maps.List[value]

	if v2 then
		return (v2.Index or 0) * 1000
	end

	for k, v3 in Gamemodes.List do
		if not (value == k or string.sub(value, 1, #k + 2) == `{k} (`) then
			continue
		end

		local v4 = Maps.List[v3.MapName]
		local index = v4 and v4.Index or 0
		local v5 = string.match(value, "%((.-)%)$")
		local index2 = v5 and table.find(Gamemodes.DifficultyOrder, v5) or 0
		return index * 1000 + 100 + index2
	end

	return 1e999
end

function v.FormatDuration(p: number)
	local v2 = math.max(0, (math.floor(p)))
	return (`{v2 // 86400}d {v2 % 86400 // 3600}h {v2 % 3600 // 60}m`)
end

return table.freeze(v)