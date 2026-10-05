return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://115253895253213", 0.875, 1 + 0.2 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://115253895253213", 0.875, 1 + 0.2 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://137209644295911", 0.875, 1 + 0.2 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.95 / p) then
		return
	end

	object:CreateSound("rbxassetid://137209644295911", 0.875, 1 + 0.2 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 1.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://137209644295911", 0.875, 1 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://135586619814232", 0.875, 1 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://92587536325720", 0.875, 1 + 0.2 * math.random(), true, 5)
end