local ValueConvertor = {}
local Players = game:GetService("Players")

local function giveAllOfObject()
	return true
end

local v = {
	others = function(p, p2)
		return p ~= p2
	end,
	me = function(p, p2)
		return p == p2
	end,
	all = giveAllOfObject,
	everything = giveAllOfObject,
	allItems = giveAllOfObject
}

function ValueConvertor:FormatDigit(p: number, p2: number)
	local v2 = tostring(p)
	local v3 = p2 - v2:len()

	if v3 > 0 then
		return string.rep("0", v3) .. v2
	end

	return v2
end

local function DictionaryToArray(items)
	local result = {}

	for k, _ in pairs(items) do
		result[#result + 1] = k
	end

	return result
end

function ValueConvertor:GetPlayerName(p)
	return (`{p.DisplayName}{p.DisplayName == p.Name and "" or ` (@{p.Name})` or ""}`)
end

function ValueConvertor:PlayerArrayToString(items, value)
	local playerNames = {}

	for _, item in pairs(items) do
		playerNames[#playerNames + 1] = self:GetPlayerName(item)
	end

	return table.concat(playerNames, value or ", ")
end

function ValueConvertor.GetPlayersDisplayNameFromText(_, p, value: string)
	local players = Players:GetPlayers()
	local v2 = {}
	local v3 = v[value]

	if v3 then
		for _, player in pairs(players) do
			if v3(player, p) then
				v2[player] = true
			end
		end
	else
		for _, player in pairs(players) do
			if player.DisplayName:lower() == value then
				v2[player] = true
			end
		end

		for _, player in pairs(players) do
			if player.DisplayName:lower():sub(1, value:len()) ~= value then
				continue
			end

			v2[player] = true
		end
	end

	local result

	if next(v2) then
		result = {}

		for k, _ in pairs(v2) do
			result[#result + 1] = k
		end

		if not result then
			result = v2
		end
	else
		result = v2
	end

	return result
end

function ValueConvertor:GetPlayersFromText(p, childName: string)
	local players = Players:GetPlayers()
	local v2 = {}
	local v3 = v[childName]

	if v3 then
		for _, player in pairs(players) do
			if v3(player, p) then
				v2[player] = true
			end
		end
	else
		local child = Players:FindFirstChild(childName)

		if child then
			v2[child] = true
		else
			for _, player in pairs(players) do
				if player.Name:lower() == childName then
					v2[player] = true
				end
			end

			for _, player in pairs(players) do
				if player.Name:lower():sub(1, childName:len()) ~= childName then
					continue
				end

				v2[player] = true
			end
		end
	end

	local result

	if next(v2) then
		result = {}

		for k, _ in pairs(v2) do
			result[#result + 1] = k
		end

		if not result then
			result = v2
		end
	else
		result = v2
	end

	return result
end

function ValueConvertor:GetPlayersFromTuple(p, ...)
	local v2 = {}

	if ... == nil or ... == "" then
		v2[p] = true
	else
		for _, v3 in pairs({ ... }) do
			for _, v4 in pairs(self:GetPlayersFromText(p, v3)) do
				v2[v4] = true
			end
		end
	end

	local result

	if next(v2) then
		result = {}

		for k, _ in pairs(v2) do
			result[#result + 1] = k
		end

		if not result then
			result = v2
		end
	else
		result = v2
	end

	return result
end

function ValueConvertor.FormatOrdinal(_, p)
	local v2 = tostring(p)
	local v3 = not (v2:len() > 1) and "" or v2:sub(-2):sub(1, 1) or ""
	local v4 = v2:sub(-1)
	local v5

	if v3 == "1" then
		v5 = "th"
	elseif v4 == "1" then
		v5 = "st"
	elseif v4 == "2" then
		v5 = "nd"
	elseif v4 == "3" then
		v5 = "rd"
	else
		v5 = "th"
	end

	return tostring(p) .. v5
end

function ValueConvertor.AddCommas(_, p: number)
	if p == 1e999 then
		return "∞"
	end

	local v2 = p % 1
	local v3 = p - v2
	local v4 = math.ceil(v2 * 100 - 0.5) / 100
	local v5 = tostring(v3)

	for i = 1, (#v5 - 1) / 3 do
		local v6 = -(i * 3 + (i - 1))
		v5 = v5:sub(1, v6 - 1) .. "," .. v5:sub(v6)
	end

	if v4 ~= 0 then
		local v6 = tostring(v4)
		return v5 .. "." .. v6:sub(3, v6:len())
	end

	return v5
end

function ValueConvertor.FormatTime(_, p: number)
	local v2 = math.ceil(p - 0.5)
	local v3 = math.floor(v2 / 3600)
	local v4 = math.floor(v2 % 3600 / 60)
	local v5 = v2 % 60

	if v3 > 0 then
		return v3 .. "h " .. ValueConvertor:FormatDigit(v4, 2) .. "m "
	end

	if v4 > 0 then
		return v4 .. "m " .. ValueConvertor:FormatDigit(v5, 2) .. "s"
	end

	return v5 .. "s"
end

function ValueConvertor.FormatTimeHHMMSS(_, p: number)
	local v2 = math.ceil(p - 0.5)
	local v3 = math.floor(v2 / 3600)
	local v4 = math.floor(v2 % 3600 / 60)
	local v5 = v2 % 60

	if v3 > 0 then
		return v3 .. "h " .. ValueConvertor:FormatDigit(v4, 2) .. "m " .. ValueConvertor:FormatDigit(v5, 2) .. "s"
	end

	if v4 > 0 then
		return v4 .. "m " .. ValueConvertor:FormatDigit(v5, 2) .. "s"
	end

	return v5 .. "s"
end

function ValueConvertor.FormatTimeWithDays(_, p: number)
	local v2 = math.ceil(p - 0.5)
	local v3 = math.floor(v2 / 86400)
	local v4 = math.floor(v2 % 86400 / 3600)
	local v5 = math.floor(v2 % 3600 / 60)
	local v6 = v2 % 60

	if v3 > 0 then
		return v3 .. "d " .. ValueConvertor:FormatDigit(v4, 2) .. "h"
	end

	if v4 > 0 then
		return v4 .. "h " .. ValueConvertor:FormatDigit(v5, 2) .. "m"
	end

	if v5 > 0 then
		return v5 .. "m " .. ValueConvertor:FormatDigit(v6, 2) .. "s"
	end

	return v6 .. "s"
end

function ValueConvertor.FormatTimeWithDaysFull(_, p: number, flag: boolean?)
	local v2 = math.ceil(p - 0.5)
	local v3 = math.floor(v2 / 86400)
	local v4 = math.floor(v2 % 86400 / 3600)
	local v5 = math.floor(v2 % 3600 / 60)
	local v6 = v2 % 60

	if v3 > 0 then
		return v3 .. "d " .. ValueConvertor:FormatDigit(v4, 2) .. "h " .. ValueConvertor:FormatDigit(v5, 2) .. "m" .. `{flag and "" or ` {ValueConvertor:FormatDigit(v6, 2)}s`}`
	end

	if v4 > 0 then
		return v4 .. "h " .. ValueConvertor:FormatDigit(v5, 2) .. "m" .. `{flag and "" or ` {ValueConvertor:FormatDigit(v6, 2)}s`}`
	end

	if v5 > 0 then
		return v5 .. "m" .. `{flag and "" or ` {ValueConvertor:FormatDigit(v6, 2)}s`}`
	end

	if flag then
		return ""
	end

	return (`{ValueConvertor:FormatDigit(v6, 2)}s`)
end

function ValueConvertor.FormatShortTime(_, p: number)
	local v2 = math.ceil(p - 0.5)
	local v3 = math.floor(v2 / 3600)
	local v4 = math.floor(v2 % 3600 / 60)
	local v5 = v2 % 60

	if v3 > 0 then
		return v3 .. "h"
	end

	if v4 > 0 then
		return v4 .. "m"
	end

	return v5 .. "s"
end

function ValueConvertor.FormatShortTimeFull(_, p: number)
	local v2 = math.floor(p / 60)
	local v3 = math.floor(v2 / 60)
	local v4 = math.floor(v3 / 24)

	if v4 > 0 then
		return v4 .. "d"
	end

	if v3 > 0 then
		return v3 .. "h"
	end

	if v2 > 0 then
		return v2 .. "m"
	end

	return math.floor(p) .. "s"
end

function ValueConvertor.FormatTimeWithMS(_, p: number)
	local v2 = math.floor(p / 60)
	local v3 = math.floor(v2 / 60)
	local v4 = math.floor(v3 / 24)

	if v4 > 0 then
		return v4 .. "d"
	end

	if v3 > 0 then
		return v3 .. "h"
	end

	if v2 > 0 then
		return v2 .. "m"
	end

	if p >= 1 then
		return math.floor(p) .. "s"
	end

	return string.format("%.1f", p) .. "s"
end

function ValueConvertor.AddNumberPadding(_, p, p2)
	local v2 = tostring(p)
	local v3 = p2 - v2:len()

	if v3 > 0 then
		return string.rep("0", v3) .. v2
	end

	return v2
end

local v2 = {
	"K",
	"M",
	"B",
	"T",
	"Qd",
	"Qnt",
	"Sxt",
	"Spt",
	"Oct",
	"Non",
	"Dec",
	"Und",
	"Dod",
	"Trd",
	"Qad",
	"Qud",
	"Sxd",
	"Spd",
	"Ocd",
	"Nvd",
	"Vig",
	"Uvg",
	"Dvg",
	"Tvg",
	"Qvv",
	"Qvg",
	"Sxv",
	"Spv",
	"Ocv",
	"Nvv",
	"Trg",
	"Utg",
	"Dtg"
}

function ValueConvertor.ShrinkNumber(_, p: number)
	if p == 1e999 then
		return "∞"
	end

	if not (p > 999) then
		return (tostring(math.ceil(p * 1000) / 1000))
	end

	local v3 = tostring((math.ceil(p)))
	local v4 = v3:len()
	local v5 = math.floor((v4 - 1) / 3)
	local v6 = v2[v5]
	local v7 = v3:sub(1, v4 - v5 * 3 + 1)
	local v8 = v7:sub(v7:len(), v7:len())
	local v9

	if v8 == "0" then
		v9 = v7:sub(1, v7:len() - 1)
	else
		v9 = v7:sub(1, v7:len() - 1) .. "." .. v8
	end

	return v9 .. v6
end

function ValueConvertor.GetColorFromPercentage(_, value: string, value2: number, color: Color3, color2: Color3)
	local v3 = value and string.gsub(value, "%D", "")
	local v4 = v3 and tonumber(v3)

	if not v4 then
		return
	end

	local v5 = color2 or Color3.new(0, 1, 0)
	local v6 = color or Color3.new(1, 0, 0)
	local v7 = math.clamp(v4 / (value2 or 1), 0, 1)
	local v8 = Vector3.new(v5.R, v5.G, v5.B) - Vector3.new(v6.R, v6.G, v6.B)
	return Color3.new(v6.R + v8.X * v7, v6.G + v8.Y * v7, v6.B + v8.Z * v7)
end

function ValueConvertor.AdjustColor(_, color: Color3, p: number)
	return Color3.new(color.R * p, color.G * p, color.B * p)
end

function ValueConvertor.GetPercentageTable(_, data)
	local _Total = data._Total
	local result = {}
	local total = 0

	for k, v3 in pairs(data.Content) do
		result[k] = v3 / _Total
		total += v3
	end

	result[data._Default] = (_Total - total) / _Total
	return result
end

function ValueConvertor:GetLootboxMaxChance(items)
	local total = 0

	for _, item in pairs(items) do
		total += item.Chance
	end

	return total
end

function ValueConvertor.PickFromLootbox(_, items)
	local lootboxMaxChance = ValueConvertor:GetLootboxMaxChance(items)
	local v3 = Random.new():NextNumber() * lootboxMaxChance
	local total = 0

	for k, item in pairs(items) do
		total += item.Chance

		if v3 <= total then
			return item, k
		end
	end
end

function ValueConvertor.GetPercentageFromNumbers(_, p, p2, p3)
	return (math.clamp((p - p2) / (p3 - p2), 0, 1))
end

function ValueConvertor.FormatMarkupColor(_, p: string, color: Color3)
	local v3 = string.format(
		"#%02X%02X%02X",
		math.clamp(color.R, 0, 1) * 255,
		math.clamp(color.G, 0, 1) * 255,
		math.clamp(color.B, 0, 1) * 255
	)
	return string.format("<font color=\"%s\">%s</font>", v3, p)
end

function ValueConvertor.GetNumberSequenceFromPercentage(_, value: number, value2: number)
	local v3 = math.clamp(value or 0, 0, 1)
	local v4 = value2 or 0.05
	local numberSequenceKeypoints = { NumberSequenceKeypoint.new(0, 1 - math.clamp(v3 / v4, 0, 1)) }
	local v5 = 1 - v4 <= v3
	local v6 = v3 < v4

	if not (v6 or v5) then
		numberSequenceKeypoints[#numberSequenceKeypoints + 1] = NumberSequenceKeypoint.new(v3 - v4, 0)
	end

	if v5 then
		local v7 = (v3 + v4) % 1
		numberSequenceKeypoints[#numberSequenceKeypoints + 1] = NumberSequenceKeypoint.new(v3 - v4, 0)

		if v3 == 1 then
			numberSequenceKeypoints[#numberSequenceKeypoints + 1] = NumberSequenceKeypoint.new(1, 0)
		else
			numberSequenceKeypoints[#numberSequenceKeypoints + 1] = NumberSequenceKeypoint.new(
				1,
				1 - math.clamp(v7 / v4, 0, 1)
			)
		end
	else
		if v6 then
		end

		numberSequenceKeypoints[#numberSequenceKeypoints + 1] = NumberSequenceKeypoint.new(v3 + v4, 1)
		numberSequenceKeypoints[#numberSequenceKeypoints + 1] = NumberSequenceKeypoint.new(1, 1)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function ValueConvertor.InvertNumberSequence(_, sequence)
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(sequence.Keypoints) do
		local v3 = 1 - keypoint.Time
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(v3, keypoint.Value)
	end

	table.sort(numberSequenceKeypoints, function(a, b)
		return a.Time < b.Time
	end)
	return NumberSequence.new(numberSequenceKeypoints)
end

function ValueConvertor.GetColorSequenceFromPercentage(_, value: number, value2: number, color: Color3, color2: Color3)
	local v3 = math.clamp(value or 0, 0, 1)
	local v4 = value2 or 0.05
	local colorSequenceKeypoints = { ColorSequenceKeypoint.new(0, color) }
	local v5 = 1 - v4 <= v3
	local v6 = v3 < v4

	if not (v6 or v5) then
		colorSequenceKeypoints[#colorSequenceKeypoints + 1] = ColorSequenceKeypoint.new(v3 - v4, color)
	end

	if v5 then
		local v7 = (v3 + v4) % 1
		colorSequenceKeypoints[#colorSequenceKeypoints + 1] = ColorSequenceKeypoint.new(v3 - v4, color)

		if v3 == 1 then
			colorSequenceKeypoints[#colorSequenceKeypoints + 1] = ColorSequenceKeypoint.new(1, color:Lerp(color2, 0))
		else
			colorSequenceKeypoints[#colorSequenceKeypoints + 1] = ColorSequenceKeypoint.new(
				1,
				color:Lerp(color2, 1 - math.clamp(v7 / v4, 0, 1))
			)
		end
	else
		if v6 then
		end

		colorSequenceKeypoints[#colorSequenceKeypoints + 1] = ColorSequenceKeypoint.new(v3 + v4, color2)
		colorSequenceKeypoints[#colorSequenceKeypoints + 1] = ColorSequenceKeypoint.new(1, color2)
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

function ValueConvertor.NormalizeRarity(_, p: string)
	if p == "Secret" then
		return 5
	elseif p == "Legendary" then
		return 4
	elseif p == "Epic" then
		return 3
	elseif p == "Rare" then
		return 2
	elseif p == "Common" then
		return 1
	end

	return 0
end

return ValueConvertor