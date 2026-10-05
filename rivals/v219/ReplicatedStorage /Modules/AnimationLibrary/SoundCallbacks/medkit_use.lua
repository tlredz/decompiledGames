return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236026280", 0.5, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.48 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.5, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.22 / p) then
		return
	end

	object:CreateSound("rbxassetid://13505411336", 0.75, 3.1 * p, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://13505411414", 0.75, 1.25, true, 10)
end