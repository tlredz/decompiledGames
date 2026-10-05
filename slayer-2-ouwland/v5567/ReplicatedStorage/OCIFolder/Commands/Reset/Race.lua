local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local SkillTreeholder = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder)
return function(list)
	for _, v in ipairs(list) do
		local data = Utility.GetData(v)

		if data == nil then
			continue
		end

		SkillTreeholder.ResetPowerBranch(v, "Breathing")
		SkillTreeholder.ResetPowerBranch(v, "DemonArt")
		data.Race.Value = "Human"
	end
end