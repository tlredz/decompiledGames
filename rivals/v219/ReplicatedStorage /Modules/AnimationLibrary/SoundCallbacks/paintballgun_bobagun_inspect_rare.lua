return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://140497591831738", 1, 1, true, 10)
end