return function(object, p, p2)
	object:CreateSound("rbxassetid://137232955524669", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 4.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.75, 1.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.75, 1.25, true, 10)
end