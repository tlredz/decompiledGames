return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://14427935597", 0.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.28 / p) then
		return
	end

	object:CreateSound("rbxassetid://14427935597", 0.5, 1.125, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.42 / p) then
		return
	end

	object:CreateSound("rbxassetid://14427935597", 0.5, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://12222208", 0.5, 1, true, 10)
	object:CreateSound("rbxassetid://14427782350", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://12222208", 0.5, 1, true, 10)
	object:CreateSound("rbxassetid://14427782350", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.58 / p) then
		return
	end

	object:CreateSound("rbxassetid://12222208", 0.5, 1, true, 10)
	object:CreateSound("rbxassetid://14427782350", 1, 1, true, 10)
end