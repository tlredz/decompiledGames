return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://71387264231358", 2.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://71387264231358", 1.5, 0.875, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13515046872", 0.75, 1, true, 10)
	object:CreateSound("rbxassetid://90757583550672", 0.5, 3 + 0.25 * math.random(), true, 5)
end