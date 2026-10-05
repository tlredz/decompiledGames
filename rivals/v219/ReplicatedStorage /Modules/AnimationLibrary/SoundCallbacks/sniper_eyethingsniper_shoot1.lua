return function(object, p, p2)
	object:CreateSound("rbxassetid://13270206222", 0.875, 0.95 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://13270206087", 0.875, 0.95 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://71304774842482", 0.875, 0.95 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395017", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.067 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395017", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455394948", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.183 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455394948", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395090", 0.25, 0.75 + 0.25 * math.random(), true, 10)
end