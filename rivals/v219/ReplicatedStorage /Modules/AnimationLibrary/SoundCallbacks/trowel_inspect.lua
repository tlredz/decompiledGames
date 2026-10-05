return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.9 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 0.25, 2, true, 10)
	object:CreateSound("rbxassetid://14427935597", 0.375, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.75, 1.25, true, 10)
end