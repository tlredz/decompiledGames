return function(object, p, p2)
	object:CreateSound("rbxassetid://96253147006478", 0.6, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://110122962237431", 0.75, 0.5 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.85 / p) then
		return
	end

	object:CreateSound("rbxassetid://110122962237431", 1, 1.1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.375, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 2.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
end