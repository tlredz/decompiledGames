return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.8 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330666", 1, 1.4, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.63 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330666", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.03 / p) then
		return
	end

	object:CreateSound("rbxassetid://13907558696", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.66 / p) then
		return
	end

	object:CreateSound("rbxassetid://13907558634", 1, 1, true, 10)
end