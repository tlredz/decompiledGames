return function(object, p, p2)
	object:CreateSound("rbxassetid://13456860578", 1.5, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 0.75, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.5, 1.5, true, 10)
end