return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://17247639614", 0.25, 1 + 0.05 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://17247639272", 0.2, 0.95 + 0.05 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 3.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://17247639272", 0.15, 0.9 + 0.05 * math.random(), true, 10)
end