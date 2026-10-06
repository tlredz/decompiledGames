local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {
	Accessories = true,
	Achievements = true,
	Commerce = true,
	Fighters = true,
	Gacha = true,
	Gamepasses = true,
	Guild = true,
	Index = true,
	IndexRewards = true,
	Level = true,
	Prestige = true,
	Profession = true,
	Progression = true,
	Quests = true,
	Upgrade = true,
	Weapons = true
}
local SystemsMap = require(script.SystemsMap)
require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local Table = require(ReplicatedStorage.Omni.Utils.Table)
local Number = require(ReplicatedStorage.Omni.Utils.Number)
local v2 = {}
local weatherState = ReplicatedStorage:GetAttribute("WeatherState")
local v3 = {
	MultiplierColors = {
		Power = Color3.new(1, 0, 0),
		Damage = Color3.new(1, 0, 0),
		["Player Damage"] = Color3.new(1, 0, 0),
		["Fighter Damage"] = Color3.new(1, 0, 0),
		Crystals = Color3.new(0.75, 0, 1),
		Luck = Color3.new(0, 1, 0),
		["Gacha Luck"] = Color3.new(0, 1, 0),
		["Attack Speed"] = Color3.new(1, 1, 0),
		["Attack Distance"] = Color3.new(1, 0.5, 0),
		["Star Speed"] = Color3.new(0, 1, 0.5),
		["Gacha Speed"] = Color3.new(0, 1, 0.5),
		["Critical Chance"] = Color3.new(1, 0.5, 0.5),
		["Critical Multiplier"] = Color3.new(1, 0.5, 0.5),
		["Critical Damage"] = Color3.new(1, 0.5, 0.5),
		["Player Exp"] = Color3.new(0.5, 1, 0),
		["Avatar Exp"] = Color3.new(0.5, 1, 0),
		["Exp Gain"] = Color3.new(0.5, 1, 0),
		["Max Level"] = Color3.new(0.5, 1, 0),
		["Movement Speed"] = Color3.new(1, 1, 1),
		Drops = Color3.new(0, 1, 1),
		["Shiny Chance"] = Color3.new(1, 1, 0)
	}
}

local function IsOnlyKeyChange(list, p: number, p2: string, p3, p4)
	if p < #list then
		return list[p + 1] == p2
	end

	if #list < p then
		return false
	end

	if typeof(p3) == "table" and typeof(p4) == "table" then
		return Table:IsEqual(p3, p4, p2)
	end

	return false
end

function v3.GetColorFromMultiplier(p: string)
	return v3.MultiplierColors[p] or Color3.new(1, 1, 1)
end

function v3.Invalidate(p)
	local v4 = p and v2[tostring(p.UserId)]

	if v4 then
		table.clear(v4)
	end
end

function v3.IsDataChangeRelevant(list, p, p2)
	if typeof(list) ~= "table" or list[1] == nil then
		return true
	end

	local v4 = list[1]

	if not v[v4] or p == p2 and p ~= nil and typeof(p) ~= "table" then
		return false
	end

	if v4 == "Level" then
		local v5

		if #list > 1 then
			v5 = list[2] == "Exp"
		elseif #list < 1 or typeof(p) ~= "table" or typeof(p2) ~= "table" then
			v5 = false
		else
			v5 = Table:IsEqual(p, p2, "Exp")
		end

		return not v5
	else
		if v4 == "Index" then
			return list[2] == nil or list[2] == "SacredArtefact"
		end

		if v4 == "Profession" then
			local v5

			if #list > 3 then
				v5 = list[4] == "Progress"
			elseif #list < 3 or typeof(p) ~= "table" or typeof(p2) ~= "table" then
				v5 = false
			else
				v5 = Table:IsEqual(p, p2, "Progress")
			end

			return not v5
		elseif v4 == "Quests" then
			if list[2] ~= "List" or list[4] ~= "List" then
				return true
			end

			local v5

			if #list > 5 then
				v5 = list[6] == "Missions"
			elseif #list < 5 or typeof(p) ~= "table" or typeof(p2) ~= "table" then
				v5 = false
			else
				v5 = Table:IsEqual(p, p2, "Missions")
			end

			return not v5
		else
			if list[2] ~= "List" then
				return true
			end

			local v5

			if #list > 3 then
				v5 = list[4] == "Exp"
			elseif #list < 3 or typeof(p) ~= "table" or typeof(p2) ~= "table" then
				v5 = false
			else
				v5 = Table:IsEqual(p, p2, "Exp")
			end

			return not v5
		end
	end
end

function v3.ToStringSingle(data)
	local compileArray, v4 = v3.CompileArray(data.MultiplierArray)
	local color = v3.GetColorFromMultiplier(data.Name)
	local v5 = v4 > 1 and "Multi" or "Add"
	local v6 = data.IsRich and "<b><font color='#" .. color:ToHex() .. "'>" or ""
	local v7 = data.IsRich and "</font></b>" or ""

	if v5 == "Multi" then
		local rounded = Number:Round((1 + compileArray) * v4)
		local formatted = Number:Format(rounded)

		if data.ShowPercentage then
			if data.RemoveName then
				return v6 .. "+" .. math.round(100 * (rounded - 1)) .. "%" .. v7
			end

			return "+" .. math.round(100 * (rounded - 1)) .. "% " .. v6 .. data.Name .. v7
		elseif data.RemoveName then
			return formatted .. "x" .. v7
		else
			return formatted .. "x " .. v6 .. data.Name .. v7
		end
	else
		local rounded = Number:Round(compileArray * v4)
		local formatted = Number:Format(rounded)

		if data.ShowPercentage then
			if data.RemoveName then
				return v6 .. "+" .. math.round(100 * rounded) .. "%" .. v7
			end

			return "+" .. math.round(100 * rounded) .. "% " .. v6 .. data.Name .. v7
		elseif data.RemoveName then
			return "+" .. formatted .. v7
		else
			return "+" .. formatted .. " " .. v6 .. data.Name .. v7
		end
	end
