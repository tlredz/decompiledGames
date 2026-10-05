return function(object, _, _)
	object:CreateSound("rbxassetid://17650837718", 1, 1.25 + 0.25 * math.random(), true, 10)
	object:CreateSound("rbxassetid://17650837861", 1, 1.5 + 0.25 * math.random(), true, 10)
	object:CreateSound("rbxassetid://17650837861", 1.5, 3 + 0.5 * math.random(), true, 10)
end