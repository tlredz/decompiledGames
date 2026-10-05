return function(object, p, p2)
	object:CreateSound("rbxassetid://13160400909", 1, 0.9 + 0.2 * math.random(), true, 10)
	object:CreateSound("rbxassetid://101733853413710", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://96253147006478", 0.75, 1.75 + 0.5 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://110122962237431", 0.5, 1 + 0.5 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 1.05 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://113941779770778", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://110122962237431", 0.5, 1 + 0.5 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://76064160033456", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://110122962237431", 0.5, 1 + 0.5 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://110122962237431", 0.5, 1 + 0.5 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://106430462780583", 1, 1.5 + 0.2 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://110122962237431", 0.5, 1 + 0.5 * math.random(), true, 5)
end