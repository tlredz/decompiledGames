local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = {
	RequiredForCrimsonCavernUnlocked = {
		Name = "Colossal Blue Dragon",
		Subvalues = {
			Mutation = "Crimson"
		}
	},
	AnnoThoughtRemote = ReplicatedStorage.events.anno_thought
}

if RunService:IsServer() then
	v.TotalPlantsRequiredTilli = 5
else
	v.AnnoThoughtBindable = ReplicatedStorage.events.anno_localthought
end

return table.freeze(v)