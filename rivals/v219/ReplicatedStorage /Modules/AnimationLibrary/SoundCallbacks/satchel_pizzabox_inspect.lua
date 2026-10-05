return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://124893673183314", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://129245637994313", 0.5, 1.5, true, 10)
	object:CreateSound("rbxassetid://80643999817278", 0.5, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.75 / p) then
		return
	end

	object:CreateSound("rbxassetid://13456860578", 1, 1, true, 10)
	object:CreateSound("rbxassetid://13160326139", 0.25, 1, true, 10)
end