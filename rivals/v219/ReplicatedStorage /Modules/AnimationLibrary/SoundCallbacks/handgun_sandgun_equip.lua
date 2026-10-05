return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158610792", 1, 1, true, 10)
	object:CreateSound("rbxassetid://87740786635301", 0.375 + 0.25 * math.random(), 0.9 + 0.4 * math.random(), true, 5)
end