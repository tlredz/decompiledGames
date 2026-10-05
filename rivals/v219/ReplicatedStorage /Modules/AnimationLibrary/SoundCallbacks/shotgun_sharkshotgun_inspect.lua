return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.65 / p) then
		return
	end

	object:CreateSound("rbxassetid://93644201634454", 0.75, 1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://93644201634454", 0.75, 0.75 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://93644201634454", 0.375, 0.875 + 0.05 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://93644201634454", 0.375, 0.875 + 0.05 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://93644201634454", 0.75, 1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://93644201634454", 0.75, 0.75 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.65 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
end