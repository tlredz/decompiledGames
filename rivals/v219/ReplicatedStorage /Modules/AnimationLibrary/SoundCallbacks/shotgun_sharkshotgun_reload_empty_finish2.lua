return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://93644201634454", 0.75, 1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://93644201634454", 0.25, 0.75 + 0.1 * math.random(), true, 5)
end