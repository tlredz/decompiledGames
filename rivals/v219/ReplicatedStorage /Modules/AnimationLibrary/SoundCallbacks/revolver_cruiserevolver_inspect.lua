return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.95 / p) then
		return
	end

	object:CreateSound("rbxassetid://134815282110155", 0.75, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://134815282110155", 0.5, 1, true, 10)
end