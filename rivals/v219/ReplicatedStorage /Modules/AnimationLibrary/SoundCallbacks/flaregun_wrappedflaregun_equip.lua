return function(object, p, p2)
	object:CreateSound("rbxassetid://123443443495942", 0.5, 1.25, true, 10)
	object:CreateSound("rbxassetid://13456860578", 1.5, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 0.75, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158330383", 1, 1, true, 10)
end