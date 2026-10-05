return function(object, p, p2)
	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128896162", 1, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.95 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128896162", 1, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.56 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128896162", 1, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.29 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128896162", 0.5, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.8 / p) then
		return
	end

	if math.random() < 0.628 then
		object:CreateSound("rbxassetid://18128949754", 0.6, 1 + 0.1 * math.random(), true, 10)
	end
end