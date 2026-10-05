return function(object, p, p2)
	object:CreateSound("rbxassetid://107901458751913", 1.5, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://134279576638277", 1.25, 2, true, 10)
end