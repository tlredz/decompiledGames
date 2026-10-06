local TimeService = require(script.Parent.TimeService)
local WeeklyFreeBallService = {}

local function validInteger(value)
	return typeof(value) == "number" and value == value and value >= 0 and value < 1e999 and value % 1 == 0
end

function WeeklyFreeBallService.getUnlockLevel(p)
	local lvl = nil
	local list = p.lvl and p.lvl.list

	if typeof(list) ~= "table" then
		return nil
	end

	for _, v in list do
		if v.featureUnlock ~= "每周免费球" then
			continue
		end

		local lvl2 = v.lvl
		local v2

		if typeof(lvl2) == "number" and lvl2 == lvl2 and lvl2 >= 0 and lvl2 < 1e999 then
			v2 = lvl2 % 1 == 0
		else
			v2 = false
		end

		if v2 and v.lvl >= 1 and (lvl == nil or v.lvl < lvl) then
			lvl = v.lvl
		end
	end

	return lvl
end

local function targets(targetId)
	local result = {}

	local function add(value)
		if typeof(value) ~= "string" then
			return
		end

		for k in string.gmatch(string.gsub(value, "，", ","), "[^,]+") do
			local v = string.match(k, "^%s*(.-)%s*$")

			if v and v ~= "" then
				table.insert(result, v)
			end
		end
	end

	if typeof(targetId) ~= "table" then
		add(targetId)
		return result
	end

	for _, item in targetId do
		add(item)
	end

	return result
end

function WeeklyFreeBallService.getRotation(data, p, p2: number?)
	local weeklyFreeBallCount = data.misc and data.misc.weeklyFreeBallCount
	local v

	if typeof(weeklyFreeBallCount) == "number" and weeklyFreeBallCount == weeklyFreeBallCount and weeklyFreeBallCount >= 0 and weeklyFreeBallCount < 1e999 then
		v = weeklyFreeBallCount % 1 == 0
	else
		v = false
	end

	if not v or weeklyFreeBallCount == 0 then
		return {}
	end

	local list = data.gacha and data.gacha.list

	if typeof(list) ~= "table" then
		return {}
	end

	local v2 = p2 or TimeService.now()
	local weekBoundaryDayKeyAt = TimeService.getWeekBoundaryDayKeyAt(v2, 0, 0, 1)
	local v3 = {}

	for _, v4 in p.battle.rolePool do
		if data.ball.byCnId[v4] and p.roles[v4] then
			v3[v4] = true
		end
	end

	local v4 = {}
	local v5 = {}

	for _, v6 in list do
		if not (v6.cnId == "金币小球箱子" and v6.itemType == "小球" and v6.unlockCondition == "x") then
			continue
		end

		local unlockDate = v6.unlockDate

		if unlockDate ~= nil and unlockDate ~= "" then
			local success, result = pcall(TimeService.configDateToDayKey, unlockDate)

			if not success or result == nil or weekBoundaryDayKeyAt < result then
				continue
			end
		end

		for _, v7 in targets(v6.targetId) do
			if not v3[v7] or v4[v7] then
				continue
			end

			v4[v7] = true
			table.insert(v5, v7)
		end
	end

	table.sort(v5)
	local random = Random.new(TimeService.getWeekKeyAt(weekBoundaryDayKeyAt * 86400, 0, 0, 1))
	local result = {}

	for _ = 1, math.min(weeklyFreeBallCount, #v5) do
		table.insert(result, table.remove(v5, random:NextInteger(1, #v5)))
	end

	return result
end

function WeeklyFreeBallService.buildMatchPool(p, p2: number, items, items2)
	local v = {}
	local result = {}
	local result2 = {}

	for _, item in items do
		if v[item] then
			continue
		end

		v[item] = true
		table.insert(result, item)
	end

	local unlockLevel = WeeklyFreeBallService.getUnlockLevel(p)

	if unlockLevel == nil or p2 < unlockLevel then
		return result, result2
	end

	for _, item in items2 do
		if v[item] then
			continue
		end

		v[item] = true
		table.insert(result, item)
		table.insert(result2, item)
	end

	return result, result2
end

return WeeklyFreeBallService