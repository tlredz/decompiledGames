return function(object, _, _)
	object:CreateSound("rbxassetid://13087362838", 1, 2.4 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://13087362838", 0.5, 1 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://126250530419268", 0.875, 0.9 + 0.1 * math.random(), true, 10)
end