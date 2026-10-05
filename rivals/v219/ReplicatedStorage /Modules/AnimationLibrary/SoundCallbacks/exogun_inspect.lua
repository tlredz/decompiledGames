return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.15, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.8 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.1, 1.25, true, 10)
end