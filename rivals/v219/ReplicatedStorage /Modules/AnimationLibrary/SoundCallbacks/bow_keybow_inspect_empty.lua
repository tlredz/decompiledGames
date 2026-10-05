return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://71387264231358", 1.25, 1.5, true, 10)
	object:CreateSound("rbxassetid://13483008798", 0.5, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://71387264231358", 1.25, 1, true, 10)
	object:CreateSound("rbxassetid://13483008798", 0.5, 1.75, true, 10)
end