return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.5, 0.8, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.625, 0.9, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.75, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.5, 1.375, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.25, 1.5, true, 10)
end