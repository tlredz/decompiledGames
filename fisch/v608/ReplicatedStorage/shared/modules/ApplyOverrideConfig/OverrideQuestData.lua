local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	ConfigName = "OverrideQuestData",
	ApplyEnvironment = "Both",
	Apply = function(items)
		if typeof(items) ~= "table" then
			return
		end

		local Quests = require(ReplicatedStorage.shared.modules:WaitForChild("Quests"))

		for k, item in items do
			if not Quests[k] then
				continue
			end

			for k2, v in item do
				Quests[k][k2] = v
			end
		end
	end
}