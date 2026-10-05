return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.25, 1, true, 10)
end