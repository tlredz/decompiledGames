local QUEST_VALUE_LOOKUP = require(script.Parent.QUEST_VALUE_LOOKUP)

local function ReturnEmptyQuestValue(_)
	return 0
end

local function GetValueRange(p: number, tierRange, winRange)
	local count = #winRange
	local flag = true

	for i, v2 in ipairs(winRange) do
		if not (v2 < p) then
			continue
		end

		count = i
		flag = false
		break
	end

	if flag then
		return tierRange[#tierRange]
	end

	return tierRange[count]
end

local function GetQuestValue(p: string, value: string)
	local parts = value:split("-")

	if not parts then
		return ReturnEmptyQuestValue
	end

	local v = QUEST_VALUE_LOOKUP[p]

	if not v then
		return ReturnEmptyQuestValue
	end

	local tierRange = v.TierRange
	local flag = true

	for _, part in ipairs(parts) do
		local v3 = tierRange[part]

		if v3 and typeof(v3) == "table" then
			tierRange = v3
		else
			flag = false
			break
		end
	end

	if flag then
		return function(object)
			local v3 = 0

			if v.WinsOnJoin then
				v3 = object:Get(v.WinsOnJoin) or v3
			end

			return (GetValueRange(v3, tierRange, v.WinRange))
		end
	end

	return ReturnEmptyQuestValue
end

return GetQuestValue