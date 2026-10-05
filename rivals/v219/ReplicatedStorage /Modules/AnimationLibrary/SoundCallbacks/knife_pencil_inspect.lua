return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.125, 1.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.85 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.125, 1.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.125, 1.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.1, 1.25, true, 10)
end