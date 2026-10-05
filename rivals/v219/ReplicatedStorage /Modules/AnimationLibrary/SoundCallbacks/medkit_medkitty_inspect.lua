return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.65 / p) then
		return
	end

	object:CreateSound("rbxassetid://92941076104902", 1, 0.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://128990235337969", 1.5, 1, true, 10)
end