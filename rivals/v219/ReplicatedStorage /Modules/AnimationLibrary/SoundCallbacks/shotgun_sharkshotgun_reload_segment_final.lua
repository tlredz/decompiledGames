return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13515046872", 1, 1, true, 10)
	object:CreateSound("rbxassetid://71924311860992", 0.75, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://93644201634454", 0.75, 0.75 + 0.1 * math.random(), true, 5)
end