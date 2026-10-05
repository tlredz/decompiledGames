return function(object, p, p2)
	object:CreateSound("rbxassetid://84897543898396", 0.5, 0.95 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://13682183816", 0.5, 0.95 + 0.1 * math.random(), true, 10)
end