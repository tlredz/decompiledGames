return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.283 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1.25, 2.5, true, 10)
	object:CreateSound("rbxassetid://90757583550672", 0.625, 1.25 + 0.25 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.283 / p) then
		return
	end

	for i = 1, 6 do
		object:CreateSound("rbxassetid://14241444681", 1, i * 0.125 + 1, true, 10)
		object:CreateSound("rbxassetid://110122962237431", 1.25, 1.25 + 0.25 * math.random() + i * 0.125, true, 5)

		if not object:_AnimationWait(script.Name, p2, 0.044500000000000005 / p) then
			return
		end
	end

	object:CreateSound("rbxassetid://71387264231358", 1.25, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1.25, 1.75, true, 10)
	object:CreateSound("rbxassetid://90757583550672", 0.625, 1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.767 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 0.5, 2, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.375, 1.5 + 0.5 * math.random(), true, 5)
end