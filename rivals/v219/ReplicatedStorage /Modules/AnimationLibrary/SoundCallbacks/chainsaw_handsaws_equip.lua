return function(object, p, p2)
	object:CreateSound("rbxassetid://13645858977", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13645858977", 1, 1.375, true, 10)
end