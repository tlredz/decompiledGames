return function(object, p, p2)
	local sound = object:CreateSound("rbxassetid://13645858587", 0.375, 1, true)

	if sound then
		sound.Looped = true
	end

	local sound2 = object:CreateSound("rbxassetid://13646484249", 0.375, 1, true)

	if sound2 then
		sound2.Looped = true
	end

	local sound3 = object:CreateSound("rbxassetid://13646484113", 0.25, 1, true)

	if sound3 then
		sound3.Looped = true
	end

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://17247639614", 0.75, 1 + 0.1 * math.random(), true, 10)
end