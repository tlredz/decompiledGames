return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.9 / p) then
		return
	end

	object:CreateSound("rbxassetid://13160326139", 0.5, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://95394392315850", 0.5, 1, true, 5)
	object:CreateSound("rbxassetid://14000023581", 0.125, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.9 / p) then
		return
	end

	object:CreateSound("rbxassetid://113130804676761", 0.5, 1, true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.36 / p) then
		return
	end

	object:CreateSound("rbxassetid://113130804676761", 0.4, 1.25, true, 5)

	if not object:_AnimationWait(script.Name, p2, 3.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://92660146054151", 0.5, 1, true, 5)
end