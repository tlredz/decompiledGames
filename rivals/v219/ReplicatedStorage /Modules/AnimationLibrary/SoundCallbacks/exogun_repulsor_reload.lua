return function(object, p, p2)
	object:CreateSound("rbxassetid://80245415527547", 0.75, 1 + 0.1 * math.random(), true, 5)
	object:CreateSound("rbxassetid://94519339983000", 0.75, 1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://86450952337176", 0.75, 1 + 0.1 * math.random(), true, 5)
end