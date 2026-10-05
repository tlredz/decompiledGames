local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SkillTreeConfig = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder.SkillTreeConfig)
local Stats = require(ReplicatedStorage.CAM.Global.SkillService.Stats)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return function(p, childName: string, _, flag: boolean?)
	local data = Utility.GetData(p)

	if data == nil then
		return 0
	end

	local v = SkillTreeConfig[childName]

	if v == nil then
		return 0
	end

	local skillTreeUnlockedList = data:FindFirstChild("SkillTreeUnlockedList")
	local child = skillTreeUnlockedList and skillTreeUnlockedList:FindFirstChild(childName)
	local value = child and child.Value or 0

	if value <= 0 then
		return 0
	end

	local statValue = Stats.GetStatValue(v.Value, value, v.IsRatio)

	if flag and v.IsRatio then
		statValue -= 1
	end

	return statValue
end