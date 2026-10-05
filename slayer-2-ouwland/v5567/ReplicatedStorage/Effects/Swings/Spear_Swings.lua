local WeaponAuras = require(script.Parent:WaitForChild("WeaponAuras"))
local v = {
	anchorParts = {
		Spear = true,
		["Meshes/PS2 WEAPONS_Plane.003"] = true
	}
}
return function(p, p2, p3)
	WeaponAuras(p, p2, p3, v)
end