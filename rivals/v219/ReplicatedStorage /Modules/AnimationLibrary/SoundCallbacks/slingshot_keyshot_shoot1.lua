return function(object, _, _)
	object:CreateSound("rbxasset://sounds//Rubber band sling shot.mp3", 0.75, 1 + 0.375 * math.random(), true, 5)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1.4 + 0.1 * math.random(), true, 5)
end