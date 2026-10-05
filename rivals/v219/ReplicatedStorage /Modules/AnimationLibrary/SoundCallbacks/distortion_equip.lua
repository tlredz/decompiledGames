return function(object, p, p2)
	object:CreateSound("rbxassetid://73931497990415", 0.75, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.9 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.125, 1.5, true, 10)
end