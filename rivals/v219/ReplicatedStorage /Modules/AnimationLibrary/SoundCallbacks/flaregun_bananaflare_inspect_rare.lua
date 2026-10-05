return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128896162", 0.5, 1 + 0.25 * math.random(), true, 10)
end