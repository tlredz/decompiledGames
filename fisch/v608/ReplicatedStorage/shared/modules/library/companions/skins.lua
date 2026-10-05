local modulesByName = {}
local skins = {}

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module

	for k, v2 in modulesByName[moduleScript.Name] do
		v2.TargetCompanion = moduleScript.Name
		skins[k] = v2
	end
end

return {
	Skins = skins,
	CompanionSkins = modulesByName,
	Rarities = {
		Common = {
			Color = Color3.fromRGB(89, 89, 89),
			ColorSequence = ColorSequence.new(Color3.fromRGB(89, 89, 89), Color3.fromRGB(0, 0, 0)),
			Weight = 1
		},
		Rare = {
			Color = Color3.fromRGB(0, 85, 255),
			ColorSequence = ColorSequence.new(Color3.fromRGB(0, 85, 255), Color3.fromRGB(0, 0, 0)),
			Weight = 2
		},
		Legendary = {
			Color = Color3.fromRGB(255, 217, 0),
			ColorSequence = ColorSequence.new(Color3.fromRGB(255, 217, 0), Color3.fromRGB(0, 0, 0)),
			Weight = 3
		},
		Secret = {
			Color = Color3.fromRGB(255, 255, 255),
			ColorSequence = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0)),
			Weight = 20
		}
	}
}