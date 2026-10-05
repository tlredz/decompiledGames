return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.85 / p) then
		return
	end

	object:CreateSound("rbxassetid://88834968924220", 1, 1 + 0.2 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.25, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128896162", 1, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://122724754588572", 1.25, 1 + 0.2 * math.random(), true, 5)
end