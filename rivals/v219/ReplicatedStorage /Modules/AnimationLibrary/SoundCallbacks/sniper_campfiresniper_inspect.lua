return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://112852622692949", 0.875, 1.1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 1.1666666666666667 / p) then
		return
	end

	object:CreateSound("rbxassetid://117184161634687", 0.875, 1 + 0.05 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.7166666666666667 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395017", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.18333333333333332 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395017", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.2166666666666666 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455394948", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.23333333333333334 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455394948", 1, 2, true, 10)
end