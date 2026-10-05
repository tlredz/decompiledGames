return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236026280", 0.5, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://120574582651469", 0.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://76703369839400", 0.875, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236026280", 0.5, 1, true, 10)
end