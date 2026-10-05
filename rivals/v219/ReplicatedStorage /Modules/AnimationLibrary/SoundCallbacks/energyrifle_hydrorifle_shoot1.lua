return function(object, p, p2)
	object:CreateSound("rbxassetid://73644074370077", 0.875, 1 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://108166862465565", 0.75, 1 + 0.2 * math.random(), true, 5)

	for _ = 1, 3 do
		object:CreateSound("rbxassetid://18763517194", 1, 1 + 0.25 * math.random(), true, 5)

		if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
			break
		end
	end
end