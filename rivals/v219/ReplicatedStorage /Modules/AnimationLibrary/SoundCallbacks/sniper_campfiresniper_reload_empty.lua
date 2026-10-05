return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.65 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395017", 1, 2, true, 10)
	object:CreateSound("rbxassetid://13455395017", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.233 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395090", 0.25, 0.75 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://112852622692949", 0.875, 1.1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.85 / p) then
		return
	end

	object:CreateSound("rbxassetid://117184161634687", 0.875, 1 + 0.05 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.78 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455394948", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455394948", 1, 2, true, 10)
end