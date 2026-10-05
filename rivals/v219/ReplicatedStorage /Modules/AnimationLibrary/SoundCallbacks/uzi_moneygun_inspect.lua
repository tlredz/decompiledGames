return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236026280", 0.5, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 2.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236026280", 0.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.2, 1.25, true, 10)
end