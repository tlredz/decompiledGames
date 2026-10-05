return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395017", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395090", 0.25, 0.75 + 0.25 * math.random(), true, 10)
	object:CreateSound("rbxassetid://13455229044", 1, 0.8, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455229188", 1, 0.8, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.65 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395017", 1, 0.7, true, 10)
end