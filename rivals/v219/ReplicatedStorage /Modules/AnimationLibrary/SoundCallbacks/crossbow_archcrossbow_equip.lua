return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.65 / p) then
		return
	end

	object:CreateSound("rbxassetid://118906938239363", 1, 0.9 + 0.2 * math.random(), true, 10)
end