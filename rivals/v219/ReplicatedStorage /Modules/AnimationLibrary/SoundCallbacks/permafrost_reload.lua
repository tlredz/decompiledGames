return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://97621886814272", 1, 3 + 0.25 * math.random(), true, 10)
	object:CreateSound("rbxassetid://13160326139", 0.375, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236026280", 0.5, 2.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://97621886814272", 1, 2.5 + 0.125 * math.random(), true, 10)
	object:CreateSound("rbxassetid://13160326139", 0.375, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236026280", 0.375, 1.75, true, 10)
end