local Helmsman = require(script.Helmsman)
local Shipwright = require(script.Shipwright)
local bestValues = {}
local allStatNames = {}
local v3 = {}

for _, child in pairs(script:GetChildren()) do
	local name = child.Name
	local v4 = nil

	if name == "Shipwright" then
		v4 = Shipwright
	elseif name == "Helmsman" then
		v4 = Helmsman
	end

	assert(v4, "bad subclassInfoIn")
	assert(v4.Passives.Base, "bad subclassInfoIn.Passives.Base")
	local v5 = {
		Name = name,
		MaxLevel = -1,
		Cost = assert(v4.Passives.Base.Levels[1].Cost, "bad subclassCost"),
		DisplayName = assert(v4.DisplayName, "bad subclassInfoIn.DisplayName"),
		Description = assert(v4.Description, "bad subclassInfoIn.Description"),
		Passives = {}
	}
	bestValues[name] = {}

	for k, passive in pairs(v4.Passives) do
		bestValues[name][k] = {}
		local v6 = {
			UnlockOrder = assert(passive.UnlockOrder, "bad passiveIn.UnlockOrder"),
			LevelRequirement = assert(passive.LevelRequirement, "bad passiveIn.LevelRequirement"),
			DisplayName = assert(passive.DisplayName, "bad passiveIn.DisplayName"),
			Levels = {},
			Index = k
		}

		if v6.LevelRequirement > v5.MaxLevel then
			v5.MaxLevel = v6.LevelRequirement
		end

		for k2, level in pairs(passive.Levels) do
			local v7 = {
				Description = {
					Current = "???",
					Upgrade = nil
				},
				Cost = assert(level.Cost, "bad passiveLevelIn.Cost"),
				Upgrade = assert(level.Upgrade, "bad passiveLevelIn.Upgrade")
			}
			local RunService = game:GetService("RunService")

			if RunService:IsClient() then
				if passive.Description and level.Description == nil then
					v7.Description = passive.Description(passive, k2)
				else
					v7.Description = level.Description
				end
			end

			v6.Levels[k2] = v7

			for k3, v8 in level.Upgrade do
				bestValues[name][k][k3] = v8
				allStatNames[k3] = v8
			end
		end

		v5.Passives[k] = v6
	end

	v3[name] = v5
end

return {
	Data = v3,
	BestValues = bestValues,
	AllStatNames = allStatNames,
	MaxValor = 5000
}