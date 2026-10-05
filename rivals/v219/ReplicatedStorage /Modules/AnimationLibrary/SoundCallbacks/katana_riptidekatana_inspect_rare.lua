return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://14427935597", 0.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://14427935597", 0.5, 1.125, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://14427935597", 0.5, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://14000023581", 0.5, 1, true, 10)
	object:CreateSound("rbxassetid://14427782350", 1, 1, true, 10)
	object:CreateSound("rbxassetid://118319832364364", 0.875, 1 + 0.125 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://14000023581", 0.5, 1, true, 10)
	object:CreateSound("rbxassetid://14427782350", 1, 1, true, 10)
	object:CreateSound("rbxassetid://118319832364364", 0.875, 1.125 + 0.125 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://14000023581", 0.5, 1, true, 10)
	object:CreateSound("rbxassetid://14427782350", 1, 1, true, 10)
	object:CreateSound("rbxassetid://118319832364364", 0.875, 1.25 + 0.125 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 1.55 / p) then
		return
	end

	object:CreateSound("rbxassetid://70883497288606", 0.625, 1.25 + 0.1 * math.random(), true, 5)
end