end

function v3.ToStringTable(data)
	local size = Table:Size(data.PerksArray)
	local index = data.ShowPercentageForMultipliers and table.find(data.ShowPercentageForMultipliers, "All")
	local v4 = 1
	local v5 = ""

	for k, multiplierArray in data.PerksArray do
		local showPercentage = index or data.ShowPercentageForMultipliers and table.find(
			data.ShowPercentageForMultipliers,
			k
		)
		local stringSingle = v3.ToStringSingle({
			Name = k,
			MultiplierArray = multiplierArray,
			IsRich = data.IsRich,
			ShowPercentage = showPercentage,
			RemoveName = data.RemoveName
		})

		if v4 == size then
			v5 ..= stringSingle
		elseif v4 + 1 == size then
			v5 ..= stringSingle .. " and "
		else
			v5 ..= stringSingle .. ", "
		end

		v4 += 1
	end

	return v5
end

function v3.ToStringEffects(items)
	local v4 = {}

	for _, v5 in {
		{
			Key = "Attributes",
			Label = "Weapon"
		},
		{
			Key = "Perks",
			Label = "Global"
		}
	} do
		local v6 = {}

		for _, item in items do
			for k, v7 in item[v5.Key] or {} do
				v6[k] = v6[k] or {}
				table.insert(v6[k], v7)
			end
		end

		local v7 = {}

		for k in v6 do
			table.insert(v7, k)
		end

		table.sort(v7)
		local v8 = {}

		for _, name in v7 do
			table.insert(v8, v3.ToStringSingle({
				Name = name,
				IsRich = true,
				ShowPercentage = name ~= "Max Level",
				MultiplierArray = v6[name]
			}))
		end

		if #v8 > 0 then
			table.insert(v4, (`{v5.Label}: {table.concat(v8, ", ")}`))
		end
	end

	return table.concat(v4, " | ")
end

function v3.CompileArray(items)
	local v4 = 1
	local total = 0

	for _, item in items do
		if typeof(item) == "table" then
			if typeof(item.Amount) == "number" then
				if item.Type == "Add" then
					total += item.Amount
				else
					v4 *= item.Amount
				end
			else
				print("[MULTIPLIERS] Multiplier Amount missing:", item, debug.traceback())
			end
		else
			print(`[MULTIPLIERS] Invalid multiplier array with type '{typeof(item)}':`, item, debug.traceback())
		end
	end

	return total, v4
end

function v3.GetMultiplierAmountFromSystem(p: string, p2: string, p3, p4)
	local result = {}
	local weatherState2 = ReplicatedStorage:GetAttribute("WeatherState")

	if weatherState2 ~= weatherState then
		weatherState = weatherState2

		for _, list in v2 do
			table.clear(list)
		end
	end

	local now = os.clock()
	local v4 = p .. p2
	local v5

	if p4 then
		v5 = v2[tostring(p4.UserId)]
	end

	local v6 = v5 and v5[v4]

	if v6 then
		if now - v6.Time >= 1 then
			v5[v4] = nil
		else
			return v6.Add, v6.Multi, v6.NameMap
		end
	end

	if p2 == "All" then
		local total = 0
		local multi = 1

		for k, v8 in SystemsMap do
			local resolver = v8.Resolver(p, p3)
			local compileArray, multi2 = v3.CompileArray(resolver)

			if compileArray < 0 or multi2 < 1 then
				warn((`[MULTIPLIERS] Problem with '{k}' multipliers! Add ({compileArray}) Multi ({multi2}).`))
			else
				total += compileArray
				multi *= multi2
				result[k] = {
					Add = compileArray,
					Multi = multi2
				}
			end
		end

		if v5 then
			v5[v4] = {
				Add = total,
				Multi = multi,
				NameMap = result,
				Time = now
			}
		end

		return total, multi, result
	else
		local v7 = SystemsMap[p2]

		if not v7 then
			return 0, 1, result
		end

		local resolver = v7.Resolver(p, p3)
		local compileArray, multi = v3.CompileArray(resolver)
		result[p2] = {
			Add = compileArray,
			Multi = multi
		}

		if v5 then
			v5[v4] = {
				Add = compileArray,
				Multi = multi,
				NameMap = result,
				Time = now
			}
		end

		return compileArray, multi, result
	end
end

Players.PlayerAdded:Connect(function(player)
	v2[tostring(player.UserId)] = {}
end)
Players.PlayerRemoving:Connect(function(player)
	v2[tostring(player.UserId)] = nil
end)

for _, v4 in Players:GetPlayers() do
	v2[tostring(v4.UserId)] = {}
end

return table.freeze(v3)