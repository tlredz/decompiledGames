return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1.25 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 1.65 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1.25 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1.25, 1.25, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1.25 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1.125, 1, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1.25 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1, 1.5, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1.25 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 0.875, 1, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1.25 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1.25, 2, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1.25 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 1, 1, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 1.25, 1.25 + 0.25 * math.random(), true, 5)
end