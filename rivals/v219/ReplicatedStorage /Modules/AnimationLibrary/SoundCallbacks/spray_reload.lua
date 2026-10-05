return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330555", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.8 / p) then
		return
	end

	object:CreateSound("rbxassetid://84163808107137", 1, 1, true, 10)
end