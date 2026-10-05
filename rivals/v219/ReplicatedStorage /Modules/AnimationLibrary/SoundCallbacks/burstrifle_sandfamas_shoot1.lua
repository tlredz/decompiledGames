return function(object, _, _)
	object:CreateSound("rbxassetid://17662574783", 0.75, 1.2 + 0.4 * math.random(), true, 5)
	object:CreateSound("rbxassetid://18764343961", 1.125, 1.4 + 0.4 * math.random(), true, 5)
	object:CreateSound("rbxassetid://87740786635301", 0.375 + 0.25 * math.random(), 0.9 + 0.4 * math.random(), true, 5)
end