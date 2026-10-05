return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.95 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.9 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://134472359434980", 0.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://134472359434980", 0.4, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.375 / p) then
		return
	end

	object:CreateSound("rbxassetid://134472359434980", 0.3, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.775 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.375, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://108380234827963", 0.5, 1.75 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
end