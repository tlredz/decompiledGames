return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128896162", 1, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128896162", 1, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128896162", 1, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128896162", 1, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128896162", 1, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128949754", 0.6, 1 + 0.1 * math.random(), true, 10)
end