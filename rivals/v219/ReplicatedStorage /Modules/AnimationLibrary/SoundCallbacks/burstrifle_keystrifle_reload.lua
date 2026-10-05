return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://110122962237431", 1.25, 1 + 0.1 * math.random(), true, 5)
	object:CreateSound("rbxassetid://71387264231358", 0.75, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
	object:CreateSound("rbxassetid://71387264231358", 1.25, 0.5, true, 10)
	object:CreateSound("rbxassetid://71387264231358", 1, 0.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.65 / p) then
		return
	end

	object:CreateSound("rbxassetid://110122962237431", 1.25, 1 + 0.1 * math.random(), true, 5)
	object:CreateSound("rbxassetid://71387264231358", 0.75, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
end