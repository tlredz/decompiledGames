return function(object, p, p2)
	if not (object:_AnimationWait(script.Name, p2, 0.3 / p) and object:_AnimationWait(script.Name, p2, 0.3 / p)) then
		return
	end

	object:CreateSound("rbxassetid://17092564046", 0.5, 1.75, true, 10)
	object:CreateSound("rbxassetid://17803360572", 1, 2 + 0.2 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://14427935597", 0.5, 0.75, true, 10)
	object:CreateSound("rbxassetid://13456860578", 1.25, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.95 / p) then
		return
	end

	object:CreateSound("rbxassetid://17092564046", 0.75, 1, true, 10)
	object:CreateSound("rbxassetid://17803360572", 1, 1 + 0.1 * math.random(), true, 10)

	if object:_AnimationWait(script.Name, p2, 0.2 / p) then
	end
end