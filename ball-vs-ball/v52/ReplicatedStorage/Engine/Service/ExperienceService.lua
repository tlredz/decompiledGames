game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(script.Parent.Config)
local TimeService = require(script.Parent.TimeService)
local ExperienceService = {}
local _ = {
	Complete3Hp = "完成3HP比赛",
	Win = "赢得比赛",
	FirstMatchOfDay = "每日首场完成任意比赛"
}

local function getRewardExp(p: string)
	local v = Config.expSource.byCnId[p]
	local rewardExp = v and v.rewardExp

	if typeof(rewardExp) == "number" and not (rewardExp < 0) then
		return (math.floor(rewardExp))
	end

	warn((`[ExperienceService] 经验来源配置无效：${p}`))
	return 0
end

local function normalizeExpState(p)
	local v = typeof(p) ~= "table" and {} or p
	return {
		total = typeof(v.total) ~= "number" and 0 or math.max(0, (math.floor(v.total))),
		firstMatchDayKey = typeof(v.firstMatchDayKey) ~= "number" and 0 or v.firstMatchDayKey
	}
end

local v = false
local v2 = {}

local function getFormula()
	local lvlUpExpFormula = Config.misc.lvlUpExpFormula
	local v3

	if typeof(lvlUpExpFormula) == "table" then
		v3 = lvlUpExpFormula["基础经验"]
	end

	local selected

	if typeof(lvlUpExpFormula) == "table" then
		selected = lvlUpExpFormula["每级递增"]
	end

	if typeof(v3) == "number" and typeof(selected) == "number" then
		return v3, selected
	end

	if not v then
		v = true
		warn((`[ExperienceService] 兜底升级经验公式配置无效，回退默认值 {20}/{10}`))
	end

	return 20, 10
end

local function readTableTotals()
	local totalExpsByLvl = {}
	local v3 = 1

	for _, v4 in ipairs(Config.lvl.list) do
		if not (typeof(v4.lvl) == "number" and typeof(v4.totalExp) == "number") then
			continue
		end

		local lvl = math.floor(v4.lvl)
		totalExpsByLvl[lvl] = v4.totalExp
		v3 = math.max(v3, lvl)
	end

	return totalExpsByLvl, v3
end

local function nextLevelTotal(p: number, p2: number, p3, p4: number, p5: number, p6: number)
	local v3 = p + 1
	local v4 = p3[v3]

	if v4 and p2 < v4 then
		return v4
	end

	if v3 <= p4 and not v2[v3] then
		v2[v3] = true
		warn((`[ExperienceService] 等级表 {v3} 级 totalExp 缺失或不递增，已按兜底公式计算`))
	end

	return p2 + math.max(1, (math.floor(p5 + p * p6)))
end

function ExperienceService.getTotalExpForLevel(p: number)
	local v3 = math.max(1, (math.floor(p)))
	local v4, v5 = readTableTotals()
	local formula, v6 = getFormula()
	local v7 = v4[1] or 0

	for i = 1, v3 - 1 do
		local v8 = i + 1
		local v9 = v4[v8]

		if v9 and v7 < v9 then
			v7 = v9
		else
			if v8 <= v5 and not v2[v8] then
				v2[v8] = true
				warn((`[ExperienceService] 等级表 {v8} 级 totalExp 缺失或不递增，已按兜底公式计算`))
			end

			v7 += math.max(1, (math.floor(formula + i * v6)))
		end
	end

	return v7
end

function ExperienceService.getLevelInfo(value: number)
	local v3 = math.max(0, (math.floor(typeof(value) ~= "number" and 0 or value)))
	local v4, v5 = readTableTotals()
	local formula, v6 = getFormula()
	local level = 1
	local v8 = v4[1] or 0
	local v9 = level + 1
	local v10 = v4[v9]

	if not (v10 and v8 < v10) then
		if v9 <= v5 and not v2[v9] then
			v2[v9] = true
			warn((`[ExperienceService] 等级表 {v9} 级 totalExp 缺失或不递增，已按兜底公式计算`))
		end

		v10 = v8 + math.max(1, (math.floor(formula + level * v6)))
	end

	while v10 <= v3 do
		level += 1
		local v11 = level + 1
		local v12 = v4[v11]

		if not (v12 and v10 < v12) then
			if v11 <= v5 and not v2[v11] then
				v2[v11] = true
				warn((`[ExperienceService] 等级表 {v11} 级 totalExp 缺失或不递增，已按兜底公式计算`))
			end

			v12 = v10 + math.max(1, (math.floor(formula + level * v6)))
		end

		v8 = v10
		v10 = v12
	end

	local requiredExp = v10 - v8
	local currentExp = math.clamp(v3 - v8, 0, requiredExp)
	return {
		level = level,
		progress = currentExp / requiredExp,
		currentExp = currentExp,
		requiredExp = requiredExp
	}
end

