return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.375, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.25, true, 10)
end