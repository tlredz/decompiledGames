return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650945056", 0.5, 1.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.28 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650945056", 0.5, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.42 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650945056", 0.5, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://106994976644858", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://106994976644858", 1, 0.875, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.58 / p) then
		return
	end

	object:CreateSound("rbxassetid://106994976644858", 1, 1.25, true, 10)
end