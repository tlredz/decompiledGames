return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.13333333333333333 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330555", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.9166666666666666 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330666", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5166666666666667 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330383", 1, 1, true, 10)
end