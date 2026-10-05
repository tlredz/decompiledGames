return function(object, _, _)
	object:CreateSound("rbxassetid://77594993345414", 0.875, 1 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://21343225", 0.25 + 0.125 * math.random(), 0.9 + 0.2 * math.random(), true, 10)
end