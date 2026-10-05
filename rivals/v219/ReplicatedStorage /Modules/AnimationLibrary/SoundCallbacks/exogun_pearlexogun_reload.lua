return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://17266070911", 0.75, 1, true, 10)
	object:CreateSound("rbxassetid://121938614359106", 0.75, 0.75, true, 10)
end