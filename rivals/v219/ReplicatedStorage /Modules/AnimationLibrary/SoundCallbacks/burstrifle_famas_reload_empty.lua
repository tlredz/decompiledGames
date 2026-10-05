return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236549962", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.8 / p) then
		return
	end

	object:CreateSound("rbxassetid://13236549962", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395017", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.217 / p) then
		return
	end

	object:CreateSound("rbxassetid://13455395017", 1, 1.25, true, 10)
end