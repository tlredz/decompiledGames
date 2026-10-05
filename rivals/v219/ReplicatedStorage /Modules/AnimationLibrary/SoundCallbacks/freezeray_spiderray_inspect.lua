return function(object, p, p2)
	object:CreateSound("rbxassetid://119827986766384", 0.75, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://119827986766384", 0.5, 0.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://119827986766384", 0.375, 0.5, true, 10)
end