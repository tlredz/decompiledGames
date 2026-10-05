return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455229044", 1, 2, true, 10)
end