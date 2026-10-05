return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.95 / p) then
		return
	end

	object:CreateSound("rbxassetid://108879620126710", 1.25, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 2.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://14000023581", 1, 0.75, true, 10)
	object:CreateSound("rbxassetid://86510987016114", 0.75, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.82 / p) then
		return
	end

	object:CreateSound("rbxassetid://90310901394527", 1.25, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.33 / p) then
		return
	end

	object:CreateSound("rbxassetid://14427782350", 1, 0.875, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://118906938239363", 1, 0.9 + 0.2 * math.random(), true, 10)
end