function ExperienceService.isFeatureUnlocked(p: number, p2: string)
	local lvl = Config.lvl

	if type(lvl) ~= "table" or type(lvl.byFeatureUnlock) ~= "table" then
		return true
	end

	local lvl2 = nil
	local v3 = lvl.byFeatureUnlock[p2]

	if type(v3) == "table" then
		for _, v4 in v3 do
			if typeof(v4.lvl) == "number" and (lvl2 == nil or v4.lvl < lvl2) then
				lvl2 = math.floor(v4.lvl)
			end
		end
	end

	return lvl2 == nil or lvl2 <= ExperienceService.getLevelInfo(p).level
end

if not RunService:IsServer() then
	return ExperienceService
end

local PlayerData = require(script.Parent.PlayerData)
local BoostService = require(script.Parent.BoostService)

-- equivalent calls inferred from this helper; original call sites unknown
local function recordMatchForPlayer(p, _: number, _: string, p2: number, userId: number?, p3: number)
	if p.Parent == nil then
		return
	end

	local dayKey = TimeService.getDayKey(0)
	PlayerData.server[p].exp(function(p4)
		local expState = normalizeExpState(p4)
		local total = 0

		if p2 == 3 then
			local _3HP = Config.expSource.byCnId["完成3HP比赛"]
			local rewardExp = _3HP and _3HP.rewardExp
			local v4

			if typeof(rewardExp) == "number" and not (rewardExp < 0) then
				v4 = math.floor(rewardExp)
			else
				warn("[ExperienceService] 经验来源配置无效：$完成3HP比赛")
				v4 = 0
			end

			total += v4
		end

		if p.UserId == userId then
			local v4 = Config.expSource.byCnId["赢得比赛"]
			local rewardExp = v4 and v4.rewardExp
			local v5

			if typeof(rewardExp) == "number" and not (rewardExp < 0) then
				v5 = math.floor(rewardExp)
			else
				warn("[ExperienceService] 经验来源配置无效：$赢得比赛")
				v5 = 0
			end

			total += v5
		end

		if expState.firstMatchDayKey ~= dayKey then
			local v4 = Config.expSource.byCnId["每日首场完成任意比赛"]
			local rewardExp = v4 and v4.rewardExp
			local v5

			if typeof(rewardExp) == "number" and not (rewardExp < 0) then
				v5 = math.floor(rewardExp)
			else
				warn("[ExperienceService] 经验来源配置无效：$每日首场完成任意比赛")
				v5 = 0
			end

			total += v5
			expState.firstMatchDayKey = dayKey
		end

		local v4 = BoostService.server.apply(p, "经验加成", total * p3)
		return {
			total = expState.total + v4,
			firstMatchDayKey = expState.firstMatchDayKey
		}
	end)
end

