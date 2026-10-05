return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.85 / p) then
		return
	end

	object:CreateSound("rbxassetid://122265646069920", 0.875, 1 + 0.2 * math.random(), true, 5)
end