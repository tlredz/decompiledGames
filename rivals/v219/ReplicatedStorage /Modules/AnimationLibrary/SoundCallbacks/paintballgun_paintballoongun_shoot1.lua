return function(object, _, _)
	object:CreateSound("rbxasset://sounds//paintball.wav", 0.875, 1 + 0.1 * math.random(), true, 5)
	object:CreateSound("rbxassetid://17803360572", 1, 3 + 0.3 * math.random(), true, 10)
end