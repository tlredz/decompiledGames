return function(object, p, p2)
	object:CreateSound("rbxassetid://13479562219", 1, 1.25 + 0.25 * math.random(), true, 10)
	object:CreateSound("rbxassetid://83828319245396", 1.5, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://13515046921", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://13515046988", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13531443905", 0.125, 0.75 + 0.25 * math.random(), true, 10)
end