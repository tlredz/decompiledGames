return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://130350823905316", 0.875, 1 + 0.2 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://91186416702443", 0.25, 0.9 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://91186416702443", 0.2, 0.9 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://91186416702443", 0.75, 1.25 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://91186416702443", 0.75, 1.25 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://130350823905316", 0.875, 1 + 0.2 * math.random(), true, 5)
end