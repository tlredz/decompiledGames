return function(object, _, _)
	object:CreateSound("rbxassetid://13682898881", 1, 0.95 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://13682223944", 0.75, 1 + 0.5 * math.random(), true, 10)
end