return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://14427935597", 0.5, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.58 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.75, 1.5, true, 10)
end