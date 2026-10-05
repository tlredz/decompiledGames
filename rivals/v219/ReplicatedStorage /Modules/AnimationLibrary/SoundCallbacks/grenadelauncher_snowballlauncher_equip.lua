return function(object, p, p2)
	object:CreateSound("rbxassetid://18429138544", 0.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://17274369044", 0.375, 1, true, 10)
end