return function(object, p, p2)
	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)
	object:CreateSpectatorSound("rbxassetid://76064160033456", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://108891371725091", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSpectatorSound("rbxassetid://106430462780583", 1, 1.5 + 0.2 * math.random(), true, 10)
end