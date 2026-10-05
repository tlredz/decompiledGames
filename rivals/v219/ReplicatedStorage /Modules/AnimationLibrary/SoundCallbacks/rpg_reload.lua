return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.666 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456746131", 0.75, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456746075", 1, 1, true, 10)
end