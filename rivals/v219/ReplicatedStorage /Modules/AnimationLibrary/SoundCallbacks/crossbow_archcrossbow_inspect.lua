return function(object, p, p2)
	object:CreateSound("rbxassetid://130860307965581", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 7.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://114610550422028", 1, 1 + 0.25 * math.random(), true, 10)
end