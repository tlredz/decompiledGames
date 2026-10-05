return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://18429093191", 1, 1, true, 10)
end