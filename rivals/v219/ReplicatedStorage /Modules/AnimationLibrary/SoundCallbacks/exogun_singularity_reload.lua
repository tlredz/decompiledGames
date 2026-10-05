return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://17672502879", 0.875, 0.875, true, 10)
end