return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://137300623286123", 0.75, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://128809359344035", 1, 0.9 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.233 / p) then
		return
	end

	object:CreateSound("rbxassetid://128809359344035", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.217 / p) then
		return
	end

	object:CreateSound("rbxassetid://128809359344035", 1, 0.8 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.317 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
end