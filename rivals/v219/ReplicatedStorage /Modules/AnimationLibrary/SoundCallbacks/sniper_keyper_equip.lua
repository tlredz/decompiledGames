return function(object, p, p2)
	object:CreateSound("rbxassetid://100664516053133", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455394948", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455394948", 1, 2, true, 10)
end