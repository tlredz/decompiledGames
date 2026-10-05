local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return function(p, p2: number)
	if p then
		local data = Utility.GetData(p)

		if data == nil then
			return
		end

		data.SkillPoints.Value += p2
	end
end