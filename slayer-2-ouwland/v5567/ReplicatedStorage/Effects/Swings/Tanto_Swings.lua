local WeaponAuras = require(script.Parent:WaitForChild("WeaponAuras"))
local Combat_Swings = require(script.Parent:WaitForChild("Combat_Swings"))
local v = {
	anchorParts = {
		Blade = true
	}
}
return function(p, p2, p3)
	if p2 == 5 then
		Combat_Swings(p, 5, p3)
	else
		WeaponAuras(p, p2, p3, v)
	end
end