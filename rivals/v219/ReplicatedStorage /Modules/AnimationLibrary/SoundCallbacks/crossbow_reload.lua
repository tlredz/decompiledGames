return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.85 / p) then
		return
	end

	object:CreateSound("rbxassetid://13682532502", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://76155503538875", 0.375, 1.75, true, 10)
end