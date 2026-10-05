return function(object, _, _)
	if tick() < object.EnergyPistolsShootSoundCooldown then
		return
	end

	object.EnergyPistolsShootSoundCooldown = tick() + 0.05
	object:CreateSound("rbxassetid://120386834342865", 0.625, 1.4 + 0.2 * math.random(), true, 1)
	object:CreateSound("rbxassetid://119904392413280", 1, 3.5 + 0.25 * math.random(), true, 5)
end