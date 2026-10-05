local LevelModule = {
	XPTable = {}
}

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function GetTotalXP(p)
	return (1000 + 225 * p) * p - 225 * (p * (0.5 * (p - 1))) - 1000 - 225
end

local function GenerateXPTable(p)
	local total = 0

	for i = 1, 100 do
		local totalXP = GetTotalXP(i - 1)
		total += GetTotalXP(i) - totalXP
		LevelModule.XPTable[i] = total

		if p then
			print("Level: ", i, " XP: ", i, GetTotalXP(i))
		end
	end
end

GenerateXPTable()

function LevelModule.GetLevel(value)
	local v = value or 0

	if v >= 1237500 then
		return 100, LevelModule.XPTable[100]
	end

	for k, v2 in LevelModule.XPTable do
		local v3 = LevelModule.XPTable[k + 1]

		if v3 == nil then
			if v2 <= v then
				return k, v2
			end
		elseif v2 <= v and v < v3 then
			return k, v3
		end
	end

	return 1, LevelModule.XPTable[2]
end

function LevelModule.GetXP(value)
	local v = value or 1
	return GetTotalXP(v < 1 and 1 or v)
end

function LevelModule.GetProgressToNextLevel(p)
	local level, v = LevelModule.GetLevel(p)
	local XP = LevelModule.GetXP(level)
	return (p - XP) / (v - XP)
end

return LevelModule