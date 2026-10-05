return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.13333333333333333 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650945056", 1.25, 1.5, true, 10)
	object:CreateSound("rbxassetid://17650837503", 1.25, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.9166666666666666 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650945056", 1, 1, true, 10)
	object:CreateSound("rbxassetid://17650837718", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5166666666666667 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650838003", 2, 1.25, true, 10)
end