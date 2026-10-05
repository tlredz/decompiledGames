return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.8 / p) then
		return
	end

	object:CreateSound("rbxassetid://89929936303974", 0.875, 1 + 0.2 * math.random(), true, 5)
end