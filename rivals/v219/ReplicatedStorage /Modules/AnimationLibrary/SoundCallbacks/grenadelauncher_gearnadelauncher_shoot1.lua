return function(object, p, _)
	object:CreateSound("rbxassetid://17274369233", 0.75, 1 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://17274368912", 0.75, 1 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://117326796133738", 0.375, 1, true, 0.4 / p)
end