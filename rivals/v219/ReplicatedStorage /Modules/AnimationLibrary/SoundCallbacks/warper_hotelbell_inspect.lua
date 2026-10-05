return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://120936003285451", 0.5, 1, true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
		return
	end

	object:CreateSound("rbxassetid://120936003285451", 0.625, 1.125, true, 5)
end