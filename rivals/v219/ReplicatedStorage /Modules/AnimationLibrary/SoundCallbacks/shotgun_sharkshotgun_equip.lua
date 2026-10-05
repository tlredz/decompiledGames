return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://93644201634454", 0.75, 0.75 + 0.1 * math.random(), true, 5)
	object:CreateSound("rbxassetid://107381185026224", 0.5, 1 + 0.1 * math.random(), true, 5)
end