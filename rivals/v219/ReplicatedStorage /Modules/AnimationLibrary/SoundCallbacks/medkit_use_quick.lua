return function(object, p, p2)
	object:CreateSound("rbxassetid://13158735106", 0.25, 1.75, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://17123622923", 2, 1, true, 10)
end