return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://17274387490", 0.375, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://17274387490", 0.25, 0.9, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.2, 1.25, true, 10)
end