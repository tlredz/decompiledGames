return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://88497957004619", 1, 1, true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://88497957004619", 0.9, 1.1, true, 5)
end