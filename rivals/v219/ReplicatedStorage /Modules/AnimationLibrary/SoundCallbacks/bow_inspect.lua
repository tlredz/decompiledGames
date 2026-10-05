return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.9 / p) then
		return
	end

	object:CreateSound("rbxassetid://13682532502", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.075 / p) then
		return
	end

	object:CreateSound("rbxassetid://13682532502", 0.5, 2, true, 10)
end