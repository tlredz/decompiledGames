return function(object, p, p2)
	object:CreateSound("rbxassetid://13158735106", 0.25, 0.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236549929", 1, 0.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.8 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236549962", 1, 0.875, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395017", 1, 1.75, true, 10)
end