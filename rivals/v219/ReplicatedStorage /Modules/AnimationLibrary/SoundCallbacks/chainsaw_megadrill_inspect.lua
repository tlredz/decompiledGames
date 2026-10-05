return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://17247639614", 0.875, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 2.9 / p) then
		return
	end

	object:CreateSound("rbxassetid://17247639614", 0.75, 0.8 + 0.1 * math.random(), true, 10)
end