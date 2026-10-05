return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://103864728645343", 1, 1, true, 10)
end