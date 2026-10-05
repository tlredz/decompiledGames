return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://107901458751913", 1.5, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://92573395473684", 1.25, 0.7 * p / 0.729, true, 10)
end