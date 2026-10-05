local modulesByName = {}
local skins = {}
local HarpoonGunSkins = {}

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module

	for k, v2 in modulesByName[moduleScript.Name] do
		v2.TargetGun = moduleScript.Name
		skins[k] = v2
	end
end

local rarities = {
	Common = {
		Color = Color3.fromRGB(89, 89, 89),
		ColorSequence = ColorSequence.new(Color3.fromRGB(89, 89, 89), Color3.fromRGB(0, 0, 0)),
		Weight = 1,
		RefoundPercentage = 0.25
	},
	Rare = {
		Color = Color3.fromRGB(0, 85, 255),
		ColorSequence = ColorSequence.new(Color3.fromRGB(0, 85, 255), Color3.fromRGB(0, 0, 0)),
		Weight = 2,
		RefoundPercentage = 0.33
	},
	Legendary = {
		Color = Color3.fromRGB(255, 217, 0),
		ColorSequence = ColorSequence.new(Color3.fromRGB(255, 217, 0), Color3.fromRGB(0, 0, 0)),
		Weight = 3,
		RefoundPercentage = 0.5
	},
	Secret = {
		Color = Color3.fromRGB(255, 255, 255),
		ColorSequence = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0)),
		Weight = 20,
		RefoundPercentage = 1
	},
	["Divine Secret"] = {
		Color = Color3.fromRGB(189, 131, 255),
		ColorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(117, 117, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(224, 188, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 92, 255))
		}),
		Weight = 500,
		RefoundPercentage = 1
	}
}
HarpoonGunSkins.Skins = skins
HarpoonGunSkins.GunsSkins = modulesByName
HarpoonGunSkins.Rarities = rarities
return HarpoonGunSkins