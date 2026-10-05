return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://99837158417289", 0.875, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://99837158417289", 0.5, 1.5, true, 10)
end