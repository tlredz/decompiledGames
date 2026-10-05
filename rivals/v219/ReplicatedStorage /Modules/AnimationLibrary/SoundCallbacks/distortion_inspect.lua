return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://139955889483895", 0.75, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 2.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://139955889483895", 0.75, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://132926867312544", 0.25, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
end