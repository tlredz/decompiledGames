return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.7 / p) then
		return
	end

	object:CreateSound("rbxassetid://134472359434980", 0.5, 1, true, 10)
end