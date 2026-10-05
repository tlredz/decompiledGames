return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://14427935597", 0.75, 1.125, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://130511754869111", 1.5, 1 + 0.1 * math.random(), true, 10)
	object:CreateSound("rbxassetid://119684878895970", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 1, 1.25, true, 10)
end