return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://110122962237431", 1.25, 1 + 0.1 * math.random(), true, 5)
	object:CreateSound("rbxassetid://71387264231358", 0.75, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://71387264231358", 0.75, 0.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.8 / p) then
		return
	end

	object:CreateSound("rbxassetid://110122962237431", 1.25, 1 + 0.1 * math.random(), true, 5)
	object:CreateSound("rbxassetid://71387264231358", 0.75, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
end