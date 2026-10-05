return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://111876623538044", 1, 1 + 0.1 * math.random(), true, 10)
end