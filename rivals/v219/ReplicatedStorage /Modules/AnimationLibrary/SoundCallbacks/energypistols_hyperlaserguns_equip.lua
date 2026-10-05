return function(object, p, p2)
	object:CreateSound("rbxassetid://13456860578", 1.25, 1.5, true, 0.5 / p)
	object:CreateSound("rbxassetid://130113370", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 2, true, 10)
end