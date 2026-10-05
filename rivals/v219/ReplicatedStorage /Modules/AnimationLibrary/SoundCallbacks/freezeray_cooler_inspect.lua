return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://130350823905316", 0.875, 1 + 0.2 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://91186416702443", 0.25, 1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 1.95 / p) then
		return
	end

	object:CreateSound("rbxassetid://91186416702443", 0.5, 0.9 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://130350823905316", 0.875, 1 + 0.2 * math.random(), true, 5)
end