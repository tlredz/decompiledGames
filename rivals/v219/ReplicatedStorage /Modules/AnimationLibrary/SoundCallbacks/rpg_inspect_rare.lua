return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456613343", 0.5, 1, true, 10)
end