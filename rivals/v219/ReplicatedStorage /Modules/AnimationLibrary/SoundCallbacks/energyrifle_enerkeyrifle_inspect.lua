return function(object, p, p2)
	object:CreateSound("rbxassetid://110122962237431", 1, 1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 1.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1, 1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 1.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 1, 1.1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.7, 0.9, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 2, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1 + 0.25 * math.random(), true, 5)
end