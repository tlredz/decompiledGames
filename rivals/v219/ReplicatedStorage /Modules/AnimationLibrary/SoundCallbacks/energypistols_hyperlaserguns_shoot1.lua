return function(object, _, _)
	if tick() < object.EnergyPistolsShootSoundCooldown then
		return
	end

	object.EnergyPistolsShootSoundCooldown = tick() + 0.05
	object:CreateSound("rbxassetid://130113322", 0.625, 1 + 0.2 * math.random(), true, 1)
end