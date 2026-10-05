return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.125 / p) then
		return
	end

	object:CreateSound("rbxassetid://17803360572", 1, 3, true, 10)
end