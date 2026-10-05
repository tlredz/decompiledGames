return function(object, _, _)
	object:CreateSound("rbxassetid://100354903585817", 0.875, 1 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://90757583550672", 0.4, 3 + 0.3 * math.random(), true, 5)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1 + 0.1 * math.random(), true, 5)
	object:CreateSound("rbxassetid://14241444681", 1, 1 + 0.25 * math.random(), true, 10)
end