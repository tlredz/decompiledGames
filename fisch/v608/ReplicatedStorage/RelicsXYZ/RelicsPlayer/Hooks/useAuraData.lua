local parent = script.Parent
local useTagged = require(parent.useTagged)
local useAttribute = require(parent.useAttribute)
local usePlayerData = require(parent.usePlayerData)

local function useAuraData()
	local v = useTagged("RelicsAuraConfig")[1]
	return usePlayerData("Auras").Auras, {
		RollsPerDay = useAttribute(v, "RollsPerDay", tonumber),
		RollAssetId = useAttribute(v, "RollAssetId", tonumber),
		RollGamePass = useAttribute(v, "RollGamePass", tonumber),
		RollsWithProduct = useAttribute(v, "RollsWithProduct", tonumber)
	}
end

return useAuraData