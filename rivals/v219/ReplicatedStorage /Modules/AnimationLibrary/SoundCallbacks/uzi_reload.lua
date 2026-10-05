return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330555", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330666", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330666", 1, 2, true, 10)
end