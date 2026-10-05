return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.175 / p) then
		return
	end

	object:CreateSound("rbxassetid://14522189766", 2, 1 + 0.25 * math.random(), true, 10)
	object:CreateSound("rbxassetid://137900058595276", 1, 1.25, true, 10)
end