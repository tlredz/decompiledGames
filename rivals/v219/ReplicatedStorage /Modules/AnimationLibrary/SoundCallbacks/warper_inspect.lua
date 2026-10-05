return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
end