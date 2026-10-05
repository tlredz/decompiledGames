return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.375 / p) then
		return
	end

	object:CreateSound("rbxassetid://134160823775126", 0.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://128990235337969", 0.75, 0.75, true, 10)
end