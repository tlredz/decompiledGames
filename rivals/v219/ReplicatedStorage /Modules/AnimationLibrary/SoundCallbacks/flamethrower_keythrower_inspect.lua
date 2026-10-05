return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.5, 0.8, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.375, 0.8, true, 10)

	if not object:_AnimationWait(script.Name, p2, 2.8 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
end