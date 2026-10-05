return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236026280", 0.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13235979356", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 1, true, 10)
end