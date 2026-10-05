return function(object, p, p2)
	object:CreateSound("rbxassetid://113227486192611", 0.875, 1 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://122971606160018", 0.875, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.43 / p) then
		return
	end

	object:CreateSound("rbxassetid://17672502879", 0.875, 0.875, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.47 / p) then
		return
	end

	object:CreateSound("rbxassetid://17672502879", 0.5, 3, true, 10)
end