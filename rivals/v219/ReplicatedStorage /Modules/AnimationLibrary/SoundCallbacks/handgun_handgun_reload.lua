return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://127707586685295", 1, 1 + 0.2 * math.random(), true, 5)
end