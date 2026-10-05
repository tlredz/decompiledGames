return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.85 / p) then
		return
	end

	object:CreateSound("rbxassetid://71387264231358", 2.5, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.31 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236026280", 0.625, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 2.84 / p) then
		return
	end

	object:CreateSound("rbxassetid://71387264231358", 2.5, 0.875, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236026280", 0.5, 1.75, true, 10)
end