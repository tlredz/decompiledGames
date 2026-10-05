return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://134160823775126", 1.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://85750875050391", 1.25, 1, true, 10)
end