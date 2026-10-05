return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650945056", 1, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.1333333333333333 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650945056", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6666666666666666 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650837861", 1, 3, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650837861", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.7333333333333333 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650837861", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650837861", 1, 3, true, 10)
end