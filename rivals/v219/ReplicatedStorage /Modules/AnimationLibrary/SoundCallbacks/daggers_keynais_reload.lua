return function(object, p, p2)
	object:CreateSound("rbxassetid://96253147006478", 0.3, 2.5 + 0.5 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.3, 2.5 + 0.5 * math.random(), true, 10)
end