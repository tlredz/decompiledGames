local Players = game:GetService("Players")
local v = {
	"",
	"K",
	"M",
	"B",
	"T",
	"Qd",
	"Qn",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"De",
	"βA",
	"βB",
	"βC",
	"βD",
	"βE",
	"βF",
	"βG",
	"βH",
	"βI",
	"βJ",
	"βK",
	"βL",
	"βM",
	"βN",
	"βO",
	"βP",
	"βQ",
	"βR",
	"βS",
	"βT",
	"βU",
	"βV",
	"βW",
	"βX",
	"βY",
	"βZ",
	"αA",
	"αB",
	"αC",
	"αD",
	"αE",
	"αF",
	"αG",
	"αH",
	"αI",
	"αJ",
	"αK",
	"αL",
	"αM",
	"αN",
	"αO",
	"αP",
	"αQ",
	"αR",
	"αS",
	"αT",
	"αU",
	"αV",
	"αW",
	"αX",
	"αY",
	"αZ",
	"εA",
	"εB",
	"εC",
	"εD",
	"εE",
	"εF",
	"εG",
	"εH",
	"εI",
	"εJ",
	"εK",
	"εL",
	"εM",
	"εN",
	"εO",
	"εP",
	"εQ",
	"εR",
	"εS",
	"εT",
	"εU",
	"εV",
	"εW",
	"εX",
	"εY",
	"εZ"
}
local Utils = {
	Format = function(self, value: number)
		if typeof(value) ~= "number" then
			return value
		end

		local v2 = tostring(value)

		if value ~= 1e999 and value >= 10000 then
			for i = 1, #v do
				if value < 10 ^ (i * 3) then
					return math.floor(value / (10 ^ ((i - 1) * 3) / 100)) / 100 .. v[i]
				end
			end
		end

		return v2
	end,
	FormatTime = function(_, value: number)
		local v2 = typeof(value) == "number" and value or tonumber(value)

		if not v2 then
			return (tostring(v2))
		end

		local v3 = math.abs(v2)
		local v4 = math.floor(v3 % 86400 / 3600)
		local v5 = math.floor(v3 % 3600 / 60)
		local v6 = v3 % 60

		if v3 < 60 then
			return ("%ds"):format(v6)
		end

		if v3 < 3600 then
			if v6 == 0 then
				return ("%dm"):format(v5)
			end

			return ("%dm %ds"):format(v5, v6)
		elseif v3 < 86400 then
			local v7 = {}

			if v4 > 0 then
				table.insert(v7, ("%dh"):format(v4))
			end

			if v5 > 0 then
				table.insert(v7, ("%dm"):format(v5))
			end

			if v6 > 0 then
				table.insert(v7, ("%ds"):format(v6))
			end

			return table.concat(v7, " ")
		else
			local v7 = math.round(v3 / 86400)

			if v7 >= 365 then
				return "1y+"
			end

			local v8 = math.floor(v7 / 30)
			local v9 = v7 % 30
			local v10 = math.floor(v9 / 7)
			local v11 = v9 % 7
			local v12 = {}

			if v8 > 0 then
				table.insert(v12, ("%dmo"):format(v8))
			end

			if v10 > 0 then
				table.insert(v12, ("%dw"):format(v10))
			end

			if v11 > 0 then
				table.insert(v12, ("%dd"):format(v11))
			end

			return table.concat(v12, " ")
		end
	end,
	Unformat = function(_, value: string)
		if tonumber(value) then
			return (tonumber(value))
		end

		if typeof(value) ~= "string" then
			return value
		end

		local v2 = ""
		local v3 = ""

		for i = 1, #value do
			local v4 = string.sub(value, i, i)

			if tonumber(v4) or v4 == "." then
				v2 ..= v4
			else
				v3 ..= v4
			end
		end

		if #v3 == 0 or not table.find(v, v3) then
			return 0
		end

		local v4 = 1

		for _ = 1, ((table.find(v, v3) or 0) - 1) * 3 do
			v4 ..= 0
		end

		return tonumber(v2) * v4
	end
}

function Utils:DeepCopy(items, options)
	local v2 = options or {}

	if v2[items] then
		return v2[items]
	end

	local result = {}
	v2[items] = result

	for k, item in pairs(items) do
		if type(item) == "table" then
			result[k] = Utils:DeepCopy(item, v2)
		else
			result[k] = item
		end
	end

	local metatable = getmetatable(items)

	if metatable then
		setmetatable(result, metatable)
	end

	return result
end

function Utils.GetOptionsForType(_, p, p2: string)
	if p2 ~= "player" then
		return p.Types[p2]
	end

	local players = Players:GetPlayers()

	if not players then
		return
	end

	local names = {}

	for _, player in players do
		table.insert(names, player.Name)
	end

	return names
end

function Utils.ResolveType(_, data, p)
	if typeof(data) ~= "table" then
		return data
	end

	local v2 = p and p[data.Index]
	local v3

	if v2 == nil then
		v3 = "nil"
	elseif v2 == true then
		v3 = "true"
	elseif v2 == false then
		v3 = "false"
	else
		v3 = v2
	end

	local value = data.Values[v3]

	if value == nil then
		return data.Fallback
	end

	return value
end

function Utils.GetPropertiesForType(_, p, p2)
	return p2.Properties or p2.Kind and p.Kinds[p2.Kind]
end

function Utils:GetDescriptionOfParameter(value)
	local v2 = ""

	if typeof(value) == "table" then
		return "{ " .. Utils:GetDescriptionOfArray(value) .. " }"
	end

	if typeof(value) == "Instance" then
		return value.Name
	end

	local v3 = tostring(value)

	if not v3 then
		return v2
	end

	local v4 = tonumber(v3)

	if v4 then
		return (Utils:Format(v4))
	end

	return v3
end

function Utils:GetDescriptionOfArray(list)
	local v2 = #list
	local v3 = ""
	local descriptionOfParameters = {}

	for k, v4 in list do
		local descriptionOfParameter = Utils:GetDescriptionOfParameter(v4)

		if k == #list then
			v3 ..= descriptionOfParameter
		elseif k + 1 == v2 then
			v3 ..= descriptionOfParameter .. " and "
		else
			v3 ..= descriptionOfParameter .. ", "
		end

		table.insert(descriptionOfParameters, descriptionOfParameter)
	end

	return v3, descriptionOfParameters
end

function Utils.CheckIfAllowed(_, p, p2)
	local v2 = true

	if not p.Allower then
		return true
	end

	for _, v3 in p.Allower do
		local v4 = p2[v3.Index]
		local v5

		if v4 == nil then
			v5 = "nil"
		elseif v4 == true then
			v5 = "true"
		elseif v4 == false then
			v5 = "false"
		else
			v5 = v4
		end

		if not table.find(v3.List, v5) then
			return false
		end
	end

	return v2
end

return Utils