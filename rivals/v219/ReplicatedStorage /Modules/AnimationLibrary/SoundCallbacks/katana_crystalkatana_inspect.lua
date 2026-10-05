return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 2.65 / p) then
		return
	end

	object:CreateSound("rbxassetid://134472359434980", 0.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.65 / p) then
		return
	end

	object:CreateSound("rbxassetid://108380234827963", 0.5, 1.75 + 0.25 * math.random(), true, 10)
end