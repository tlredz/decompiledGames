return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.85 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 0.5, 1.25, true, 10)
	object:CreateSound("rbxassetid://13160326139", 0.5, 1, true, 10)
end