return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	object:CreateSound("rbxassetid://13515046921", 1, 1.25, true, 10)
	object:CreateSound("rbxassetid://13236026280", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.717 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 2.783 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.5, 1.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://13235979356", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://13515046988", 1, 1.25, true, 10)
end