return function(object, p, p2)
	object:CreateSound("rbxassetid://71387264231358", 1.25, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.375, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 3.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.6, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.6, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.6, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.6, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://93178963908825", 1, 1 + 0.25 * math.random(), true, 10)
	object:CreateSound("rbxassetid://96253147006478", 0.625, 1.75 + 0.5 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.9 / p) then
		return
	end

	object:CreateSound("rbxassetid://71387264231358", 1.25, 1, true, 10)
end