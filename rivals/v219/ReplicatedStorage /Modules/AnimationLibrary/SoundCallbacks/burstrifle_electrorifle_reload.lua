return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://17803231630", 1, 1, true, 10)

	if not (object:_AnimationWait(script.Name, p2, 0.1 / p) and object:_AnimationWait(script.Name, p2, 0.95 / p)) then
		return
	end

	object:CreateSound("rbxassetid://17803231954", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.39 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.75, 1, true, 10)
end