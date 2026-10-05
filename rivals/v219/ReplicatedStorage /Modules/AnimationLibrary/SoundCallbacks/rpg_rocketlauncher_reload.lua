return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.85 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456746075", 0.75, 1.25, true, 10)
end