return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.38 / p) then
		return
	end

	object:CreateSound("rbxassetid://82156077357708", 0.875, 1 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://121373202237894", 0.875, 1 + 0.2 * math.random(), true, 5)
end