return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://112852622692949", 0.875, 1.1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://117184161634687", 0.875, 1 + 0.05 * math.random(), true, 5)
end