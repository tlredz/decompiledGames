return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.78 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456746131", 0.75, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456746075", 1, 1.75, true, 10)
end