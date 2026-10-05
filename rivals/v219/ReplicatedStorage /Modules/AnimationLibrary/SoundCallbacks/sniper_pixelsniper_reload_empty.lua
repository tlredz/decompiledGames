return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.65 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650837861", 1, 3, true, 10)
	object:CreateSound("rbxassetid://17650837861", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.233 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650838003", 0.5, 0.875 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650945056", 1, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.85 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650945056", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.78 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650837861", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650837861", 1, 3, true, 10)
end