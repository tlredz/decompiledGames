return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://14240944488", 0.75, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://14240944327", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 1.5, true, 10)
end