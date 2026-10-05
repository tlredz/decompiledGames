return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.8 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650945056", 1.25, 1.5, true, 10)
	object:CreateSound("rbxassetid://17650837503", 1.25, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.63 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650945056", 1, 1, true, 10)
	object:CreateSound("rbxassetid://17650837718", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.03 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650837861", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.66 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650837861", 1, 1, true, 10)
end