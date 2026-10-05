return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://13682183816", 0.5, 2 + 0.5 * math.random(), true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.5, 1.5 + 0.25 * math.random(), true, 5)
	object:CreateSound("rbxassetid://71387264231358", 0.375, 1, true, 10)
end