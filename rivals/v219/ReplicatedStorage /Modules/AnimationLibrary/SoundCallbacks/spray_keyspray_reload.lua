return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330555", 1, 1.25, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1, 1.1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.625, 0.9, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://84163808107137", 1, 1, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1, 1.1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
end