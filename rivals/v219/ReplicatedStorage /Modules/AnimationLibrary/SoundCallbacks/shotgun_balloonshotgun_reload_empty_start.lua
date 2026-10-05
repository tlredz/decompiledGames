return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://17803360572", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.85 / p) then
		return
	end

	object:CreateSound("rbxassetid://17803360572", 1, 3, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://17803360572", 1, 1.25, true, 10)
end