return function(object, p, p2)
	object:CreateSound("rbxassetid://115657023572170", 1, 1.5 + 0.25 * math.random(), true, 10)
	object:CreateSound("rbxassetid://13479562219", 0.875, 2 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.75, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.25, 1.5, true, 10)
end