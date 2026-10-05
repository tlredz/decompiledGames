return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://126069605787926", 1, 1.25 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.03 / p) then
		return
	end

	object:CreateSound("rbxassetid://126069605787926", 1, 1.25 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.12 / p) then
		return
	end

	object:CreateSound("rbxassetid://126069605787926", 1, 1.25 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.083 / p) then
		return
	end

	object:CreateSound("rbxassetid://126069605787926", 1, 1.25 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://126069605787926", 1, 1.25 + 0.25 * math.random(), true, 10)
end