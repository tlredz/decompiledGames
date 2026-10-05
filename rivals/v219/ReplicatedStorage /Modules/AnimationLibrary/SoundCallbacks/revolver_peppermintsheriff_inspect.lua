return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1.5, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1.25, 1.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 2.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 3.95 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1.5, 1.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1.25, 2.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.41 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 2.25, true, 10)
end