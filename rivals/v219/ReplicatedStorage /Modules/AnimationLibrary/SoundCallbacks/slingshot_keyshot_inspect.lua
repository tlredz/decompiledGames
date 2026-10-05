return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://8971407217", 0.5, 1.25, true, 5)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 2.85 / p) then
		return
	end

	object:CreateSound("rbxassetid://14241444681", 0.5, 1.5, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1 + 0.1 * math.random(), true, 5)
	object:CreateSound("rbxasset://sounds//Rubber band sling shot.mp3", 0.75, 1.4 + 0.2 * math.random(), true, 5)
end