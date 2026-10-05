return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236549929", 1, 0.875, true, 10)

	if not object:_AnimationWait(script.Name, p2, 2.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236549929", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395017", 1, 0.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395017", 1, 1.1, true, 10)
end