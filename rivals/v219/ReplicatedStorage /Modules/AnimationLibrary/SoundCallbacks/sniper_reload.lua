return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455229044", 1, 1.1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.92 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455229188", 1, 1.1, true, 10)
end