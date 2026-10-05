return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1, 2, true, 10)
	object:CreateSound("rbxassetid://100664516053133", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1, 2.5, true, 10)
	object:CreateSound("rbxassetid://100664516053133", 0.25, 1.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 2, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1 + 0.1 * math.random(), true, 5)
end