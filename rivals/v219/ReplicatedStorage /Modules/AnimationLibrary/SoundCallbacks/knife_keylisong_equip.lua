return function(object, p, p2)
	object:CreateSound("rbxassetid://100664516053133", 0.25, 1.5, true, 10)
	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://76064160033456", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://110122962237431", 0.5, 1 + 0.5 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://106430462780583", 1, 1.5 + 0.2 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://110122962237431", 0.5, 1 + 0.5 * math.random(), true, 5)
end