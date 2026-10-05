return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://111475442610934", 4, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.28 / p) then
		return
	end

	object:CreateSound("rbxassetid://106855758356398", 0.25, 1.5, true, 10)
end