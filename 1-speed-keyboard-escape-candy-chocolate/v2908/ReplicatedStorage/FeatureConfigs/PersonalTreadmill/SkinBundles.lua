local Skins = require(script.Parent:WaitForChild("Skins"))
local SKINS = Skins.SKINS
local BUNDLES = {
	["BBNO$Bundle"] = {
		displayName = "BBNO$ Collection Bundle",
		description = "Unlock all 8 BBNO$ collab treadmill skins in one purchase.",
		icon = "rbxassetid://80345673772455",
		color = Color3.new(0.764706, 0.129412, 0.129412),
		category = "BBNO",
		EventKey = "Bbno2026",
		price = 3611160345,
		skinKeys = {
			"BBNO$BoxingTreadmill",
			"BBNO$BrazilTreadmill",
			"BBNO$CosmicTreadmill",
			"BBNO$EdamameTreadmill",
			"BBNO$FashionTreadmill",
			"BBNO$LALALATreadmill",
			"BBNO$PlaneTreadmill",
			"BBNO$CowboyTreadmill"
		}
	}
}

for k, v2 in pairs(BUNDLES) do
	for _, skinKey in ipairs(v2.skinKeys) do
		assert(SKINS[skinKey], ("[SkinBundles] '%s' référence une skin inconnue : '%s'"):format(k, skinKey))
	end
end

return {
	BUNDLES = BUNDLES
}