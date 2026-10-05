return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.25, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://70883497288606", 0.75, 1 + 0.1 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://70883497288606", 0.6, 0.875 + 0.075 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://70883497288606", 0.45, 0.75 + 0.05 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 2.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://13158735106", 0.25, 1.5, true, 10)
end