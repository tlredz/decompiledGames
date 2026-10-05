return function(object, p, p2)
	object:CreateSound("rbxassetid://13455968853", 1, 1.5 + 0.5 * math.random(), true, 10)
	object:CreateSound("rbxassetid://101733853413710", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://96253147006478", 0.75, 1.75 + 0.5 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://110122962237431", 0.5, 1 + 0.5 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 1.05 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://76064160033456", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://110122962237431", 0.5, 1 + 0.5 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://110122962237431", 0.5, 1 + 0.5 * math.random(), true, 5)
end