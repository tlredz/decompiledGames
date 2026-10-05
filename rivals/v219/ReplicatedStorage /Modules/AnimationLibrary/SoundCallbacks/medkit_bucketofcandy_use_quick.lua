return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://92333760834779", 1, 1, true, 10)
end