local FruitM1Speed = {
	getCooldownScale = function(instance)
		local v

		if instance then
			v = instance:GetAttribute("FruitTAPCooldown")
		end

		return (math.clamp(1 - (v or 0), 0.05, 1))
	end
}

function FruitM1Speed.getWeaponCooldownScale(p, p2: string?)
	if p2 == "Demon Fruit" then
		return (FruitM1Speed.getCooldownScale(p))
	end

	return 1
end

return FruitM1Speed