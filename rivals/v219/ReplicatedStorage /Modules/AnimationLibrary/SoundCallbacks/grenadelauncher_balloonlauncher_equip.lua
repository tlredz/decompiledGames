return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://17274369044", 0.375, 1, true, 10)
	object:CreateSound("rbxassetid://17803360572", 1, 1 + 0.2 * math.random(), true, 10)
end