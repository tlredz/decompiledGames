return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1, 1, true, 10)
	object:CreateSound("rbxassetid://13160326139", 0.25, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.01 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860532", 1, 1.1, true, 10)
	object:CreateSound("rbxassetid://13160326139", 0.25, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.125, 1, true, 10)
end