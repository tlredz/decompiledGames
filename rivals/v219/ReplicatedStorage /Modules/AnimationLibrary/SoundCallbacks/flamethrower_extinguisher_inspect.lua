return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://137260230649042", 0.75, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://137260230649042", 0.875, 1.25, true, 10)
end