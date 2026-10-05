return function(object, p, p2)
	object:CreateSound("rbxassetid://128735130219172", 0.5, 1 + 0.2 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://114830743588818", 0.5, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://114830743588818", 0.5, 1.1 + 0.1 * math.random(), true, 10)
end