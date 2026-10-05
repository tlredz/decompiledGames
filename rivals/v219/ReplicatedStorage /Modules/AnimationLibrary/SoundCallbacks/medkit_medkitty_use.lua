return function(object, p, p2)
	object:CreateSound("rbxassetid://128632959026124", 1.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://106320000244648", 1.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.8 / p) then
		return
	end

	object:CreateSound("rbxassetid://103145233607638", 1.5, 0.875, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://103145233607638", 1.35, 0.9, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://103145233607638", 1.2, 0.925, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://103145233607638", 1, 0.95, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://81623846775515", 0.75, 2.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.375 / p) then
		return
	end

	object:CreateSound("rbxassetid://128990235337969", 1.5, 1, true, 10)
end