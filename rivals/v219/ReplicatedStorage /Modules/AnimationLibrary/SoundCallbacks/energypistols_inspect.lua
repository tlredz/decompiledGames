return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1.25, 1.75, true, 0.5 / p)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.2, 1.375, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.15, 1.25, true, 10)
end