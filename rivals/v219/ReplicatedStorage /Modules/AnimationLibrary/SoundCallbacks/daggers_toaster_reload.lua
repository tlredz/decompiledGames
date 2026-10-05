return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://122724754588572", 1.25, 1 + 0.2 * math.random(), true, 5)
end