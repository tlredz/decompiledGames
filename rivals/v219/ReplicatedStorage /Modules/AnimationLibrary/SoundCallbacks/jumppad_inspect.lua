return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 0.75, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.25, 1, true, 10)
	object:CreateSound("rbxassetid://13456860578", 0.5, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 0.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.58 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.175, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.42 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.125, 0.75, true, 10)
end