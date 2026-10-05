return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://107901458751913", 1.5, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://71608982627584", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 9.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://107901458751913", 1.5, 1.5, true, 10)
end