return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650945056", 1, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.92 / p) then
		return
	end

	object:CreateSound("rbxassetid://17650945056", 1, 1, true, 10)
end