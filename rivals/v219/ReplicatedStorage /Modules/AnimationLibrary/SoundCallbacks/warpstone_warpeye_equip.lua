return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://73717852775255", 1, 1 + 0.2 * math.random(), true, 10)
end