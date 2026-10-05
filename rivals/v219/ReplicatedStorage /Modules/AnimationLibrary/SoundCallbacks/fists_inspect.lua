return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.3333333333333333 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160489311", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160489311", 0.5, 0.75, true, 10)
end