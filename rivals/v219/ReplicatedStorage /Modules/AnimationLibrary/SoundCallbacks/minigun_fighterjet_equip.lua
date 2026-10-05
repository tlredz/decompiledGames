return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://17247639614", 0.25, 1 + 0.1 * math.random(), true, 10)
end