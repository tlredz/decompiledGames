local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShrineFusionRules = require(ReplicatedStorage.Shared.Util.ShrineFusionRules)
local tiers = { "Both" }

for _, tier in ShrineFusionRules.Tiers do
	table.insert(tiers, tier)
end

return function(registry)
	registry:RegisterType("shrineFusionTier", registry.Cmdr.Util.MakeEnumType("ShrineFusionTier", tiers))
end