return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://17803360572", 1, 2, true, 10)
	object:CreateSound("rbxassetid://13236026280", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.717 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 2.783 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.5, 1.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://17803360572", 1, 3, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://17803360572", 1, 1.25, true, 10)
end