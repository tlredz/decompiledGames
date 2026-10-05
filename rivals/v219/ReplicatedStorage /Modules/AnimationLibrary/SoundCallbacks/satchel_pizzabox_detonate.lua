return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://129245637994313", 1, 1.5, true, 10)
	object:CreateSound("rbxassetid://80643999817278", 1, 1.5, true, 10)
end