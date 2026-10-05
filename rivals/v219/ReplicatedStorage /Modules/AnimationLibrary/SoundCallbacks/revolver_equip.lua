return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 0.5, 2, true, 10)
end