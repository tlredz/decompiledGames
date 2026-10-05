return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 3.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://106485622539697", 1, 1 + 0.1 * math.random(), true, 5)
end