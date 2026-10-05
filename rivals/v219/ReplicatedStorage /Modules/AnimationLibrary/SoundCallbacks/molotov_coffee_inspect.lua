return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.9 / p) then
		return
	end

	object:CreateSound("rbxassetid://17814389291", 1, 1.25, true, 10)
end