local WeaponAuras = require(script.Parent:WaitForChild("WeaponAuras"))
local v = {
	anchorParts = {
		Blade = true,
		Blade2 = true
	}
}
return function(p, p2, p3)
	WeaponAuras(p, p2, p3, v)
end