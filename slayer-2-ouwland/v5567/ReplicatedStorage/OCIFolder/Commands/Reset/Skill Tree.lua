local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SkillTreeholder = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder)
return function(items, p: string?)
	if p == "" then
		p = nil
	end

	for _, item in items do
		SkillTreeholder.ResetTree(item, p)
	end
end