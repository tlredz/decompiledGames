return function(object, p, p2)
	object:CreateSound("rbxassetid://100664516053133", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://71387264231358", 1.5, 0.875, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.75, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.25, 1.5, true, 10)
end