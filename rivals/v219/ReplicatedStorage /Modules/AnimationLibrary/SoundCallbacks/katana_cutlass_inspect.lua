return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 3.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.75, true, 10)
	object:CreateSound("rbxassetid://95394392315850", 0.25, 1, true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 2, true, 10)
	object:CreateSound("rbxassetid://88960734678343", 0.25, 1.25, true, 5)
end