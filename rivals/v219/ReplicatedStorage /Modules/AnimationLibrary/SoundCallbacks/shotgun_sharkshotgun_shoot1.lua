return function(object, p, p2)
	object:CreateSound("rbxassetid://13479562219", 0.75, 1.25 + 0.25 * math.random(), true, 10)
	object:CreateSound("rbxassetid://89420994269759", 1, 1 + 0.1 * math.random(), true, 5)
	object:CreateSound("rbxassetid://107381185026224", 1, 1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://93644201634454", 0.75, 1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://93644201634454", 0.25, 0.75 + 0.1 * math.random(), true, 5)
end