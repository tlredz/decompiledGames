return function(object, _, _)
	object:CreateSound("rbxassetid://13682898881", 1.25, 0.6 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://13682898881", 0.875, 1 + 0.2 * math.random(), true, 10)
	object:CreateSound("rbxassetid://13682223944", 0.75, 1 + 0.5 * math.random(), true, 10)
	object:CreateSound("rbxassetid://18763594759", 0.5, 1, true, 10)
end