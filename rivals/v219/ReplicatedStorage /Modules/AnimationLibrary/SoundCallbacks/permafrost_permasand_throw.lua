return function(object, _, _)
	object:CreateSound("rbxassetid://14522189766", 2, 1 + 0.25 * math.random(), true, 10)
	object:CreateSound("rbxassetid://87740786635301", 0.375 + 0.25 * math.random(), 0.9 + 0.4 * math.random(), true, 5)
end