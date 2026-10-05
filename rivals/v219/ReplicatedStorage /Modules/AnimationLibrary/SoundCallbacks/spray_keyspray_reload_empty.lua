return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330555", 1, 1.25, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1, 1.1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.625, 0.9, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://84163808107137", 1, 1, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1, 1.1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://14241444681", 1, 1 + 0.25 * math.random(), true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1.25 + 0.25 * math.random() + 0.25, true, 5)
end