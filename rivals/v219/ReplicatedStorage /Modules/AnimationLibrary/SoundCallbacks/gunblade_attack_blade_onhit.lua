return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.38 / p) then
		return
	end

	object:CreateSound("rbxassetid://96886470957330", 0.875, 1.25 + 0.125 * math.random(), true, 5)
end