return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.175 / p) then
		return
	end

	object:CreateSound("rbxassetid://14522189766", 2, 1 + 0.25 * math.random(), true, 10)
	object:CreateSound("rbxassetid://96253147006478", 0.6, 1.75, true, 10)
end