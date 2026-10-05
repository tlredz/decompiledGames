return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330555", 1, 1, true, 10)
	object:CreateSound("rbxassetid://13236549962", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330555", 1, 1.5, true, 10)
end