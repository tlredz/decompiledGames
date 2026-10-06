local Multipliers = require(script.Parent.Multipliers)
local v = {
	["Ultimate Damage"] = "Damage",
	["Boss Damage"] = "Damage",
	["Movement Speed"] = "Drops",
	["Critical Damage"] = "Critical Chance",
	["Exp Gain"] = "Player Exp",
	["Max Level"] = "Player Exp",
	["Ultimate Hits"] = "Attack Distance"
}
local v2 = {
	{
		Key = "Attributes",
		Label = "Fighter"
	},
	{
		Key = "Perks",
		Label = "Global"
	}
}
local v3 = {}

local function Colorize(value: string, p: string)
	local color = Multipliers.GetColorFromMultiplier(v[p] or p)
	return (`<font color="#{string.format("%02X%02X%02X", math.round(color.R * 255), math.round(color.G * 255), (math.round(color.B * 255)))}">{value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub("'", "&apos;")}</font>`)
end

function v3.GetRows(p, flag: boolean?)
	local result = {}

	if not p then
		return result
	end

	for _, v4 in v2 do
		local v5 = {}

		for k in p[v4.Key] or {} do
			table.insert(v5, k)
		end

		table.sort(v5)

		for _, name in v5 do
			local v7 = p[v4.Key][name]
			local v8

			if name == "Fighter Size" and v7.Type == "Multi" then
				v8 = `{v7.Amount}x {"Fighter Size"}`
			elseif v4.Key == "Attributes" and v7.Type == "Add" then
				local v9 = name == "Critical Chance" and "%" or ""
				v8 = `{v7.Amount >= 0 and "+" or ""}{v7.Amount}{v9} {name}`
			elseif v7.Type == "Multi" then
				local v9 = math.round((v7.Amount - 1) * 100)
				v8 = `{v9 >= 0 and "+" or ""}{v9}% {name}`
			else
				v8 = Multipliers.ToStringSingle({
					Name = name,
					IsRich = false,
					ShowPercentage = true,
					MultiplierArray = { v7 }
				})
			end

			if flag then
				v8 = Colorize(v8, name)
			end

			table.insert(result, {
				Key = `{v4.Key}/{name}`,
				Text = `{v4.Label}: {v8}`
			})
		end
	end

	return result
end

function v3.ToString(p, flag: boolean?)
	local v4 = {
		Fighter = {},
		Global = {}
	}

	for _, v5 in v3.GetRows(p, flag) do
		local v6, v7 = string.match(v5.Text, "^(%w+): (.+)$")

		if v6 and v7 then
			table.insert(v4[v6], v7)
		end
	end

	local v5 = {}

	for _, v6 in { "Fighter", "Global" } do
		if #v4[v6] > 0 then
			table.insert(v5, (`{v6}: {table.concat(v4[v6], ", ")}`))
		end
	end

	return table.concat(v5, " | ")
end

return table.freeze(v3)