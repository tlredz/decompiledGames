local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Config)
local Config2 = require(script.Parent.Config)
local worlds = ReplicatedStorage.Config.Worlds
local BestStage = {}

function BestStage.theoretical(items, p: number)
	local v = 1

	for k, item in pairs(items) do
		if item <= p and v < k then
			v = k
		end
	end

	return v
end

function BestStage.isUpsell(p: number, p2: number)
	return p2 - 1 <= p
end

function BestStage.worldStageCount()
	local PROGRESSION = Config.PROGRESSION
	return PROGRESSION.WIN_BLOCK_LAST - PROGRESSION.WIN_BLOCK_FIRST + 1
end

function BestStage.bonusWalkspeed(p: number, p2: number)
	local v = Config.STAGE_RECOMMENDED_LEVELS[p2]
	local v2 = (v == nil or not (p < v)) and 0 or Config.CalculateMaxSpeed(v) - Config.CalculateMaxSpeed(p)
	return (math.min(
		math.max(
			not (v2 > 0) and 0 or math.ceil(v2 / Config2.BONUS_STEP - 1e-6) * Config2.BONUS_STEP,
			Config2.BONUS_MIN
		),
		Config2.BONUS_MAX
	))
end

function BestStage.playableWorlds()
	local modules = {}

	for _, moduleScript in worlds:GetChildren() do
		if string.match(moduleScript.Name, "^World%d+$") then
			table.insert(modules, require(moduleScript))
		end
	end

	return modules
end

function BestStage.stageFromWinBlock(value: string)
	local v = nil

	if type(Config.WORLD) ~= "number" or not Config.PROGRESSION then
		return v
	end

	local PROGRESSION = Config.PROGRESSION
	local v2 = value == "WinBlock" and 1 or tonumber(string.match(value, "^WinBlock(%d+)$"))

	if v2 and PROGRESSION.WIN_BLOCK_FIRST <= v2 and v2 <= PROGRESSION.WIN_BLOCK_LAST then
		return v2 - PROGRESSION.WIN_BLOCK_FIRST + 1
	end

	return v
end

return BestStage