ExperienceService.server = {
	recordCompletedMatch = function(list, p: string, p2: number, p3: number?)
		if p ~= "Duel" and p ~= "RPS" or #list ~= 2 then
			return
		end

		local v4 = list[1]
		local v5 = list[2]
		local _ = v5.UserId

		if v4.Parent ~= nil then
			local dayKey = TimeService.getDayKey(0)
			local v6 = 1
			PlayerData.server[v4].exp(function(p4)
				local expState = normalizeExpState(p4)
				local total = 0

				if p2 == 3 then
					local _3HP = Config.expSource.byCnId["完成3HP比赛"]
					local rewardExp = _3HP and _3HP.rewardExp
					local v7

					if typeof(rewardExp) == "number" and not (rewardExp < 0) then
						v7 = math.floor(rewardExp)
					else
						warn("[ExperienceService] 经验来源配置无效：$完成3HP比赛")
						v7 = 0
					end

					total += v7
				end

				if v4.UserId == p3 then
					local v7 = Config.expSource.byCnId["赢得比赛"]
					local rewardExp = v7 and v7.rewardExp
					local v8

					if typeof(rewardExp) == "number" and not (rewardExp < 0) then
						v8 = math.floor(rewardExp)
					else
						warn("[ExperienceService] 经验来源配置无效：$赢得比赛")
						v8 = 0
					end

					total += v8
				end

				if expState.firstMatchDayKey ~= dayKey then
					local v7 = Config.expSource.byCnId["每日首场完成任意比赛"]
					local rewardExp = v7 and v7.rewardExp
					local v8

					if typeof(rewardExp) == "number" and not (rewardExp < 0) then
						v8 = math.floor(rewardExp)
					else
						warn("[ExperienceService] 经验来源配置无效：$每日首场完成任意比赛")
						v8 = 0
					end

					total += v8
					expState.firstMatchDayKey = dayKey
				end

				local v7 = BoostService.server.apply(v4, "经验加成", total * v6)
				return {
					total = expState.total + v7,
					firstMatchDayKey = expState.firstMatchDayKey
				}
			end)
		end

		local _ = v4.UserId

		if v5.Parent == nil then
			return
		end

		local dayKey = TimeService.getDayKey(0)
		local v6 = 1
		PlayerData.server[v5].exp(function(p4)
			local expState = normalizeExpState(p4)
			local total = 0

			if p2 == 3 then
				local _3HP = Config.expSource.byCnId["完成3HP比赛"]
				local rewardExp = _3HP and _3HP.rewardExp
				local v7

				if typeof(rewardExp) == "number" and not (rewardExp < 0) then
					v7 = math.floor(rewardExp)
				else
					warn("[ExperienceService] 经验来源配置无效：$完成3HP比赛")
					v7 = 0
				end

				total += v7
			end

			if v5.UserId == p3 then
				local v7 = Config.expSource.byCnId["赢得比赛"]
				local rewardExp = v7 and v7.rewardExp
				local v8

				if typeof(rewardExp) == "number" and not (rewardExp < 0) then
					v8 = math.floor(rewardExp)
				else
					warn("[ExperienceService] 经验来源配置无效：$赢得比赛")
					v8 = 0
				end

				total += v8
			end

			if expState.firstMatchDayKey ~= dayKey then
				local v7 = Config.expSource.byCnId["每日首场完成任意比赛"]
				local rewardExp = v7 and v7.rewardExp
				local v8

				if typeof(rewardExp) == "number" and not (rewardExp < 0) then
					v8 = math.floor(rewardExp)
				else
					warn("[ExperienceService] 经验来源配置无效：$每日首场完成任意比赛")
					v8 = 0
				end

				total += v8
				expState.firstMatchDayKey = dayKey
			end

			local v7 = BoostService.server.apply(v5, "经验加成", total * v6)
			return {
				total = expState.total + v7,
				firstMatchDayKey = expState.firstMatchDayKey
			}
		end)
	end,
	recordCompletedTeamMatch = function(list, p: string, p2: number, list2)
		if p ~= "TwoVTwo" then
			return
		end

		for _, v4 in ipairs(list) do
			local userId

			if table.find(list2, v4.UserId) then
				userId = v4.UserId
			end

			if v4.Parent == nil then
				continue
			end

			local v6 = v4
			local v7 = userId
			local firstMatchDayKey = TimeService.getDayKey(0)
			local v9 = 1
			PlayerData.server[v4].exp(function(p3)
				local expState = normalizeExpState(p3)
				local total = 0

				if p2 == 3 then
					local _3HP = Config.expSource.byCnId["完成3HP比赛"]
					local rewardExp = _3HP and _3HP.rewardExp
					local v10

					if typeof(rewardExp) == "number" and not (rewardExp < 0) then
						v10 = math.floor(rewardExp)
					else
						warn("[ExperienceService] 经验来源配置无效：$完成3HP比赛")
						v10 = 0
					end

					total += v10
				end

				if v6.UserId == v7 then
					local v10 = Config.expSource.byCnId["赢得比赛"]
					local rewardExp = v10 and v10.rewardExp
					local v11

					if typeof(rewardExp) == "number" and not (rewardExp < 0) then
						v11 = math.floor(rewardExp)
					else
						warn("[ExperienceService] 经验来源配置无效：$赢得比赛")
						v11 = 0
					end

					total += v11
				end

				if expState.firstMatchDayKey ~= firstMatchDayKey then
					local v10 = Config.expSource.byCnId["每日首场完成任意比赛"]
					local rewardExp = v10 and v10.rewardExp
					local v11

					if typeof(rewardExp) == "number" and not (rewardExp < 0) then
						v11 = math.floor(rewardExp)
					else
						warn("[ExperienceService] 经验来源配置无效：$每日首场完成任意比赛")
						v11 = 0
					end

					total += v11
					expState.firstMatchDayKey = firstMatchDayKey
				end

				local v10 = BoostService.server.apply(v6, "经验加成", total * v9)
				return {
					total = expState.total + v10,
					firstMatchDayKey = expState.firstMatchDayKey
				}
			end)
		end
	end,
	recordForfeitWin = function(p, p2, p3: string, p4: number, value: number)
		if p3 ~= "Duel" and p3 ~= "RPS" and p3 ~= "TwoVTwo" or value <= 0 then
			return
		end

		local _ = p2.UserId
		recordMatchForPlayer(p, nil, nil, p4, p.UserId, math.clamp(value, 0, 1)) -- equivalent call inferred; original call site unknown
	end,
	add = function(p, value: number)
		if typeof(value) ~= "number" or value <= 0 or value % 1 ~= 0 then
			return false
		end

		PlayerData.server[p].exp(function(p2)
			local expState = normalizeExpState(p2)
			expState.total += value
			return expState
		end)
		return true
	end,
	reset = function(p)
		PlayerData.server[p].exp({
			total = 0,
			firstMatchDayKey = 0
		})
	end
}
return ExperienceService