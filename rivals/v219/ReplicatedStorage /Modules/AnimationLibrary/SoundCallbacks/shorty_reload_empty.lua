return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.2833333333333333 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236026280", 0.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.03333333333333333 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236026280", 0.5, 1.1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.0666666666666667 / p) then
		return
	end

	object:CreateSound("rbxassetid://13235979356", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.06666666666666667 / p) then
		return
	end

	object:CreateSound("rbxassetid://13235979356", 1, 1.1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://13483008798", 1, 1, true, 10)
end