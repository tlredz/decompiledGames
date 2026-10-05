return function(object, p, p2)
	object:CreateSound("rbxassetid://100664516053133", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 0.5, 2, true, 10)
	object:CreateSound("rbxassetid://110122962237431", 0.375, 1.5 + 0.5 * math.random(), true, 5)
end