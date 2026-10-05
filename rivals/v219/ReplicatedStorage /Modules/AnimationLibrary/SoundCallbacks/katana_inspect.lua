return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.125, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://14000093824", 0.75, 1.4, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://14000093824", 0.625, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://14000093824", 0.5, 1.6, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://14000093824", 1, 1, true, 10)
end