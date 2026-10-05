local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Stats = require(ReplicatedStorage.CAM.Global.SkillService.Stats)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local MasterySource = require(ReplicatedStorage.CAM.Global.Collectibles.MasterySource)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Mastery = {
	DisplayName = "Mastery",
	Icon = BunchaIcons.Mastery,
	Persistent = true
}
local name = script.Name

local function getMasteryInfo(p: string)
	local skillInfo = Stats.GetSkillInfo(p)

	if skillInfo == nil then
		return nil, gameSettings.expPerMasteryDefault
	end

	local masterySource = MasterySource(skillInfo.Category)

	if masterySource == nil or masterySource.Mastery == false then
		return nil, gameSettings.expPerMasteryDefault
	end

	local mastery

	if type(masterySource.Mastery) == "string" then
		mastery = masterySource.Mastery
	elseif type(masterySource.Mastery) == "table" then
		mastery = masterySource.Mastery.Value or skillInfo.Category
	else
		mastery = skillInfo.Category
	end

	return
		mastery,
		type(masterySource.Mastery) == "table" and masterySource.Mastery.IncrementAmount or gameSettings.expPerMasteryDefault
end

function Mastery.CanBuy(p, p2: string, p3: number?)
	if p == nil or p2 == nil then
		return
	end

	local data = Utility.GetData(p)

	if data == nil then
		return
	end

	if p3 == nil then
		local requirements = Stats.GetRequirements(p, p2)
		p3 = requirements and requirements[name]
	end

	if p3 == nil or p3 <= 0 then
		return true
	end

	local masteryInfo, v = getMasteryInfo(p2)

	if masteryInfo == nil then
		return true
	end

	local child = data.MasteryProgressionList:FindFirstChild(masteryInfo)

	if child == nil then
		return false
	end

	local goal = child:FindFirstChild("Goal")
	return goal ~= nil and p3 <= math.floor(goal.Value / v)
end

function Mastery.Buy(_, _: string, _: number?) end

return Mastery