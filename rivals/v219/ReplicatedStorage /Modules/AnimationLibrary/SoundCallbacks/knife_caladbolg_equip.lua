return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://101161696630107", 1.5, 1, true, 10)
	object:CreateSound("rbxassetid://136174258344321", 0.5, 2 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.9 / p) then
		return
	end

	object:CreateSound("rbxassetid://14427935597", 0.75, 1.125, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 1, 1.25, true, 10)
end