return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://101161696630107", 1.5, 0.5, true, 10)
	object:CreateSound("rbxassetid://136174258344321", 0.375, 1.5 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.125, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
end