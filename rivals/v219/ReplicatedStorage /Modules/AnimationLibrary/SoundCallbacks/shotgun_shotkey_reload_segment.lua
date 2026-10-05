return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13515046872", 0.75, 1, true, 10)
	object:CreateSound("rbxassetid://90757583550672", 0.5, 3 + 0.25 * math.random(), true, 5)
end