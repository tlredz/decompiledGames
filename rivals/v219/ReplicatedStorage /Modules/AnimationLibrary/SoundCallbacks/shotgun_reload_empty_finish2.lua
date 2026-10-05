return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.56 / p) then
		return
	end

	object:CreateSound("rbxassetid://13515046921", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.19 / p) then
		return
	end

	object:CreateSound("rbxassetid://13515046988", 1, 1.25, true, 10)
end