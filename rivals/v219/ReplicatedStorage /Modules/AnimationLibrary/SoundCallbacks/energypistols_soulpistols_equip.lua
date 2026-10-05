return function(object, p, p2)
	object:CreateSound("rbxassetid://13456860578", 1.25, 1.5, true, 0.5 / p)
	object:CreateSound("rbxassetid://134917124344503", 0.5, 1.25, true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 2, true, 10)
end