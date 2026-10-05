return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.75, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.1666666666666667 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1.5, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://17803360572", 1, 2, true, 10)
end