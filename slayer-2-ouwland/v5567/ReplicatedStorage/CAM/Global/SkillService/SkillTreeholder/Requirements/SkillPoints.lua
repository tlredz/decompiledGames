local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Stats = require(ReplicatedStorage.CAM.Global.SkillService.Stats)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local SkillPoints = {
	DisplayName = "Skill Points",
	Icon = BunchaIcons.SkillPoints,
	Persistent = false
}
local name = script.Name

function SkillPoints.CanBuy(p, p2: string, p3: number?)
	if p == nil or p2 == nil then
		return
	end

	local data = Utility.GetData(p)

	if data == nil then
		return
	end

	if p3 == nil then
		p3 = Stats.GetRequirements(p, p2)[name]
	end

	return p3 ~= nil and p3 <= data.SkillPoints.Value
end

function SkillPoints.Buy(p, p2: string, p3: number?)
	if p == nil or p2 == nil then
		return
	end

	local data = Utility.GetData(p)

	if data == nil then
		return
	end

	if p3 == nil then
		p3 = Stats.GetRequirements(p, p2)[name]
	end

	if p3 ~= nil then
		data.SkillPoints.Value -= p3
	end
end

function SkillPoints.Reset(p, _: string, p2: number)
	local data = Utility.GetData(p)

	if data == nil then
		return
	end

	data.SkillPoints.Value += p2
end

return SkillPoints